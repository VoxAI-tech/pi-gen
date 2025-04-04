#!/bin/bash -e
# Assumes rauc_VERSION_arm64.deb is placed in files/ directory of this stage
install -m 644 files/rauc_*.deb "${ROOTFS_DIR}/tmp/" # Copy deb into image tmp
on_chroot << EOF
echo "Installing RAUC from .deb..."
dpkg -i /tmp/rauc_*.deb || apt-get install -f -y # Install deps if needed
rm /tmp/rauc_*.deb
echo "RAUC installed."
EOF 