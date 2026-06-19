# images/

This directory is tracked by **Git LFS** and holds the pre-built sparse images for flashing.

## Available Images

| File | Size | Variant |
|---|---|---|
| `lk2nd.img` | ~344 KB | Secondary bootloader (required) |
| `pmos_sparse.img` | ~1.9 GB | Phosh (standard) |
| `phosh_light_sparse.img` | ~1.1 GB | Phosh minimal |
| `phosh_balanced_sparse.img` | ~1.9 GB | Phosh + extras |
| `phosh_dev_sparse.img` | ~4.7 GB | Developer (VSCodium, Flutter, Frappe) |
| `sxmo_sparse.img` | ~1.1 GB | Sxmo / Sway |
| `xfce_sparse.img` | ~2.2 GB | XFCE4 |
| `lomiri_light_sparse.img` | ~1.5 GB | Lomiri minimal |
| `lomiri_balanced_sparse.img` | ~2.5 GB | Lomiri + extras |
| `super_sparse.img` | ~3.6 GB | All-in-one |
| `tuned_sparse.img` | ~3.2 GB | Tuned dual-UI |

## How to Download

```bash
# After cloning, pull LFS objects:
git lfs pull
```

> **Note:** Images will be added progressively as GitHub LFS quota allows.  
> Alternatively, build your own image using the Docker environment in `../docker/`.

## Build Your Own

```bash
cd ../docker
docker compose up -d
./build.sh phosh        # or: sxmo | xfce4 | super | dev | ...
```
