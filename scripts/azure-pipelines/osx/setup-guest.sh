#!/bin/sh
export VM_DIRECTORY=`ls ~/Parallels | grep vcpkg-osx`
export SSH_KEY="$HOME/Parallels/$VM_DIRECTORY/id_guest"
export SSH_PUBLIC_KEY="$SSH_KEY.pub"
ssh-keygen -P '' -f "$SSH_KEY"
echo Type 'vcpkg' and press enter
ssh-copy-id -i "$SSH_PUBLIC_KEY" vcpkg@vcpkgs-Virtual-Machine.local
echo Keys deployed
ssh vcpkg@vcpkgs-Virtual-Machine.local -i "$SSH_KEY" echo hello from \`hostname\`
scp -i "$SSH_KEY" ./clt.dmg vcpkg@vcpkgs-Virtual-Machine.local:/Users/vcpkg/clt.dmg
scp -i "$SSH_KEY" ./setup-box.sh vcpkg@vcpkgs-Virtual-Machine.local:/Users/vcpkg/setup-box.sh
ssh vcpkg@vcpkgs-Virtual-Machine.local -i "$SSH_KEY" chmod +x /Users/vcpkg/setup-box.sh
ssh vcpkg@vcpkgs-Virtual-Machine.local -i "$SSH_KEY" /Users/vcpkg/setup-box.sh
