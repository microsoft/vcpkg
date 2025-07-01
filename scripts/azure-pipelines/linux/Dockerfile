# syntax=docker/dockerfile:1.4
# DisableDockerDetector "Used to build the container deployed to Azure Container Registry"
FROM ubuntu:jammy-20250530
ADD provision-image.sh /provision-image.sh
RUN apt-get update && \
  apt-get install --no-install-recommends -y curl gnupg ca-certificates
# The BUILD_DATE argument forces cache invalidation so we get updated apt dependencies
ARG BUILD_DATE
RUN echo "Build date: ${BUILD_DATE}"
RUN chmod +x /provision-image.sh && /provision-image.sh
