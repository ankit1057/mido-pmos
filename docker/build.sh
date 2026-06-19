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
# The script runs against the 'pmos' Docker container. Start it first:
#   docker compose up -d
#
# Validated against pmbootstrap 3.10.1 on 2025-06-19.
# Key lessons learned:
#   - Must run as 'pmos' user (not root) inside the container
#   - Password must be piped via echo (no TTY in non-interactive exec)
#   - Use `pmbootstrap export` (NOT --odin, which is Heimdall/Samsung only)
#   - `zap` has no -y flag; pipe `yes` to confirm
#   - Set UI via `pmbootstrap config ui <name>` before install
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail
VARIANT="${1:-phosh}"
CHANNEL="${2:-edge}"
CONTAINER="pmos"
PMB_USER="pmos"
PMB="python3 /home/pmos/pmbootstrap/pmbootstrap.py"

# ── Ensure Docker Daemon is running ──────────────────────────────────────────
if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not running. Attempting to start Docker Desktop..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open -g -a Docker
    echo -n "Waiting for Docker daemon to start"
    until docker info >/dev/null 2>&1; do
      echo -n "."
      sleep 2
    done
    echo " Started!"
  else
    echo "Error: Docker daemon is not running and auto-start is only supported on macOS."
    echo "Please start Docker and try again."
    exit 1
  fi
fi

# ── Ensure Builder Container is running ──────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! docker ps --filter "name=^${CONTAINER}$" --filter "status=running" --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Builder container '$CONTAINER' is not running. Starting it..."
  if docker ps -a --filter "name=^${CONTAINER}$" --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "Removing stopped '$CONTAINER' container..."
    docker rm -f "$CONTAINER" >/dev/null
  fi
  echo "Building builder image..."
  docker build -t mido-pmos-builder:latest "$SCRIPT_DIR"
  docker volume create pmos-pmbootstrap-work >/dev/null 2>&1 || true
  docker run -d --privileged --name "$CONTAINER" -it \
    --entrypoint "" \
    -v pmos-pmbootstrap-work:/home/pmos/.local/var/pmbootstrap \
    -v "$SCRIPT_DIR/output:/home/pmos/output" \
    -e TERM=xterm-256color \
    mido-pmos-builder:latest sleep infinity
fi

OUTPUT_DIR="$SCRIPT_DIR/../images"
mkdir -p "$OUTPUT_DIR"

# ── UI name for pmbootstrap config ───────────────────────────────────────────
declare -A UI_NAME
UI_NAME[phosh]="phosh"
UI_NAME[phosh_light]="phosh"
UI_NAME[phosh_balanced]="phosh"
UI_NAME[sxmo]="sxmo-de-sway"
UI_NAME[xfce4]="xfce4"
UI_NAME[lomiri_light]="lomiri"
UI_NAME[lomiri_balanced]="lomiri"
UI_NAME[super]="phosh"
UI_NAME[dev]="phosh"

# ── Extra packages ON TOP of the base UI ─────────────────────────────────────
declare -A PKGS
PKGS[phosh]="none"
PKGS[phosh_light]="none"
PKGS[phosh_balanced]="foot,nautilus,evince,mpv"
PKGS[sxmo]="none"
PKGS[xfce4]="none"
PKGS[lomiri_light]="none"
PKGS[lomiri_balanced]="morph-browser,messaging-app"
PKGS[super]="postmarketos-ui-sxmo-de-sway,postmarketos-ui-xfce4,postmarketos-ui-lomiri"
PKGS[dev]="vscodium,openjdk17,python3,py3-pip,nodejs,npm,yarn,mariadb,redis,podman"

if [[ -z "${PKGS[$VARIANT]+_}" ]]; then
  echo "ERROR: Unknown variant '$VARIANT'. Valid: ${!PKGS[*]}"
  exit 1
fi

UI="${UI_NAME[$VARIANT]}"
EXTRA="${PKGS[$VARIANT]}"
IMG_NAME="${VARIANT}_sparse.img"

echo "═══════════════════════════════════════════════"
echo "  Building variant : $VARIANT"
echo "  Channel          : $CHANNEL"
echo "  UI               : $UI"
echo "  Extra packages   : $EXTRA"
echo "  Output           : $OUTPUT_DIR/$IMG_NAME"
echo "═══════════════════════════════════════════════"

# ── Run build steps inside container as pmos user ────────────────────────────
docker exec "$CONTAINER" bash -l -c "
  set -euo pipefail
  PMB=\"$PMB\"

  echo \"[0/5] Fixing volume permissions and seeding version...\"
  sudo chown -R pmos:pmos /home/pmos/.local/var/pmbootstrap
  if [ ! -f /home/pmos/.local/var/pmbootstrap/version ]; then
    echo 8 > /home/pmos/.local/var/pmbootstrap/version
  fi

  echo \"[1/5] Setting channel to $CHANNEL...\"
  sed -i \"s/^channel =.*/channel = $CHANNEL/\" /home/pmos/.config/pmbootstrap_v3.cfg

  echo \"[1.5/5] Checking and cloning/updating pmaports...\"
  if [ ! -d /home/pmos/pmaports ]; then
    echo \"Cloning pmaports channel $CHANNEL...\"
    BRANCH=\"master\"
    if [[ \"$CHANNEL\" != \"edge\" ]]; then
      BRANCH=\"$CHANNEL\"
    fi
    git clone --depth 1 -b \"\$BRANCH\" https://gitlab.postmarketos.org/postmarketOS/pmaports.git /home/pmos/pmaports
  else
    echo \"Updating pmaports...\"
    BRANCH=\"master\"
    if [[ \"$CHANNEL\" != \"edge\" ]]; then
      BRANCH=\"$CHANNEL\"
    fi
    git -C /home/pmos/pmaports fetch --depth 1 origin \"\$BRANCH\"
    git -C /home/pmos/pmaports checkout -f \"\$BRANCH\"
    git -C /home/pmos/pmaports reset --hard origin/\"\$BRANCH\"
  fi

  echo \"[1/5] Setting UI to $UI...\"
  \$PMB config ui \"$UI\"

  if [[ \"$EXTRA\" != \"none\" ]]; then
    echo \"[1/5] Setting extra_packages to $EXTRA...\"
    \$PMB config extra_packages \"$EXTRA\"
  else
    \$PMB config extra_packages \"none\"
  fi

  echo \"[2/5] Zapping old rootfs chroots (keeping package caches)...\"
  set +o pipefail
  yes | \$PMB zap 2>&1 | tail -3
  set -o pipefail

  echo \"[3/5] Running pmbootstrap install...\"
  echo -e \"pmos1234\npmos1234\" | \$PMB install 2>&1

  echo \"[4/5] Exporting image symlinks...\"
  mkdir -p /home/pmos/output
  \$PMB export /home/pmos/output 2>&1 | grep -E \"Export|DONE|ERROR\"

  echo \"[5/5] Converting to sparse image...\"
  RAW=\$(readlink -f /home/pmos/output/qcom-msm8953.img)
  img2simg \"\$RAW\" \"/home/pmos/output/$IMG_NAME\"
  ls -lh \"/home/pmos/output/$IMG_NAME\"
  echo \"Sparse image ready.\"
"

# ── Copy out of container to host images/ ────────────────────────────────────
docker cp "${CONTAINER}:/home/pmos/output/${IMG_NAME}" "${OUTPUT_DIR}/${IMG_NAME}"
echo ""
echo "✅  Built: ${OUTPUT_DIR}/${IMG_NAME}"
echo "    Size : $(du -sh "${OUTPUT_DIR}/${IMG_NAME}" | cut -f1)"
