# Pinned to a specific patch release rather than a floating tag. For a
# stronger pin, resolve this to a digest yourself (`docker pull
# python:3.12.7-slim && docker inspect --format='{{index .RepoDigests 0}}'
# python:3.12.7-slim`) and use `FROM python:3.12.7-slim@sha256:...` — no
# digest is hardcoded here since it wasn't verified in this environment.
FROM python:3.12.7-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .
COPY sample_export.json .

# Run as a non-root, unprivileged user rather than the image's default root.
RUN useradd --system --create-home --uid 10001 --shell /usr/sbin/nologin appuser \
    && chown -R appuser:appuser /app
USER appuser

# NEBIUS_API_KEY must be supplied at run time (env var / Nebius Serverless
# Jobs secret), never baked into the image. See README.md.
ENTRYPOINT ["python", "main.py"]
CMD ["--help"]
