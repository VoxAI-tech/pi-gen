#!/bin/bash -e

# Check project dir env var (set in pi-gen/config)
if [ -z "${AUDIOBOX_PROJECT_DIR}" ] || [ ! -d "${AUDIOBOX_PROJECT_DIR}" ]; then
    echo "Error: AUDIOBOX_PROJECT_DIR env var not set or dir not found: ${AUDIOBOX_PROJECT_DIR}" >&2
    exit 1
fi
echo "AudioBox Project Source: ${AUDIOBOX_PROJECT_DIR}"

# --- Create Directories ---
echo "Creating directories..."
install -v -o 0 -g 0 -m 700 -d "${ROOTFS_DIR}/etc/audiobox/keys"
install -v -o 0 -g 0 -m 755 -d "${ROOTFS_DIR}/opt/audiobox"
install -v -o 0 -g 0 -m 755 -d "${ROOTFS_DIR}/opt/audiobox/audio_client"
install -v -o 0 -g 0 -m 755 -d "${ROOTFS_DIR}/opt/audiobox/app-slot-0"
install -v -o 0 -g 0 -m 755 -d "${ROOTFS_DIR}/opt/audiobox/app-slot-1"
install -v -o 0 -g 0 -m 755 -d "${ROOTFS_DIR}/etc/rauc"
install -v -o 0 -g 0 -m 755 -d "${ROOTFS_DIR}/usr/lib/rauc/hooks" # Adjust if RAUC needs hooks elsewhere

# --- Copy Audio Client Code --- ## Make sure target dir /opt/audiobox/audio_client exists
echo "Copying audio_client application..."
rsync -a --delete "${AUDIOBOX_PROJECT_DIR}/audio_client/" "${ROOTFS_DIR}/opt/audiobox/audio_client/" \
    --exclude '.venv' --exclude '__pycache__' --exclude '.git' --exclude '*.pyc' \
    --exclude 'config.toml'

# --- Copy Scripts --- ## Make sure target dir /usr/local/bin exists
echo "Copying device scripts..."
install -v -o 0 -g 0 -m 755 "${AUDIOBOX_PROJECT_DIR}/scripts/first-boot.sh" "${ROOTFS_DIR}/usr/local/bin/"
install -v -o 0 -g 0 -m 755 "${AUDIOBOX_PROJECT_DIR}/scripts/polling_client.py" "${ROOTFS_DIR}/usr/local/bin/"
install -v -o 0 -g 0 -m 755 "${AUDIOBOX_PROJECT_DIR}/scripts/check_for_updates.sh" "${ROOTFS_DIR}/usr/local/bin/"
install -v -o 0 -g 0 -m 755 "${AUDIOBOX_PROJECT_DIR}/scripts/display_uuid.sh" "${ROOTFS_DIR}/usr/local/bin/"

# --- Copy RAUC Hooks --- ## Make sure target dir /usr/lib/rauc/hooks exists
echo "Copying RAUC hook scripts..."
install -v -o 0 -g 0 -m 755 "${AUDIOBOX_PROJECT_DIR}/scripts/hooks/post-install.sh" "${ROOTFS_DIR}/usr/lib/rauc/hooks/"
install -v -o 0 -g 0 -m 755 "${AUDIOBOX_PROJECT_DIR}/scripts/hooks/health-check.sh" "${ROOTFS_DIR}/usr/lib/rauc/hooks/"

# --- Copy Systemd Units --- ## Make sure target dir /etc/systemd/system exists
echo "Copying systemd units..."
install -v -o 0 -g 0 -m 644 "${AUDIOBOX_PROJECT_DIR}/systemd/"*.service "${ROOTFS_DIR}/etc/systemd/system/"
install -v -o 0 -g 0 -m 644 "${AUDIOBOX_PROJECT_DIR}/systemd/"*.timer "${ROOTFS_DIR}/etc/systemd/system/"

# --- Copy Config Files --- ## Make sure target dir /etc/rauc exists
echo "Copying configuration files..."
install -v -o 0 -g 0 -m 644 files/system.conf "${ROOTFS_DIR}/etc/rauc/"
install -v -o 0 -g 0 -m 644 "${AUDIOBOX_PROJECT_DIR}/dev_ca/rauc-public.crt" "${ROOTFS_DIR}/etc/rauc/keyring.pem"
install -v -o 0 -g 0 -m 644 "${AUDIOBOX_PROJECT_DIR}/audio_client/config.toml.example" "${ROOTFS_DIR}/etc/audiobox/"

echo "File copying complete." 