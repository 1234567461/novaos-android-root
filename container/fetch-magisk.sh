#!/bin/sh
# NovaOS Android Root - fetch the OFFICIAL Magisk toolchain
#
# Downloads the latest Magisk release from github.com/topjohnwu/Magisk
# (official source), extracts the native binaries for the container's
# architecture and installs them to /usr/local/lib/magisk/.
# All binaries are official Magisk components - no exploit code anywhere.
set -eu

MAGISK_DIR=/usr/local/lib/magisk
mkdir -p "$MAGISK_DIR"

# --- latest release URL from the official GitHub API ---------------------
API="https://api.github.com/repos/topjohnwu/Magisk/releases/latest"
APK_URL=$(curl -fsSL "$API" | grep -o 'https://[^"]*Magisk-v[^"]*\.apk' | head -1)
if [ -z "$APK_URL" ]; then
    echo "WARN: could not resolve latest Magisk APK from GitHub API"
    echo "      (rate limit?). The container still works for adb/fastboot;"
    echo "      re-run fetch-magisk.sh later to add the toolchain."
    exit 0
fi
echo "fetching: $APK_URL"
curl -fSL -o /tmp/magisk.apk "$APK_URL" || {
    echo "WARN: download failed; continuing without Magisk toolchain"; exit 0; }

# --- pick the right lib dir for this container's arch ----------------------
case "$(uname -m)" in
    x86_64|amd64) LIBDIR="lib/x86_64" ;;
    aarch64|arm64) LIBDIR="lib/arm64-v8a" ;;
    *) echo "WARN: unsupported container arch $(uname -m)"; exit 0 ;;
esac

# --- extract the official native components ---------------------------------
unzip -o -j /tmp/magisk.apk "$LIBDIR/libmagiskboot.so"   -d /tmp/magisk >/dev/null 2>&1
unzip -o -j /tmp/magisk.apk "$LIBDIR/libmagiskinit.so"   -d /tmp/magisk >/dev/null 2>&1 || true
unzip -o -j /tmp/magisk.apk "$LIBDIR/libmagisk32.so"     -d /tmp/magisk >/dev/null 2>&1 || true
unzip -o -j /tmp/magisk.apk "$LIBDIR/libmagisk64.so"     -d /tmp/magisk >/dev/null 2>&1 || true
unzip -o -j /tmp/magisk.apk "$LIBDIR/libmagiskpolicy.so" -d /tmp/magisk >/dev/null 2>&1 || true

if [ ! -f /tmp/magisk/libmagiskboot.so ]; then
    echo "WARN: magiskboot not found in APK (structure changed?); continue anyway"
    exit 0
fi

for f in /tmp/magisk/lib*.so; do
    b=$(basename "$f" .so)               # libmagiskboot -> magiskboot
    b=${b#lib}
    cp "$f" "$MAGISK_DIR/$b"
    chmod +x "$MAGISK_DIR/$b"
done
rm -rf /tmp/magisk /tmp/magisk.apk

echo "Magisk toolchain installed at $MAGISK_DIR:"
ls -1 "$MAGISK_DIR"
