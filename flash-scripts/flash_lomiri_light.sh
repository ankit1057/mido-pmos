#!/bin/bash
# Flash Streamlined Lomiri Variant
echo "Checking for device in fastboot..."
if ! fastboot devices | grep -q "fastboot"; then
    echo "Error: Device not found in fastboot. Please reboot to bootloader."
    exit 1
fi
echo "Flashing lk2nd bootloader..."
fastboot flash boot ../images/lk2nd.img
echo "Erasing userdata..."
fastboot erase userdata
echo "Flashing Light Lomiri rootfs (sparse)..."
fastboot -S 128M flash userdata ../images/lomiri_light_sparse.img
echo "Rebooting..."
fastboot reboot
