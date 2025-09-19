#!/bin/sh
if [ -z "$1" ]; then
    echo "PAT missing"
    exit 1
fi
export AGENT=$(hostname | sed -nr 's/([^.]+).*/\1/p' | tr '[:lower:]' '[:upper:]')
echo "THIS IS AGENT: $AGENT"
if [ `uname -m` = 'arm64' ]; then
export POOL=`echo ~/Parallels/*/ | sed -nr 's/\/Users\/vcpkg\/Parallels\/vcpkg-osx-([0-9]{4}-[0-9]{2}-[0-9]{2})-arm64\/$/PrOsx-\1-arm64/p'`
# on arm64, DNS works
export SSH_COOKIE=vcpkg@vcpkgs-Virtual-Machine.local
else
export POOL=`echo ~/Parallels/*.pvm | sed -nr 's/\/Users\/vcpkg\/Parallels\/vcpkg-osx-([0-9]{4}-[0-9]{2}-[0-9]{2})-amd64\.pvm/PrOsx-\1/p'`
# on amd64, DNS does not work, but luckily for us prlctl does know the IP
export GUEST_IP=`prlctl list --full | sed -nr 's/^.*running *([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*/\1/p'`
export SSH_COOKIE=vcpkg@$GUEST_IP
fi
ssh $SSH_COOKIE -o "StrictHostKeyChecking=no" -i ~/Parallels/*/id_guest "~/myagent/config.sh --unattended --url https://dev.azure.com/vcpkg --work ~/Data/work --auth pat --token $1 --pool $POOL --agent $AGENT --replace --acceptTeeEula"
if [ `uname -m` = 'arm64' ]; then
  ssh $SSH_COOKIE -o "StrictHostKeyChecking=no" -i ~/Parallels/*/id_guest "sudo shutdown -h now"
fi
