#!/bin/sh
export VM_DIRECTORY=`ls ~/Parallels | grep vcpkg-osx`
export SSH_KEY="$HOME/Parallels/$VM_DIRECTORY/id_guest"
export SSH_PUBLIC_KEY="$SSH_KEY.pub"
ssh-keygen -P '' -f "$SSH_KEY"
if [ `uname -m` = 'arm64' ]; then
# on arm64, prlctl does not know the IP address, but luckily for us DNS works
export SSH_COOKIE=vcpkg@vcpkgs-Virtual-Machine.local
else
# on amd64, DNS does not work, but luckily for us prlctl does know the IP
export GUEST_IP=`prlctl list --full | sed -nr 's/^.*running *([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*/\1/p'`
export SSH_COOKIE=vcpkg@$GUEST_IP
fi
echo Type 'vcpkg' and press enter
ssh-copy-id -i "$SSH_PUBLIC_KEY" $SSH_COOKIE
echo Keys deployed
ssh $SSH_COOKIE -i "$SSH_KEY" echo hello from \`hostname\`
scp -i "$SSH_KEY" ./clt.dmg $SSH_COOKIE:/Users/vcpkg/clt.dmg
scp -i "$SSH_KEY" ./setup-box.sh $SSH_COOKIE:/Users/vcpkg/setup-box.sh
ssh $SSH_COOKIE -i "$SSH_KEY" chmod +x /Users/vcpkg/setup-box.sh
ssh $SSH_COOKIE -i "$SSH_KEY" /Users/vcpkg/setup-box.sh
