#!/bin/bash
# Flash Phosh variant
echo "Checking for device in fastboot..."
if ! fastboot devices | grep -q "fastboot"; then
    echo "Error: Device not found in fastboot. Please reboot to bootloader."
    exit 1
fi
echo "Flashing lk2nd bootloader..."
fastboot flash boot ../images/lk2nd.img
echo "Erasing userdata..."
fastboot erase userdata
echo "Flashing Phosh rootfs (sparse)..."
fastboot -S 128M flash userdata ../images/phosh_sparse.img
echo "Rebooting..."
fastboot reboot
