import asyncio
import json
import logging
import os
import re
import tempfile
import urllib.request
import uuid
from pathlib import Path
from typing import Any

# Mirrors the path used by apps/backend/src/app/api/v1/upload.py
_UPLOADS_DIR = Path(__file__).resolve().parents[4] / "static" / "uploads"

import structlog
import uvloop
from arq.worker import Worker

asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())


# -------- helpers --------

def _download_audio_sync(url: str, output_path: str, max_duration_seconds: int = 900) -> str | None:
    """Download audio from a video URL using yt-dlp (synchronous, run in thread).

    Returns the best available thumbnail URL from the video metadata, or None.
    """
    import yt_dlp

    # First extract metadata only to check duration before downloading
    with yt_dlp.YoutubeDL({"quiet": True, "no_warnings": True}) as ydl:
        info = ydl.extract_info(url, download=False)

    duration = info.get("duration") or 0
    if duration > max_duration_seconds:
        raise ValueError(
            f"La vidéo est trop longue : {duration}s (maximum {max_duration_seconds}s / 15 min)."
        )

    # Pick the highest-resolution *static* thumbnail (skip animated GIFs)
    thumbnails: list[dict] = info.get("thumbnails") or []
    thumbnail_url: str | None = None
    if thumbnails:
        _static_exts = (".jpg", ".jpeg", ".png", ".webp")
        static_thumbs = [
            t for t in thumbnails
            if not (t.get("url") or "").lower().endswith(".gif")
            and any((t.get("url") or "").lower().split("?")[0].endswith(ext) for ext in _static_exts)
        ]
        pool = static_thumbs if static_thumbs else [
            t for t in thumbnails
            if not (t.get("url") or "").lower().endswith(".gif")
        ]
        if not pool:
            pool = thumbnails
        best = max(pool, key=lambda t: (t.get("width") or 0) * (t.get("height") or 0))
        thumbnail_url = best.get("url") or info.get("thumbnail")
    else:
        thumbnail_url = info.get("thumbnail")

    # Final GIF safety-net: fall back to the yt-dlp default if best is still a GIF
    if thumbnail_url and thumbnail_url.lower().endswith(".gif"):
        thumbnail_url = info.get("thumbnail") or thumbnail_url

    ydl_opts: dict[str, Any] = {
        "format": "bestaudio/best",
        "outtmpl": output_path,
        "postprocessors": [
            {
                "key": "FFmpegExtractAudio",
                "preferredcodec": "mp3",
                "preferredquality": "64",
            }
        ],
        "quiet": True,
        "no_warnings": True,
    }
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([url])

    return thumbnail_url


