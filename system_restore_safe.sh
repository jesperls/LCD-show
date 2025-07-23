#!/bin/bash

# Safe restoration script for MHS35 LCD setup
# This will restore your system to its original state

echo "Restoring system to original state..."

# Check if we have backups
if [ ! -d "./.system_backup" ]; then
    echo "No backup directory found. Cannot restore."
    exit 1
fi

# Restore boot config
if [ -f ./.system_backup/config.txt.backup ]; then
    echo "Restoring boot configuration..."
    sudo cp ./.system_backup/config.txt.backup /boot/config.txt
else
    echo "Removing MHS35 configuration from boot config..."
    sudo sed -i '/# MHS35 LCD Configuration/,/# End MHS35 LCD Configuration/d' /boot/config.txt
fi

# Remove overlay files
echo "Removing overlay files..."
if [ -f /boot/overlays/mhs35-overlay.dtb ]; then
    sudo rm -f /boot/overlays/mhs35-overlay.dtb
fi
if [ -f /boot/overlays/mhs35.dtbo ]; then
    sudo rm -f /boot/overlays/mhs35.dtbo
fi

# Remove calibration config
echo "Removing touch calibration..."
if [ -f /etc/X11/xorg.conf.d/99-calibration.conf ]; then
    sudo rm -f /etc/X11/xorg.conf.d/99-calibration.conf
fi

# Restore original calibration if backed up
if [ -f ./.system_backup/99-calibration.conf ]; then
    sudo cp ./.system_backup/99-calibration.conf /etc/X11/xorg.conf.d/
fi

# Stop and disable FBCP service
echo "Removing FBCP service..."
if systemctl is-active --quiet fbcp.service; then
    sudo systemctl stop fbcp.service
fi
if systemctl is-enabled --quiet fbcp.service; then
    sudo systemctl disable fbcp.service
fi
if [ -f /etc/systemd/system/fbcp.service ]; then
    sudo rm -f /etc/systemd/system/fbcp.service
    sudo systemctl daemon-reload
fi

# Remove FBCP binary
if [ -f /usr/local/bin/fbcp ]; then
    sudo rm -f /usr/local/bin/fbcp
fi

# Remove installation marker
if [ -f ./.have_installed ]; then
    sudo rm -f ./.have_installed
fi

# Clean up build directory
if [ -d ./rpi-fbcp ]; then
    sudo rm -rf ./rpi-fbcp
fi

echo "System restoration complete!"
echo "You may want to reboot to ensure all changes take effect."
echo ""
echo "To reboot now, run: sudo reboot"
