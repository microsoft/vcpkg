# syntax=docker/dockerfile:1.4
# DisableDockerDetector "Used to build the container deployed to Azure Container Registry"
FROM ubuntu:noble-20260410
ADD provision-image.sh /provision-image.sh
# The BUILD_DATE argument forces cache invalidation so we get updated apt dependencies
ARG BUILD_DATE
RUN echo "Build date: ${BUILD_DATE}"
RUN chmod +x /provision-image.sh && /provision-image.sh