def _save_thumbnail_sync(thumbnail_url: str) -> str | None:
    """Download a thumbnail URL and persist it as a JPG in the uploads directory.

    Returns the server-relative URL (/static/uploads/…) or None on failure.
    """
    try:
        _UPLOADS_DIR.mkdir(parents=True, exist_ok=True)
        filename = f"recipe_thumb_{uuid.uuid4().hex[:12]}.jpg"
        dest = _UPLOADS_DIR / filename

        req = urllib.request.Request(
            thumbnail_url,
            headers={"User-Agent": "Mozilla/5.0"},
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            dest.write_bytes(resp.read())

        return f"/static/uploads/{filename}"
    except Exception as exc:
        logging.warning("Thumbnail download failed: %s", exc)
        return None


def _call_gemini_sync(audio_path: str, language: str, api_key: str) -> dict[str, Any]:
    """Call Gemini Flash with the audio file and extract recipe JSON (synchronous)."""
    import google.generativeai as genai

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel("gemini-2.5-flash")

    with open(audio_path, "rb") as f:
        audio_bytes = f.read()

    language_hint = (
        f"The speaker in this video uses {language}. "
        if language and language.lower() != "auto"
        else ""
    )

    prompt = (
        f"{language_hint}"
        "Listen to this audio and determine whether it describes a cooking recipe. "
        "Output ONLY valid JSON (no markdown, no code fences) with exactly this structure:\n"
        "{\n"
        '  "is_cooking_recipe": true,\n'
        '  "title": "Recipe title in French",\n'
        '  "servings": 4,\n'
        '  "ingredients": [\n'
        '    {"name": "ingredient name in French", "quantity": "200", "unit": "g"}\n'
        "  ],\n"
        '  "preparation_steps": [\n'
        '    {"step_number": 1, "description": "Step description in French"}\n'
        "  ]\n"
        "}\n"
        'Set "is_cooking_recipe" to false if the audio does not describe a food recipe '
        "(e.g. it is a vlog, music, sport, news, or unrelated content). "
        "When false, you may leave all other fields empty. "
        "When true, fill every field accurately.\n"
        "IMPORTANT — the only allowed values for 'unit' are: "
        '"g", "kg", "mL", "L", "tasse", "c. à s.", "c. à c.", "pièce(s)", or "" (empty string for unitless). '
        "You MUST convert every non-standard unit to the closest allowed unit with an accurate numeric quantity. Examples:\n"
        "- '1 pot de yaourt (125 g)' → quantity: '125', unit: 'g'\n"
        "- '1 pot de sucre (using the yaourt pot as measure, ~125 g)' → quantity: '125', unit: 'g'\n"
        "- '1 pot de farine (~100 g)' → quantity: '100', unit: 'g'\n"
        "- '1 pot d'huile (~100 mL)' → quantity: '100', unit: 'mL'\n"
        "- '1 sachet de levure (~11 g)' → quantity: '11', unit: 'g'\n"
        "- '1 sachet de sucre vanillé (~8 g)' → quantity: '8', unit: 'g'\n"
        "- '1 pincée de sel' → quantity: '1', unit: 'c. à c.'\n"
        "- '1 noix de beurre (~15 g)' → quantity: '15', unit: 'g'\n"
        "- 'quelques feuilles de basilic' → quantity: '5', unit: 'pièce(s)'\n"
        "Never output a unit that is not in the allowed list. "
        "For every field not explicitly stated in the video, make your best estimate based on context:\n"
        "- 'servings': if not mentioned, infer from the total ingredient quantities and typical portion sizes "
        "(e.g. 500 g of pasta with sauce → 4 servings; a single yaourt cake → 6–8 servings).\n"
        "- 'title': infer from the ingredients and technique if not stated.\n"
        "- ingredient quantities: estimate from visual cues, standard recipe conventions, or typical amounts if not clearly stated.\n"
        "Never leave a field null or 0; always provide a reasonable value. "
        "Output all text in French. If you cannot detect a recipe, return an empty ingredients list and a single step explaining what you heard."
    )

    response = model.generate_content(
        [
            {"mime_type": "audio/mp3", "data": audio_bytes},
            prompt,
        ],
        generation_config=genai.GenerationConfig(response_mime_type="application/json"),
    )

    text = response.text.strip()
    # Strip markdown code fences if model ignores the mime type hint
    text = re.sub(r"^```(?:json)?\s*", "", text)
    text = re.sub(r"\s*```\s*$", "", text)

    return json.loads(text)


# -------- background tasks --------

async def sample_background_task(ctx: Worker, name: str) -> str:
    await asyncio.sleep(5)
    return f"Task {name} is complete!"


async def transcribe_video_task(ctx: Worker, url: str, language: str) -> dict[str, Any]:
    """Download a cooking video, transcribe it via Gemini Flash, and return a recipe dict."""
    from ...core.config import settings

    api_key = settings.GEMINI_API_KEY.get_secret_value()
    if not api_key:
        raise ValueError("GEMINI_API_KEY is not configured on the server.")

    # Use a temp directory; yt-dlp appends .mp3 after FFmpeg post-processing
    with tempfile.TemporaryDirectory() as tmp_dir:
        base_path = os.path.join(tmp_dir, "audio")
        audio_path = base_path + ".mp3"

        try:
            # Download audio and retrieve thumbnail URL (blocks — run in thread pool)
            thumbnail_url = await asyncio.to_thread(_download_audio_sync, url, base_path)

            if not os.path.exists(audio_path):
                raise FileNotFoundError(
                    f"Audio extraction failed: expected file at {audio_path}"
                )

            # Call Gemini (blocks — run in thread pool)
            recipe_data = await asyncio.to_thread(_call_gemini_sync, audio_path, language, api_key)

        except Exception:
            raise
        # Temp dir (and audio file) are automatically deleted when the context exits

    # Guard: reject non-cooking videos
    if not recipe_data.get("is_cooking_recipe", True):
        raise ValueError(
            "Cette vidéo ne semble pas contenir une recette de cuisine. "
            "Veuillez fournir un lien vers une vidéo culinaire."
        )

    # Download and save the thumbnail locally, then attach its server URL
    if thumbnail_url:
        local_url = await asyncio.to_thread(_save_thumbnail_sync, thumbnail_url)
        recipe_data["thumbnail_url"] = local_url or thumbnail_url  # CDN fallback

    return recipe_data


# -------- base functions --------
async def startup(ctx: Worker) -> None:
    logging.info("Worker Started")


async def shutdown(ctx: Worker) -> None:
    logging.info("Worker end")


async def on_job_start(ctx: dict[str, Any]) -> None:
    structlog.contextvars.bind_contextvars(job_id=ctx["job_id"])
    logging.info("Job Started")


async def on_job_end(ctx: dict[str, Any]) -> None:
    logging.info("Job Competed")
    structlog.contextvars.clear_contextvars()
