"""Video import / transcription endpoints."""
from typing import Annotated

from arq.jobs import Job, JobStatus
from fastapi import APIRouter, Depends, HTTPException

from ...api.dependencies import get_current_user
from ...core.utils import queue
from ...schemas.video_import import VideoImportRequest, VideoImportResponse, VideoImportStatus

router = APIRouter(tags=["video-import"])


@router.post("/recipes/import-from-video", response_model=VideoImportResponse, status_code=202)
async def import_from_video(
    body: VideoImportRequest,
    current_user: Annotated[dict, Depends(get_current_user)],
) -> VideoImportResponse:
    """Enqueue a background job to download and transcribe a cooking video.

    Returns the job ID immediately; the client should poll
    GET /recipes/import-status/{job_id} for the result.
    """
    if queue.pool is None:
        raise HTTPException(status_code=503, detail="Queue service unavailable")

    job = await queue.pool.enqueue_job(
        "transcribe_video_task",
        body.url,
        body.language,
    )

    if job is None:
        raise HTTPException(status_code=500, detail="Failed to enqueue transcription job")

    return VideoImportResponse(job_id=job.job_id)


@router.get("/recipes/import-status/{job_id}", response_model=VideoImportStatus)
async def get_import_status(
    job_id: str,
    current_user: Annotated[dict, Depends(get_current_user)],
) -> VideoImportStatus:
    """Poll the status of a video transcription job.

    Possible status values:
    - ``pending``  — job is queued or running
    - ``done``     — recipe_data contains the extracted recipe
    - ``error``    — error_message contains the failure reason
    """
    if queue.pool is None:
        raise HTTPException(status_code=503, detail="Queue service unavailable")

    job = Job(job_id, queue.pool)
    status = await job.status()

    if status == JobStatus.not_found:
        return VideoImportStatus(status="error", error_message="Job not found or expired")

    if status in (JobStatus.deferred, JobStatus.queued, JobStatus.in_progress):
        return VideoImportStatus(status="pending")

    if status == JobStatus.complete:
        try:
            result = await job.result(timeout=0.5)
            return VideoImportStatus(status="done", recipe_data=result)
        except Exception as exc:
            return VideoImportStatus(status="error", error_message=str(exc))

    return VideoImportStatus(status="error", error_message="Unknown job state")
