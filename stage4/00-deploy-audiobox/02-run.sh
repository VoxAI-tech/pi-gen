#!/bin/bash -e

# Check for Tailscale Auth Key Environment Variable (set in pi-gen/config or exported)
if [ -z "${TAILSCALE_AUTH_KEY}" ]; then
    echo "Error: TAILSCALE_AUTH_KEY environment variable not set." >&2
    echo "Provide it when running the build script (e.g., export TAILSCALE_AUTH_KEY=...)" >&2
    exit 1
fi
echo "Using provided Tailscale Auth Key."

# Run within chroot
on_chroot << EOF
echo "Enabling systemd services..."
systemctl enable first-boot.service
systemctl enable polling-client.service
systemctl enable audiobox-audio.service
systemctl enable update-check.timer
systemctl enable tailscaled.service
systemctl enable rauc.service # Assuming rauc package installed this or you copied a unit

echo "Attempting Tailscale pre-authentication..."
# Use the injected auth key. Set initial hostname. Accept default routes=false
tailscale up --authkey="${TAILSCALE_AUTH_KEY}" --hostname="audiobox-new" --accept-routes=false --timeout=30s # Add timeout
ts_exit_code=$?
if [ $ts_exit_code -ne 0 ]; then
    echo "Warning: Tailscale pre-authentication command failed with exit code $ts_exit_code. Check network or auth key." >&2
    # Continue build, but flag potential issue
else
    echo "Tailscale pre-authentication attempted."
fi
# Stop tailscaled, it will start on device boot
systemctl stop tailscaled || true # Ignore error if already stopped
EOF

# Optional: Clean up Tailscale state if needed before image finalization
# echo "Cleaning up Tailscale state file..."
# rm -f "${ROOTFS_DIR}/var/lib/tailscale/tailscaled.state" 