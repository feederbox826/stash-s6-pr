# syntax=docker/dockerfile:1
ARG UPSTREAM_TYPE="alpine"

# pull in builds from artifacts
FROM alpine AS puller
ARG TARGET_BRANCH \
  TARGET_REPO="stashapp/stash" \
  WORKFLOW_NAME="Build" \
  ARTIFACT_NAME="stash-linux"
WORKDIR /app
COPY app/pr-artifact.sh /app/pr-artifact.sh
RUN apk add --no-cache curl unzip jq
RUN --mount=type=secret,id=GITHUB_TOKEN \
  sh /app/pr-artifact.sh && \
  unzip stash-linux.zip && \
  chmod 755 stash-linux

# pull in prebuilt alpine/hwaccel
FROM ghcr.io/feederbox826/stash-s6:alpine AS stash
COPY --from=puller --chmod=755 /app/stash-linux /app/stash