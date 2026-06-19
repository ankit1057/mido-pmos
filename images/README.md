# images/

This directory holds the built or downloaded sparse images for flashing. **These binary files are ignored by Git.**

## How to Get the Images

You can either:
1. **Download them:** Get pre-built images from [GitHub Releases](https://github.com/ankit1057/mido-pmos/releases) and place them in this folder.
2. **Build them locally:** Use the Docker environment in `../docker/`.

## Available Image Mappings

| Variant | Image Name | Size | Description |
|---|---|---|---|
| `lk2nd` | `lk2nd.img` | ~352 KB | Secondary Android bootloader (required for boot) |
| `phosh` | `phosh_sparse.img` | ~1.9 GB | Phosh (standard) |
| `phosh_light` | `phosh_light_sparse.img` | ~1.2 GB | Phosh minimal (light daily driver) |
| `phosh_balanced` | `phosh_balanced_sparse.img` | ~2.0 GB | Phosh with common extras |
| `sxmo` | `sxmo_sparse.img` | ~1.1 GB | Sxmo / Sway (ultralight, minimal RAM usage) |
| `xfce4` | `xfce_sparse.img` | ~2.4 GB | XFCE4 desktop UI |
| `lomiri_light` | `lomiri_light_sparse.img` | ~1.6 GB | Lomiri UI minimal |
| `lomiri_balanced` | `lomiri_balanced_sparse.img` | ~2.7 GB | Lomiri UI with common extras |
| `tuned` | `tuned_sparse.img` | ~3.5 GB | Tuned dual-UI |
| `super` | `super_sparse.img` | ~3.8 GB | All-in-one Phosh + XFCE4 + Sxmo + Lomiri switcher |
| `dev` | `phosh_dev_sparse.img` | ~4.7 GB | Developer image (VSCodium, openjdk, podman, etc.) |

## Build Locally

To build any flavor locally:
```bash
cd ../docker
./build.sh <variant> <channel>
# Example: Build phosh_light on edge channel
./build.sh phosh_light edge
```
The build script will compile the image inside Docker, convert it to sparse format, and copy it directly to this `images/` directory.
