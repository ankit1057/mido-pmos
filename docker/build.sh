#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build.sh — Build postmarketOS image variants for mido (qcom-msm8953)
#
# Usage:
#   ./build.sh <variant>
#
# Variants:
#   phosh            — Phosh (standard)
#   phosh_light      — Phosh minimal (no recommended extras)
#   phosh_balanced   — Phosh with common extras
#   sxmo             — Sxmo (Sway-based, ultralight)
#   xfce4            — XFCE4 desktop
#   lomiri_light     — Lomiri (Ubuntu Touch UI, minimal)
#   lomiri_balanced  — Lomiri with extras
#   super            — All-in-one (Phosh + XFCE4 + Sxmo + Lomiri)
#   dev              — Developer image (VSCodium, Flutter, Frappe deps, Podman)
#
# The script runs inside the 'pmos' Docker container. Start it first:
#   docker compose up -d
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail
VARIANT="${1:-phosh}"
CONTAINER="pmos"
OUTPUT_DIR="$(cd "$(dirname "$0")" && pwd)/../images"
mkdir -p "$OUTPUT_DIR"

# ── Package sets per variant ─────────────────────────────────────────────────
declare -A PKGS
PKGS[phosh]="postmarketos-ui-phosh"
PKGS[phosh_light]="postmarketos-ui-phosh"
PKGS[phosh_balanced]="postmarketos-ui-phosh,foot,nautilus,evince,mpv"
PKGS[sxmo]="postmarketos-ui-sxmo-de-sway"
PKGS[xfce4]="postmarketos-ui-xfce4"
PKGS[lomiri_light]="postmarketos-ui-lomiri"
PKGS[lomiri_balanced]="postmarketos-ui-lomiri,morph-browser,messaging-app"
PKGS[super]="postmarketos-ui-phosh,postmarketos-ui-sxmo-de-sway,postmarketos-ui-xfce4,postmarketos-ui-lomiri"
PKGS[dev]="postmarketos-ui-phosh,vscodium,flutter,openjdk17,python3,py3-pip,nodejs,npm,yarn,mariadb,redis,podman"

if [[ -z "${PKGS[$VARIANT]+_}" ]]; then
  echo "ERROR: Unknown variant '$VARIANT'. Valid: ${!PKGS[*]}"
  exit 1
fi

IMG_NAME="${VARIANT}_sparse.img"

echo "═══════════════════════════════════════════════"
echo "  Building variant : $VARIANT"
echo "  Packages         : ${PKGS[$VARIANT]}"
echo "  Output           : $OUTPUT_DIR/$IMG_NAME"
echo "═══════════════════════════════════════════════"

docker exec -it "$CONTAINER" bash -lc "
  set -euo pipefail
  pmbootstrap zap -y 2>/dev/null || true
  pmbootstrap install \
    --extra-packages '${PKGS[$VARIANT]}' \
    --no-fde \
    -- \
    qcom-msm8953 \
    linux-postmarketos-qcom-msm8953

  # Export images
  pmbootstrap export --odin /tmp/pmos-export
  RAW=\$(ls /tmp/pmos-export/*.img 2>/dev/null | head -n1)
  echo \"Exporting \$RAW → /home/pmos/output/${IMG_NAME}\"
  img2simg \"\$RAW\" /home/pmos/output/${IMG_NAME}
"

# Copy from container output volume mount
docker cp "${CONTAINER}:/home/pmos/output/${IMG_NAME}" "${OUTPUT_DIR}/${IMG_NAME}"
echo "✅  Built: ${OUTPUT_DIR}/${IMG_NAME}"
