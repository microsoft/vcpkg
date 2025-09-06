#!/usr/bin/env zsh

vm_name=$(/usr/local/bin/prlctl list --all --output name --no-header 2>/dev/null | head -1)
if [[ -z "$vm_name" ]]; then
    echo "No VM found on the system."
    exit 0
fi

echo "Found VM: $vm_name"

# Stop the VM if it's running
echo "Stopping VM..."
/usr/local/bin/prlctl stop "$vm_name" --kill 2>/dev/null || echo "VM was already stopped or failed to stop"

# Delete the VM
echo "Deleting VM..."
/usr/local/bin/prlctl delete "$vm_name"