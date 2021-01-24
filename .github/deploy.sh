#!/bin/bash
#
# Deploy artifacts (e.g. dmg, deb files) built by CI to downloads.mixxx.org.

set -eu -o pipefail

[ -z "${SSH_HOST}" ] && echo "Please set the SSH_HOST env var." >&2 && exit 1
[ -z "${SSH_KEY}" ] && echo "Please set the SSH_KEY env var." >&2 && exit 1
[ -z "${SSH_PASSWORD}" ] && echo "Please set the SSH_PASSWORD env var." >&2 && exit 1
[ -z "${SSH_USER}" ] && echo "Please set the SSH_USER env var." >&2 && exit 1
[ -z "${UPLOAD_ID}" ] && echo "Please set the UPLOAD_ID env var." >&2 && exit 1
[ -z "${OS}" ] && echo "Please set the OS env var." >&2 && exit 1
[ -z "${DESTDIR}" ] && echo "Please set the DESTDIR env var." >&2 && exit 1

SSH="ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
DEST_PATH="${DESTDIR}/${GIT_BRANCH}/${OS}"
TMP_PATH="${DESTDIR}/.tmp/${UPLOAD_ID}"

echo "Deploying to $TMP_PATH, then to $DEST_PATH."

# Remove permissions for group and other users so that ssh-keygen does not
# complain about the key not being protected.
chmod go-rwx "${SSH_KEY}"

# Unlock the key by removing its password. This is easier than messing with ssh-agent.
ssh-keygen -p -P "${SSH_PASSWORD}" -N "" -f "${SSH_KEY}"

# realpath does not exist on macOS
command -v realpath >/dev/null 2>&1 || realpath() {
    [[ "$1" = /* ]] && echo "$1" || echo "${PWD}/${1#./}"
}

# sha256sum doesn't exist on Windows (Git Bash) or macOS
command -v sha256sum >/dev/null 2>&1 || sha256sum() {
    openssl dgst -sha256 "$@" | sed 's/^SHA256(\(.*\))= \(\w\+\)$/\2  \1/'
}

for FILEPATH in "$@"
do
    # Always upload to a temporary path.
    # This prevents users from downloading an incomplete file from the server which has not yet finished deploying.
    echo "Deploying artifact: ${FILEPATH}"
    FILENAME="$(basename "${FILEPATH}")"
    FILENAME_HASH="${FILENAME}.sha256sum"
    FILEPATH_HASH="${FILEPATH}.sha256sum"

    # There should be no path components in the shasum file, so we need to cd to it first.
    pushd "$(dirname "$(realpath "${FILEPATH}")")"
    sha256sum "${FILENAME}" > "${FILENAME_HASH}"
    popd

    FILEEXT="${FILENAME##*.}"

    rsync -e "${SSH}" --rsync-path="mkdir -p ${TMP_PATH} && rsync" -r --delete-after "${FILEPATH}" "${FILEPATH_HASH}" "${SSH_USER}@${SSH_HOST}:${TMP_PATH}"

    # Move from the temporary path to the final destination.
    ${SSH} "${SSH_USER}@${SSH_HOST}" << EOF
    trap 'rm -rf "${TMP_PATH}"' EXIT
    mkdir -p "${DEST_PATH}" &&
    mv "${TMP_PATH}/${FILENAME}" "${TMP_PATH}/${FILENAME_HASH}" "${DEST_PATH}"
EOF
done
