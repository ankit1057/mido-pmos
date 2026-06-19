# 🐧 mido-pmos — postmarketOS on Xiaomi Redmi Note 4 (mido)

> Mainline Linux on the Xiaomi Redmi Note 4 / 4X (mido · Snapdragon 625 / msm8953)

[![Device](https://img.shields.io/badge/device-Xiaomi%20Redmi%20Note%204-blue)](https://wiki.postmarketos.org/wiki/Xiaomi_Redmi_Note_4_(xiaomi-mido))
[![Kernel](https://img.shields.io/badge/kernel-mainline%20qcom--msm8953-green)](https://gitlab.com/postmarketOS/pmaports/-/tree/master/device/community/linux-postmarketos-qcom-msm8953)
[![License](https://img.shields.io/badge/license-MIT-orange)](LICENSE)

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Repository Layout](#repository-layout)
- [Build with Docker](#build-with-docker)
- [Flash a Pre-built Image](#flash-a-pre-built-image)
- [Image Variants](#image-variants)
- [Post-Installation](#post-installation)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## Project Overview

This repository contains everything needed to **build, flash, and use postmarketOS** on the Xiaomi Redmi Note 4 (`mido`).

| Property | Value |
|---|---|
| **Device** | Xiaomi Redmi Note 4 / 4X (mido) |
| **SoC** | Qualcomm Snapdragon 625 (MSM8953) |
| **RAM** | 3 GB |
| **Port type** | Generic mainline (`qcom-msm8953`) |
| **Kernel** | `linux-postmarketos-qcom-msm8953` (mainline) |
| **Bootloader** | `lk2nd` (secondary Android bootloader) |
| **Container support** | ✅ Docker / Podman verified |
| **Default credentials** | user `pmos` / password `pmos1234` |

> **Why the generic port?**  
> The device-specific `device-xiaomi-mido` port is archived in pmaports as "unmaintained, for testing only". The community-maintained `qcom-msm8953` generic port targets the same SoC with the same mainline kernel + lk2nd stack — and is actively updated.

---

## Prerequisites

- **macOS or Linux** host
- [`fastboot`](https://developer.android.com/studio/releases/platform-tools) in PATH
- [`docker`](https://docs.docker.com/get-docker/) (for building)
- [`gh` CLI](https://cli.github.com/) (optional, for downloading releases)
- **Unlocked bootloader** on the device (standard Xiaomi method)

---

## 📦 Downloading Pre-built Images from Releases

Since postmarketOS images are large binary files (1.2 GB to 4.7 GB), they are **not** stored in this Git repository. Instead, they are published directly to [GitHub Releases](https://github.com/ankit1057/mido-pmos/releases).

1. Go to the [Releases page](https://github.com/ankit1057/mido-pmos/releases) and download `lk2nd.img` along with the `.img` (or split parts) for your chosen variant.
2. Save these files to the `images/` directory in the repository.

### Reassembling Split Images (> 2GB)
GitHub Releases limits individual asset uploads to 2 GB. Image variants larger than 1.9 GB (e.g. `lomiri_balanced`, `super`, `dev`) are automatically split into ~1.9 GB chunks during the build (e.g., `super_sparse.img.partaa`, `super_sparse.img.partab`).

Before flashing, you must reassemble these parts into a single sparse image file:

```bash
# Go to the directory where you saved the downloaded parts
cd images/

# Reassemble the split parts (for example, for the 'super' variant)
cat super_sparse.img.part* > super_sparse.img

# Clean up the parts if desired
rm super_sparse.img.part*
```

Once reassembled, you can proceed with standard flashing instructions.

---

## Repository Layout

```
mido-pmos/
├── README.md               ← you are here
├── LICENSE
├── docs/
│   ├── Mido-PMOS-Guide.md  ← full build + flash guide
│   ├── device-info.md      ← hardware notes / partition table
│   └── post-install.md     ← SSH, containers, Frappe setup
├── docker/
│   ├── Dockerfile          ← pmbootstrap build environment
│   ├── docker-compose.yml  ← convenience compose file
│   └── build.sh            ← one-shot build script (all variants)
├── flash-scripts/
│   ├── flash.sh            ← universal interactive flash helper
│   ├── flash_phosh.sh
│   ├── flash_phosh_light.sh
│   ├── flash_phosh_balanced.sh
│   ├── flash_sxmo.sh
│   ├── flash_xfce.sh
│   ├── flash_super.sh      ← all-in-one (Phosh+XFCE4+Sxmo+Lomiri)
│   ├── flash_lomiri_light.sh
│   ├── flash_lomiri_balanced.sh
│   ├── flash_tuned.sh
│   └── flash_dev.sh        ← dev image (VSCodium, Flutter, Frappe deps)
└── images/                 ← Local build output / download target (Git ignored)
    ├── lk2nd.img           ← secondary bootloader (flash to boot partition)
    └── (image files here)  ← put built or downloaded sparse images here
```

---

## Build with Docker

The `docker/` directory contains a self-contained pmbootstrap build environment.

```bash
# 1. Pull the builder image and start the container
cd docker
docker compose up -d

# 2. Build a specific variant (e.g. phosh)
./build.sh phosh

# Available variants: phosh | phosh_light | sxmo | xfce4 | super | lomiri_light | dev
./build.sh super
```

The build script will:
1. Run `pmbootstrap install` inside the container
2. Convert the raw image to sparse format via `img2simg`
3. Copy the `.img` file to `images/`

---

## 🛠️ Automated Build with GitHub Actions

The repository includes a fully-automated GitHub Actions pipeline in `.github/workflows/build.yml` which handles builds and releases.

### Triggering a Custom Build:
1. Go to the **Actions** tab of your repository on GitHub.
2. Select the **Build & Release postmarketOS Image** workflow in the left sidebar.
3. Click the **Run workflow** dropdown on the right.
4. Select the **Image variant** flavor you want to build (e.g. `phosh_light`, `super`, `dev`, etc.).
5. Select the **postmarketOS release channel** (`edge`, `v25.12`, or `v24.12`).
6. Click **Run workflow**.

The workflow will:
- Spin up a clean runner environment and install all dependencies.
- Compile the selected postmarketOS image variant.
- Automatically convert the output to a sparse image (`img2simg`).
- Split the sparse image into ~1.9 GB parts if the total size exceeds the 2 GB GitHub upload limit.
- Create a release tag and upload the sparse image parts and `lk2nd.img` directly to the repository's **Releases** page.

---

## Flash a Pre-built Image

> **All flash scripts must be run from the `flash-scripts/` directory** (they reference `../images/` and `../images/lk2nd.img`).

### Step 1 — Reboot to fastboot

```bash
adb reboot bootloader
# or hold Volume Down + Power while booting
```

### Step 2 — Run a flash script

```bash
cd flash-scripts
./flash.sh          # interactive: shows a menu of variants
# or directly:
./flash_sxmo.sh     # lightest
./flash_super.sh    # all-in-one (select UI at login)
./flash_dev.sh      # developer image
```

Each script performs:
1. Detects device in fastboot
2. Flashes `lk2nd.img` → `boot` partition
3. Erases `userdata`
4. Flashes the chosen sparse rootfs in 128 MB chunks
5. Reboots

---

## Image Variants

| Script | Image | Size | UI(s) | Best for |
|---|---|---|---|---|
| `flash_sxmo.sh` | `sxmo_sparse.img` | ~1.1 GB | Sxmo (Sway) | Max RAM for containers |
| `flash_phosh_light.sh` | `phosh_light_sparse.img` | ~1.2 GB | Phosh (minimal) | Daily driver, light |
| `flash_phosh.sh` | `phosh_sparse.img` | ~1.9 GB | Phosh | Daily driver |
| `flash_phosh_balanced.sh` | `phosh_balanced_sparse.img` | ~2.0 GB | Phosh | Balanced |
| `flash_lomiri_light.sh` | `lomiri_light_sparse.img` | ~1.6 GB | Lomiri (light) | Ubuntu Touch feel |
| `flash_lomiri_balanced.sh` | `lomiri_balanced_sparse.img` | ~2.7 GB | Lomiri | Ubuntu Touch feel |
| `flash_xfce.sh` | `xfce_sparse.img` | ~2.4 GB | XFCE4 | Desktop-like |
| `flash_tuned.sh` | `tuned_sparse.img` | ~3.5 GB | Phosh + Lomiri | Tuned dual |
| `flash_super.sh` | `super_sparse.img` | ~3.8 GB | Phosh+XFCE4+Sxmo+Lomiri | All-in-one switcher |
| `flash_dev.sh` | `phosh_dev_sparse.img` | ~4.7 GB | Phosh + Dev tools | Development |

---

## Post-Installation

Once booted, the device appears as a USB network adapter:

```bash
ping 172.16.42.1
ssh pmos@172.16.42.1     # password: pmos1234
```

### Install containers (Podman recommended)

```bash
sudo apk update
sudo apk add podman
sudo podman run --rm hello-world
```

### Or Docker

```bash
sudo apk add docker
sudo rc-update add docker default
sudo service docker start
sudo docker run --rm hello-world
```

See [`docs/post-install.md`](docs/post-install.md) for Frappe/Bench and Flutter dev setup.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `FAILED (remote: 'Failed to read userdata partition')` | Use sparse images; scripts already pass `-S 128M` |
| No USB network after boot | Replug USB after device fully boots; disable lock screen |
| SSH timeout | Keep screen on; `ssh -o ConnectTimeout=15` |
| Device not in fastboot | `adb reboot bootloader` or hold Vol− + Power |
| `pmbootstrap zap` error | Channel mismatch; run `pmbootstrap zap -y` before rebuilding |

---

## Contributing

PRs welcome! This is a community effort — open an issue for:
- Broken packages in a specific UI
- New variant requests
- Post-install guides for apps

---

## License

MIT — see [LICENSE](LICENSE).
