#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# flash.sh — Interactive flash helper for mido postmarketOS variants
#
# Usage:
#   cd flash-scripts
#   ./flash.sh           ← shows a selection menu
#   ./flash.sh phosh     ← flash directly without menu
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_DIR="${SCRIPT_DIR}/../images"

VARIANTS=(
  "phosh           → phosh_sparse.img           (Phosh, standard)"
  "phosh_light     → phosh_light_sparse.img     (Phosh minimal, ~1.2 GB)"
  "phosh_balanced  → phosh_balanced_sparse.img  (Phosh + extras, ~2.0 GB)"
  "sxmo            → sxmo_sparse.img            (Sxmo/Sway, ultralight)"
  "xfce4           → xfce_sparse.img            (XFCE4 desktop)"
  "lomiri_light    → lomiri_light_sparse.img    (Lomiri minimal)"
  "lomiri_balanced → lomiri_balanced_sparse.img (Lomiri + extras)"
  "super           → super_sparse.img           (All-in-one, ~3.8 GB)"
  "tuned           → tuned_sparse.img           (Tuned dual UI)"
  "dev             → phosh_dev_sparse.img       (Developer image)"
)

declare -A IMG_MAP
IMG_MAP[phosh]="phosh_sparse.img"
IMG_MAP[phosh_light]="phosh_light_sparse.img"
IMG_MAP[phosh_balanced]="phosh_balanced_sparse.img"
IMG_MAP[sxmo]="sxmo_sparse.img"
IMG_MAP[xfce4]="xfce_sparse.img"
IMG_MAP[lomiri_light]="lomiri_light_sparse.img"
IMG_MAP[lomiri_balanced]="lomiri_balanced_sparse.img"
IMG_MAP[super]="super_sparse.img"
IMG_MAP[tuned]="tuned_sparse.img"
IMG_MAP[dev]="phosh_dev_sparse.img"

check_fastboot() {
  if ! fastboot devices 2>/dev/null | grep -q "fastboot"; then
    echo "❌  No device found in fastboot mode."
    echo "    → Hold Vol− + Power to reboot to bootloader."
    exit 1
  fi
  echo "✅  Device detected in fastboot."
}

flash() {
  local variant="$1"
  local img="${IMG_MAP[$variant]}"
  local img_path="${IMAGE_DIR}/${img}"

  if [[ ! -f "$img_path" ]]; then
    echo "❌  Image not found: $img_path"
    echo "    Run: git lfs pull    (to download from GitHub)"
    exit 1
  fi

  echo ""
  echo "══════════════════════════════════════════"
  echo "  Variant : $variant"
  echo "  Image   : $img"
  echo "  Size    : $(du -sh "$img_path" | cut -f1)"
  echo "══════════════════════════════════════════"
  echo ""
  read -r -p "Continue? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

  check_fastboot

  echo "⚡  Flashing lk2nd.img → boot partition..."
  fastboot flash boot "${IMAGE_DIR}/lk2nd.img"

  echo "🧹  Erasing userdata..."
  fastboot erase userdata

  echo "📲  Flashing $img → userdata (sparse, 128MB chunks)..."
  fastboot -S 128M flash userdata "$img_path"

  echo "🔄  Rebooting..."
  fastboot reboot

  echo "✅  Done! Device is rebooting into postmarketOS."
  echo "    Wait ~60s then: ssh pmos@172.16.42.1"
}

# ── Main ─────────────────────────────────────────────────────────────────────
if [[ $# -ge 1 ]] && [[ -n "${IMG_MAP[$1]+_}" ]]; then
  flash "$1"
  exit 0
fi

echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│        postmarketOS Flash Tool — Xiaomi Redmi Note 4        │"
echo "└─────────────────────────────────────────────────────────────┘"
echo ""
echo "Select a variant to flash:"
echo ""
for i in "${!VARIANTS[@]}"; do
  echo "  $((i+1)). ${VARIANTS[$i]}"
done
echo ""
read -r -p "Enter number [1-${#VARIANTS[@]}]: " choice

# Convert choice number to variant key
VARIANT_KEYS=(phosh phosh_light phosh_balanced sxmo xfce4 lomiri_light lomiri_balanced super tuned dev)
idx=$((choice - 1))

if [[ $idx -lt 0 || $idx -ge ${#VARIANT_KEYS[@]} ]]; then
  echo "❌  Invalid selection."
  exit 1
fi

flash "${VARIANT_KEYS[$idx]}"
