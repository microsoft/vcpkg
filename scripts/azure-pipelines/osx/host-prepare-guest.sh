#!/bin/sh
set -e

export VM_DIRECTORY=`ls "$HOME" | grep vcpkg-osx-`
export SSH_KEY="$HOME/$VM_DIRECTORY/id_guest"
export SSH_PUBLIC_KEY="$SSH_KEY.pub"
ssh-keygen -P '' -f "$SSH_KEY"
echo Type 'builduser' and press enter
ssh-copy-id -i "$SSH_PUBLIC_KEY" builduser@buildusers-Virtual-Machine.local
echo Keys deployed
ssh builduser@buildusers-Virtual-Machine.local -i "$SSH_KEY" echo hello from \`hostname\`
scp -i "$SSH_KEY" "$HOME/Command_Line_Tools_26.6_Apple_silicon.dmg" builduser@buildusers-Virtual-Machine.local:clt.dmg
scp -i "$SSH_KEY" ./guest-prepare.sh builduser@buildusers-Virtual-Machine.local:guest-prepare.sh
ssh builduser@buildusers-Virtual-Machine.local -i "$SSH_KEY" chmod +x guest-prepare.sh
ssh builduser@buildusers-Virtual-Machine.local -i "$SSH_KEY" ./guest-prepare.sh
