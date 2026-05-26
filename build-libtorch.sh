#!/usr/bin/env bash
# Build libtorch-212 (and its deps) using the same cuda13.2-ubuntu24 container
# as ifaceengine, which ships gcc-13 — compatible with nvcc 13.2.
#
# Usage: ./build-libtorch.sh [--install | --shell]
#
#   --install  Run vcpkg install (default)
#   --shell    Open an interactive bash shell inside the container
set -euo pipefail

VCPKG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="833918616025.dkr.ecr.ap-southeast-2.amazonaws.com"
IMAGE="${REGISTRY}/ifaceengine-compile:cuda13.2-ubuntu24-latest"

MODE="install"

usage() {
    cat <<EOF
Usage: $0 [--install | --shell]

  --install  Run vcpkg install for libtorch-212[cuda,dist,...] (default)
  --shell    Open an interactive bash shell inside the container

Set AWS_PROFILE if you need a non-default AWS SSO profile for ECR login.
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --install) MODE="install"; shift ;;
        --shell)   MODE="shell";   shift ;;
        -h|--help) usage ;;
        *) echo "error: unknown option '$1'"; usage ;;
    esac
done

# ECR login (mirrors ifaceengine/scripts/ecr_login.sh)
ecr_login() {
    local aws_args=()
    [[ -n "${AWS_PROFILE:-}" ]] && aws_args+=(--profile "${AWS_PROFILE}")

    if ! aws "${aws_args[@]}" sts get-caller-identity --output text --query Account &>/dev/null; then
        echo "AWS credentials missing or expired — running aws sso login..."
        aws "${aws_args[@]}" sso login
    fi

    if ! podman login --get-login "${REGISTRY}" &>/dev/null; then
        echo "Logging in to ECR..."
        aws "${aws_args[@]}" ecr get-login-password --region ap-southeast-2 \
            | podman login --username AWS --password-stdin "${REGISTRY}" 2>&1 | grep -v WARNING
    else
        echo "Already logged in to ${REGISTRY}"
    fi
}

if ! podman image exists "${IMAGE}"; then
    echo "Image ${IMAGE} not found locally — pulling from ECR..."
    ecr_login
    podman pull "${IMAGE}"
else
    ecr_login
fi

case "${MODE}" in
    install)
        CONTAINER_CMD=(
            bash -c "
                export CC=gcc-13 CXX=g++-13
                # Find gfortran (may be gfortran-13 on Ubuntu 24)
                if command -v gfortran-13 &>/dev/null; then
                    export FC=gfortran-13
                elif command -v gfortran &>/dev/null; then
                    export FC=gfortran
                fi
                cd '${VCPKG_ROOT}'
                ./vcpkg install 'libtorch-212[cuda,dist,gflags,glog,zstd]:x64-linux' --editable --binarysource=clear
            "
        )
        ;;
    shell)
        CONTAINER_CMD=(bash)
        ;;
esac

podman run --rm -it \
    --security-opt=label=disable \
    --device nvidia.com/gpu=all \
    --env HOME="${HOME}" \
    --env CC=gcc-13 \
    --env CXX=g++-13 \
    --env FC=gfortran-13 \
    --volume "${VCPKG_ROOT}:${VCPKG_ROOT}:z" \
    --volume "${HOME}/.aws:${HOME}/.aws:z" \
    --volume "${HOME}/.ccache:${HOME}/.ccache:z" \
    --volume "${HOME}/.cache/vcpkg:${HOME}/.cache/vcpkg:z" \
    --workdir "${VCPKG_ROOT}" \
    "${IMAGE}" \
    "${CONTAINER_CMD[@]}"
