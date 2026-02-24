"""Development-only CORS middleware that allows any localhost origin.

Ensures Flutter web (and other dev servers) on any localhost port can call the API
without CORS blocking the preflight OPTIONS request.
"""

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response


class CorsDevMiddleware(BaseHTTPMiddleware):
    """For local dev: respond to OPTIONS preflight with 200 and CORS headers for any localhost origin."""

    ALLOWED_ORIGIN_PREFIXES = ("http://localhost:", "http://127.0.0.1:")
    ALLOW_METHODS = "GET, POST, PUT, PATCH, DELETE, OPTIONS"
    ALLOW_HEADERS = "Authorization, Content-Type, Accept, Origin"

    async def dispatch(self, request: Request, call_next):
        origin = request.headers.get("origin", "")
        is_localhost = origin.startswith(self.ALLOWED_ORIGIN_PREFIXES)

        if request.method == "OPTIONS" and is_localhost:
            return Response(
                status_code=200,
                headers={
                    "Access-Control-Allow-Origin": origin,
                    "Access-Control-Allow-Credentials": "true",
                    "Access-Control-Allow-Methods": self.ALLOW_METHODS,
                    "Access-Control-Allow-Headers": self.ALLOW_HEADERS,
                    "Access-Control-Max-Age": "86400",
                },
            )

        response = await call_next(request)

        # For localhost origins, always echo back the request origin so credentials
        # (e.g. Authorization header) work. Browsers reject "*" when credentials are sent.
        if is_localhost and origin:
            response.headers["Access-Control-Allow-Origin"] = origin
            if "Access-Control-Allow-Credentials" not in response.headers:
                response.headers["Access-Control-Allow-Credentials"] = "true"

        return response
