#!/usr/bin/env zsh

set -e  # Exit on any error

# Find the .pvmp file
PVMP_FILE=$(find ~/Parallels -name "*.pvmp" -type f | head -1)
if [[ -z "$PVMP_FILE" ]]; then
    echo "Error: No .pvmp file found in ~/Parallels"
    exit 1
fi

echo "Found PVMP file: $PVMP_FILE"

# Attach the PVMP file
echo "Registering PVMP file..."
/usr/local/bin/prlctl register "$PVMP_FILE"

VM_NAME=$(/usr/local/bin/prlctl list --all --output name --no-header | head -1)

if [[ -z "$VM_NAME" ]]; then
    echo "Error: Failed to register PVMP file or extract VM ID"
    exit 1
fi

echo "VM registered with ID: $VM_NAME"

# Unpack the VM
echo "Unpacking VM..."
/usr/local/bin/prlctl unpack "$VM_NAME"

# Configure startup and shutdown settings
echo "Configuring VM startup and shutdown settings..."
/usr/local/bin/prlctl set "$VM_NAME" --startup-view headless
/usr/local/bin/prlctl set "$VM_NAME" --autostart start-host
/usr/local/bin/prlctl set "$VM_NAME" --autostop shutdown
/usr/local/bin/prlctl set "$VM_NAME" --on-shutdown close
/usr/local/bin/prlctl set "$VM_NAME" --on-window-close keep-running

echo "VM startup and shutdown settings configured successfully"

# Display current VM configuration for verification
echo "Current VM configuration:"
/usr/local/bin/prlctl list "$VM_NAME" --info | grep -E "(Autostart|Autostop|Startup view|On shutdown|On window close)"

echo "Parallels VM setup completed successfully!"
echo "VM ID: $VM_NAME"

