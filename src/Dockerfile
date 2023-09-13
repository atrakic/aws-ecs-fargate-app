FROM debian:11-slim AS build
RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes python3-venv gcc libpython3-dev && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip setuptools wheel

FROM build AS build-venv
COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install --disable-pip-version-check -r /requirements.txt

FROM gcr.io/distroless/python3-debian11:nonroot as final
LABEL org.opencontainers.image.description="Flask API with AWS access"
LABEL dev.atrakic.src.app="github.com/atrakic/aws-ecs-fargate-stack"

COPY --from=build-venv /venv /venv
COPY --from=busybox:1.35.0-uclibc /bin/wget /bin/wget
COPY . /app
WORKDIR /app

EXPOSE 8000

HEALTHCHECK --interval=30s \
  --timeout=5s \
  CMD ["/bin/wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8000/health"]

ENTRYPOINT ["/venv/bin/gunicorn", "-b", ":8000", "app:app"]
