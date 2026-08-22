#!/bin/sh
set -e

VM_DIRECTORY=`ls "$HOME" | grep vcpkg-osx-`
SSH_KEY="$HOME/$VM_DIRECTORY/id_guest"
SSH_PUBLIC_KEY="$SSH_KEY.pub"

mkdir -p "$HOME/.ssh"
touch "$HOME/.ssh/known_hosts"
ssh-keygen -R buildusers-Virtual-Machine.local -f "$HOME/.ssh/known_hosts"
ssh-keygen -P '' -f "$SSH_KEY"
echo "Enter the guest builduser password to install the SSH key"
ssh-copy-id -i "$SSH_PUBLIC_KEY" builduser@buildusers-Virtual-Machine.local
echo "Enter the guest builduser password to enable passwordless sudo"
ssh -t -i "$SSH_KEY" builduser@buildusers-Virtual-Machine.local \
    "printf 'builduser\tALL=(ALL)\tNOPASSWD:\tALL\n' | sudo tee /etc/sudoers.d/builduser >/dev/null && sudo chmod 0440 /etc/sudoers.d/builduser"
scp -i "$SSH_KEY" "$HOME/Xcode_26.6_Apple_silicon.xip" builduser@buildusers-Virtual-Machine.local:Xcode.xip
ssh -i "$SSH_KEY" builduser@buildusers-Virtual-Machine.local \
    "sudo mdutil -ad && xip --expand Xcode.xip && sudo mv Xcode.app /Applications/Xcode.app && rm Xcode.xip"