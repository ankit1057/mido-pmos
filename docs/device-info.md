# Xiaomi Redmi Note 4 — Hardware Reference

## Partition Layout (eMMC)

| Partition | Size | Purpose |
|---|---|---|
| `boot` | 64 MB | Kernel / lk2nd image |
| `system` | 3 GB | Android system (unused for pmos) |
| `userdata` | ~26 GB | postmarketOS rootfs |
| `modem` | 200 MB | ADSP firmware (keep stock) |
| `persist` | 32 MB | Persistent data (keep stock) |

## SoC Details

| Property | Value |
|---|---|
| SoC | Qualcomm Snapdragon 625 (MSM8953) |
| CPU | 8× Cortex-A53 @ 2.0 GHz |
| GPU | Adreno 506 |
| RAM | 3 GB (4 GB variant also exists) |
| Storage | 32 / 64 GB eMMC |
| Display | 5.5" 1080p IPS |
| Cameras | 13 MP rear, 5 MP front |

## What Works on Mainline

| Feature | Status |
|---|---|
| Display | ✅ |
| Touch | ✅ |
| Wi-Fi | ✅ |
| Bluetooth | ✅ |
| USB networking | ✅ |
| USB OTG | ✅ |
| Audio (speaker/mic) | ⚠️ Partial |
| Camera | ❌ Not working |
| GPS | ❌ Not working |
| Modem / calls | ❌ Not working |
| Sensors (accel, gyro) | ✅ |
| Vibration | ✅ |
| Podman / Docker | ✅ (mainline kernel cgroups v2) |

## Key pmaports Reference

- **Device package:** `device-qcom-msm8953` (generic, community-maintained)
- **Kernel package:** `linux-postmarketos-qcom-msm8953`
- **pmaports tree:** https://gitlab.com/postmarketOS/pmaports/-/tree/master/device/community/device-qcom-msm8953

## USB Networking

After boot the device creates a USB RNDIS interface at `172.16.42.1`.

```bash
# Verify connection
ping 172.16.42.1

# SSH in
ssh pmos@172.16.42.1          # password: pmos1234
```
