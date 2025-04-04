# --- AudioBox Stage 2 Tweaks ---

on_chroot << EOF
# Install uv using pip
echo "Installing uv..."
pip3 install uv --break-system-packages # Add flag if needed on newer OS

# Add Tailscale repository
echo "Adding Tailscale repository..."
# Assumes files/tailscale.list exists in this stage directory
install -m 644 files/tailscale.list "/etc/apt/sources.list.d/"
# Assumes files/tailscale-keyring.gpg exists in this stage directory
install -m 644 files/tailscale-keyring.gpg "/etc/apt/trusted.gpg.d/"

# Update package list and install tailscale (do this inside chroot)
apt-get update
apt-get install -y --no-install-recommends tailscale
EOF
# --- End AudioBox Stage 2 Tweaks --- 