#!/bin/bash

#-----------------------------------#
#    Install Realtek Bluetooth      #
#  + Wi-Fi firmware for dArkOS      #
#            By Jason               #
#-----------------------------------#

if [ "$(id -u)" -ne 0 ]; then
    exec sudo -E "$0" "$@"
fi

DEB_PATH=$(find / -name "firmware-realtek_20250410-2_all.deb" 2>/dev/null | head -1)
if [ -z "$DEB_PATH" ]; then
    echo "Error: firmware-realtek_20250410-2_all.deb not found" > /dev/tty1
    exit 1
fi

if ! sudo dpkg -i "$DEB_PATH" 2>&1; then
    echo "Error: dpkg installation failed" > /dev/tty1
    exit 1
fi

# Reload modules
echo "Reloading Realtek kernel modules..." > /dev/tty1
sleep 2

MODULES=$(lsmod | awk '{print $1}' | grep -E '^rtl|^bt|^btrtl|^btusb|^btbcm|^btintel|^rtk|^rtw')

for mod in $(echo "$MODULES" | tac); do
    modprobe -r "$mod" 2>/dev/null || true
done

sleep 2

for mod in $MODULES; do
    modprobe "$mod" 2>/dev/null || true
done

if lsmod | grep -q -E '^rtl|^btrtl'; then
    echo "Kernel modules reloaded." > /dev/tty1
else
    echo "Warning: Some modules may not have reloaded" > /dev/tty1
fi
sleep 2
echo "" > /dev/tty1

echo "Firmware installation completed." > /dev/tty1
echo "System will power off now..." > /dev/tty1
sleep 2

shutdown now
