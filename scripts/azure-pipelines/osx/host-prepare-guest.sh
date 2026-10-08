#!/bin/sh
set -e

export VM_DIRECTORY=`ls "$HOME" | grep vcpkg-osx-`
export SSH_KEY="$HOME/$VM_DIRECTORY/id_guest"
ssh -i "$SSH_KEY" builduser@buildusers-Virtual-Machine.local echo hello from \`hostname\`
scp -i "$SSH_KEY" "$HOME/Command_Line_Tools_26.6_Apple_silicon.dmg" builduser@buildusers-Virtual-Machine.local:clt.dmg
scp -i "$SSH_KEY" ./guest-prepare.sh builduser@buildusers-Virtual-Machine.local:guest-prepare.sh
ssh -i "$SSH_KEY" builduser@buildusers-Virtual-Machine.local chmod +x guest-prepare.sh
ssh -i "$SSH_KEY" builduser@buildusers-Virtual-Machine.local ./guest-prepare.sh
