#!/bin/sh
# NovaOS Android Root - one-command container setup ON THE PHONE
#
# Deploys a Linux container (Debian via proot-distro) inside Termux,
# installs the official android-tools (adb/fastboot) and the official
# Magisk toolchain inside it, then copies this repo's scripts in.
# Everything runs on the phone - no PC involved.
#
# Usage (in Termux on the phone):
#   sh container/setup-container.sh
#
# Afterwards:
#   sh container/run.sh          -> enter the container (Debian shell)
#   ./auto-root.sh               -> automated check/extract/patch flow
set -eu

say() { printf '%s\n' "$*"; }

say "NovaOS Android Root - on-phone container setup"
say "==============================================="

# --- 1. Termux packages ------------------------------------------------------
command -v proot-distro >/dev/null 2>&1 || {
    say "installing proot-distro + android-tools (Termux)..."
    pkg install -y proot-distro android-tools
}
command -v proot-distro >/dev/null 2>&1 || {
    echo "FAIL: proot-distro unavailable; run 'pkg install proot-distro' first"; exit 1; }

# --- 2. Debian container -----------------------------------------------------
if proot-distro list | grep -q '^debian'; then
    say "debian container: already installed"
else
    say "installing Debian container (first run downloads ~100MB)..."
    proot-distro install debian
fi

# --- 3. tools inside the container -------------------------------------------
say "installing curl/unzip inside the container..."
proot-distro login debian -- sh -c \
    "apt-get update -qq && apt-get install -y -qq curl unzip" \
    || say "  (apt install deferred - rerun container/run.sh then: apt install curl unzip)"

# --- 4. copy this repo's scripts into the container ---------------------------
ROOTFS="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
if [ -d "$ROOTFS" ]; then
    mkdir -p "$ROOTFS/opt/novaos-root"
    cp -r scripts "$ROOTFS/opt/novaos-root/"
    cp -r container/fetch-magisk.sh "$ROOTFS/opt/novaos-root/"
    say "scripts copied to container: /opt/novaos-root"
else
    say "WARN: container rootfs not at $ROOTFS - copy scripts manually"
fi

# --- 5. official Magisk toolchain inside the container ------------------------
say "extracting official Magisk toolchain (magiskboot etc.)..."
proot-distro login debian -- sh /opt/novaos-root/fetch-magisk.sh || \
    say "  (toolchain fetch failed - adb/fastboot still work; see docs/CONTAINER.md)"

say ""
say "DONE. Now:"
say "  1. turn on wireless debugging on the phone:"
say "     Settings -> Developer options -> Wireless debugging"
say "     (phone and itself are always 'same network' - localhost works)"
say "  2. enter the container and automate:"
say "     sh container/run.sh"
say "     ./adb-connect.sh <ip:port> <pairing-code>   (or use USB)"
say "     ./auto-root.sh"
