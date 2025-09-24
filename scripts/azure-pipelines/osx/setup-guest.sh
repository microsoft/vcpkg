#!/bin/sh
export VM_DIRECTORY=`ls ~/Parallels | grep vcpkg-osx`
export SSH_KEY="$HOME/Parallels/$VM_DIRECTORY/id_guest"
export SSH_PUBLIC_KEY="$SSH_KEY.pub"
ssh-keygen -P '' -f "$SSH_KEY"
export SSH_COOKIE=vcpkg@vcpkgs-Virtual-Machine.local
echo Type 'vcpkg' and press enter
ssh-copy-id -i "$SSH_PUBLIC_KEY" $SSH_COOKIE
echo Keys deployed
ssh $SSH_COOKIE -i "$SSH_KEY" echo hello from \`hostname\`
scp -i "$SSH_KEY" ./clt.dmg $SSH_COOKIE:/Users/vcpkg/clt.dmg
scp -i "$SSH_KEY" ./setup-box.sh $SSH_COOKIE:/Users/vcpkg/setup-box.sh
ssh $SSH_COOKIE -i "$SSH_KEY" chmod +x /Users/vcpkg/setup-box.sh
ssh $SSH_COOKIE -i "$SSH_KEY" /Users/vcpkg/setup-box.sh
