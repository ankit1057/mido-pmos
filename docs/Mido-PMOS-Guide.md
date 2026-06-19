# Xiaomi Redmi Note 4 (mido) postmarketOS Project

This guide documents the build and deployment of postmarketOS (mainline kernel) on the Xiaomi Redmi Note 4 (mido).

## Project Overview

- **Device:** Xiaomi Redmi Note 4 (mido)
- **Kernel:** Mainline `linux-postmarketos-qcom-msm8953` (verified Docker-compatible)
- **Bootloader:** `lk2nd` (secondary bootloader)
- **User Variants Built:** Phosh, XFCE4, Sxmo, Lomiri, "Super-Image", "Tuned-Dual", "Light", and "Developer" (Dev-Ready)

## Images & Flashing

Images are located in `~/Music/pmos-flash/`. All variants use the same `lk2nd.img` bootloader.

### 0. Developer Phosh (Dev-Ready)
- **Included:** VSCodium (VS Code), Flutter + JDK, Python 3 + Pip, Node.js + NPM + Yarn, MariaDB + Redis (for Frappe), Podman.
- **Flash Command:**
  ```bash
  cd ~/Music/pmos-flash && ./flash_dev.sh
  ```

### 1. Light Phosh (Streamlined & Fast)
- **Included:** Core Phosh components only (no recommended bloat).
- **Tweaks:** Optimized memory management for 3GB RAM.
- **Flash Command:**
  ```bash
  cd ~/Music/pmos-flash && ./flash_phosh_light.sh
  ```

### 1. Light Lomiri (Streamlined & Fast)
- **Included:** Core Lomiri components only.
- **Tweaks:** Optimized memory management for 3GB RAM.
- **Flash Command:**
  ```bash
  cd ~/Music/pmos-flash && ./flash_lomiri_light.sh
  ```

### 2. Super-Image (All-in-One)
- **Included:** Phosh, XFCE4, Sxmo, Lomiri.
- **Switching:** Select the session at the login screen (TinyDM/LightDM).
- **Flash Command:**
  ```bash
  cd ~/Music/pmos-flash && ./flash_super.sh
  ```

### 1. Sxmo (Minimalist & Ultra-Light)
- **Pros:** Maximum RAM available for Docker/Podman, very fast, extremely light.
- **Cons:** Unique navigation (hardware buttons & gestures).
- **Flash Command:**
  ```bash
  cd ~/Music/pmos-flash && ./flash_sxmo.sh
  ```

### 2. Lomiri (Ubuntu Touch UI)
- **Pros:** Smooth, convergent interface, gesture-heavy.
- **Cons:** Can be resource-intensive.
- **Flash Command:** (Included in Super-Image or build individually if needed)

### 2. XFCE4 (Desktop Experience)
- **Pros:** Familiar desktop interface, customizable, relatively light.
- **Cons:** Not touch-optimized.
- **Flash Command:**
  ```bash
  cd ~/Music/pmos-flash && ./flash_xfce.sh
  ```

### 3. Phosh (Mobile Shell)
- **Pros:** Touch-optimized, modern mobile interface (GNOME-based).
- **Cons:** Heaviest of the three, highest RAM consumption.
- **Flash Command:**
  ```bash
  cd ~/Music/pmos-flash && ./flash_phosh.sh
  ```

## Post-Installation Verification

### Network Connection
After booting, connect the phone via USB. It will appear as a network interface (usually `172.16.42.1`).

```bash
ping 172.16.42.1
ssh pmos@172.16.42.1  # Password: pmos1234
```

### Docker / Podman Installation
The mainline kernel used here supports containerization. To install and run containers:

```bash
sudo apk add podman
sudo podman run --rm hello-world
```

## Troubleshooting

- **Fastboot Errors:** If you see "Failed reading from userdata", use the sparse images and the `-S 128M` flag (handled automatically by the flashing scripts).
- **No USB Network:** Unplug and replug the USB cable after the device has fully booted to the desktop.
- **SSH Timeout:** Ensure the device is awake and the screen is not locked.
