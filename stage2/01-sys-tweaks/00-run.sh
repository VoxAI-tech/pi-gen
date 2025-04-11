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

# Set timezone to UTC
echo "Etc/UTC" > "${ROOTFS_DIR}/etc/timezone"

# --- BEGIN: Configure Persistent Storage Mounts and Directories --- #

# 1. Ensure base persistent directories exist within the image filesystem
#    (Actual content will be on the separate /data partition at runtime)
mkdir -p "${ROOTFS_DIR}/data/tailscale"
chown root:root "${ROOTFS_DIR}/data/tailscale" # Set appropriate owner/group
chmod 700 "${ROOTFS_DIR}/data/tailscale"      # Set appropriate permissions

mkdir -p "${ROOTFS_DIR}/data/audiobox"
# Add chown/chmod for /data/audiobox if needed, depending on app user

# 2. Add persistent partition mounts to /etc/fstab
FSTAB_FILE="${ROOTFS_DIR}/etc/fstab"

# Ensure /data partition itself is mounted
DATA_MOUNT_ENTRY="/dev/mmcblk0p4  /data   ext4    defaults,noatime 0 2"
if ! grep -qF "${DATA_MOUNT_ENTRY}" "${FSTAB_FILE}"; then
  echo "Adding /data mount to /etc/fstab"
  echo "${DATA_MOUNT_ENTRY}" >> "${FSTAB_FILE}"
else
  echo "/data mount already exists in /etc/fstab"
fi

# Ensure Tailscale state is bind-mounted from persistent storage
TAILSCALE_BIND_MOUNT_ENTRY="/data/tailscale /var/lib/tailscale none defaults,bind 0 0"
# Ensure the mount point /var/lib/tailscale exists (package should create it, but be defensive)
mkdir -p "${ROOTFS_DIR}/var/lib/tailscale"
if ! grep -qF "${TAILSCALE_BIND_MOUNT_ENTRY}" "${FSTAB_FILE}"; then
  echo "Adding Tailscale state bind mount to /etc/fstab"
  echo "${TAILSCALE_BIND_MOUNT_ENTRY}" >> "${FSTAB_FILE}"
else
  echo "Tailscale state bind mount already exists in /etc/fstab"
fi

# --- END: Configure Persistent Storage Mounts and Directories --- #

# Disable swap
dphys-swapfile swapoff || true 