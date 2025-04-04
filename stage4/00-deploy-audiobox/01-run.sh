#!/bin/bash -e
# Run within chroot
on_chroot << EOF
echo "Installing audio_client Python dependencies..."
cd /opt/audiobox/audio_client || exit 1 # Exit if cd fails
# Ensure uv is available in the chroot PATH (installed in stage 2)
if ! command -v uv &> /dev/null; then
    echo "Error: uv command not found in chroot. Was it installed in Stage 2?" >&2
    exit 1
fi
# Create virtual environment
echo "Creating venv with uv..."
uv venv .venv -p python3
# Install dependencies (including the app itself in editable mode)
# Ensure network access works from within the chroot if needed
echo "Installing dependencies with uv..."
uv pip install -p .venv/bin/python -e .
# Optional: Set ownership if needed for non-root user later
# chown -R 1000:1000 /opt/audiobox/audio_client
echo "Python dependencies installed."
EOF 