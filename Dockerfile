FROM ghcr.io/astral-sh/uv:0.13.5 AS uv
FROM python:3.13.17-slim-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

COPY --from=uv /uv /uvx /bin/
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-dev --no-install-project --no-cache

# Copy only the API package; MLflow artifacts stay outside the image and are mounted at runtime.
COPY webservice_locally /app/webservice_locally

EXPOSE 9696

CMD ["uv", "run", "--no-sync", "uvicorn", "webservice_locally.app:app", "--host", "0.0.0.0", "--port", "9696"]
