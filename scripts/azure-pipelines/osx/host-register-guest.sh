#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <token>" >&2
    exit 1
fi

HOST_NAME=$(hostname) || {
    echo "Failed to determine the host name" >&2
    exit 1
}
HOST_NAME=${HOST_NAME%%.*}
HOST_NAME=$(printf '%s' "$HOST_NAME" | tr '[:lower:]' '[:upper:]')
case "$HOST_NAME" in
    VCPKG-M4-[0-9][0-9][0-9]) ;;
    *)
        echo "Host name '$HOST_NAME' does not match required format 'VCPKG-M4-NNN'" >&2
        exit 1
        ;;
esac

export AGENT=$HOST_NAME
echo "THIS IS AGENT: $AGENT"
export POOL=`echo "$HOME"/vcpkg-osx-*-arm64/ | sed -En 's/.+\/vcpkg-osx-([0-9]{4}-[0-9]{2}-[0-9]{2})-arm64\/$/PrOsx-\1-arm64/p'`
case "$POOL" in
    PrOsx-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-arm64) ;;
    *)
        echo "Failed to determine exactly one agent pool from ~/vcpkg-osx-*-arm64" >&2
        exit 1
        ;;
esac
# on arm64, DNS works
export SSH_COOKIE=builduser@buildusers-Virtual-Machine.local
mkdir -p "$HOME/.ssh"
touch "$HOME/.ssh/known_hosts"
ssh-keygen -R buildusers-Virtual-Machine.local -f "$HOME/.ssh/known_hosts"
echo "POOL: $POOL"
echo "SSH_COOKIE: $SSH_COOKIE"
ssh -o "StrictHostKeyChecking=no" -i "$HOME"/vcpkg-osx-*-arm64/id_guest "$SSH_COOKIE" "\$HOME/myagent/config.sh --unattended --url https://dev.azure.com/vcpkg --work \$HOME/Data/work --auth pat --token $1 --pool $POOL --agent $AGENT --replace --acceptTeeEula"
ssh -o "StrictHostKeyChecking=no" -i "$HOME"/vcpkg-osx-*-arm64/id_guest "$SSH_COOKIE" "sudo shutdown -h now"
