# syntax=docker/dockerfile:1.4
# DisableDockerDetector "Used to build the container deployed to Azure Container Registry"
FROM ubuntu:jammy-20250126
ADD provision-image.sh /provision-image.sh
RUN apt-get update && \
    apt-get install --no-install-recommends -y curl gnupg ca-certificates
RUN chmod +x /provision-image.sh && /provision-image.sh
