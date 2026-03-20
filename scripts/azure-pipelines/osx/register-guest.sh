#!/bin/sh
if [ -z "$1" ]; then
    echo "PAT missing"
    exit 1
fi
if [ -z "$2" ]; then
    echo "Agent number missing"
    exit 1
fi
export AGENT=CPPMAC-ARM64-$2
echo "THIS IS AGENT: $AGENT"
export POOL=`echo ~/Parallels/*/ | sed -nr 's/\/Users\/vcpkg\/Parallels\/vcpkg-osx-([0-9]{4}-[0-9]{2}-[0-9]{2})-arm64\/$/PrOsx-\1-arm64/p'`
# on arm64, DNS works
export SSH_COOKIE=vcpkg@vcpkgs-Virtual-Machine.local
echo "POOL: $POOL"
echo "SSH_COOKIE: $SSH_COOKIE"
ssh $SSH_COOKIE -o "StrictHostKeyChecking=no" -i ~/Parallels/*/id_guest "~/myagent/config.sh --unattended --url https://dev.azure.com/vcpkg --work ~/Data/work --auth pat --token $1 --pool $POOL --agent $AGENT --replace --acceptTeeEula"
ssh $SSH_COOKIE -o "StrictHostKeyChecking=no" -i ~/Parallels/*/id_guest "sudo shutdown -h now"
