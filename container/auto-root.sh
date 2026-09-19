#!/bin/sh
# NovaOS Android Root - automated flow INSIDE the on-phone container
#
# Run from the Debian container on the phone (container/run.sh), after
# adb-connect.sh. Uses only official components: platform-tools adb and
# the Magisk toolchain (magiskboot) fetched from the official release.
# No exploits, ever.
#
# Flow: detect -> (rooted?) -> extract boot -> patch -> guide install
set -u

say()  { printf '%s\n' "$*"; }
fail() { printf '  [FAIL] %s\n' "$*"; }

MAGISK_DIR=/usr/local/lib/magisk
OUT=/sdcard/Download
WORK=/opt/novaos-root/work

say "NovaOS Android Root - automated flow (on-phone container)"
say "========================================================="

# --- 0. device ----------------------------------------------------------------
if ! adb get-state >/dev/null 2>&1; then
    fail "no device connected - first run: ./adb-connect.sh (wireless debugging)"
    exit 1
fi
SERIAL=$(adb get-serialno 2>/dev/null || echo unknown)
say "  device: $SERIAL"

# --- 1. detect (architecture / android version / root state) -------------------
ARCH=$(adb shell uname -m 2>/dev/null | tr -d '\r')
REL=$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
say "  arch:    ${ARCH:-unknown}"
say "  android: ${REL:-unknown}"

ROOTED=0
if adb shell 'ls /data/adb/magisk >/dev/null 2>&1 || ls /sbin/su >/dev/null 2>&1' 2>/dev/null; then
    ROOTED=1
fi
if [ "$ROOTED" = 1 ]; then
    say "  root:    present (Magisk/su found)"
else
    say "  root:    none"
fi

# --- 2. rooted -> official on-device reinstall path -----------------------------
if [ "$ROOTED" = 1 ]; then
    say ""
    say "already rooted. Official next steps (on the phone):"
    say "  - reinstall/upgrade root:  Magisk app -> Install -> Direct Install"
    say "  - switch to NO root:       Magisk app -> Uninstall -> Restore images"
    say "  - verify via adb:          ./auto-root.sh --check"
    [ "${1:-}" = "--check" ] && exit 0
    exit 0
fi

# --- 3. not rooted -> extract current boot --------------------------------------
say ""
say "not rooted. Extracting the CURRENT boot image..."
mkdir -p "$WORK" "$OUT"
if adb shell 'su -c "dd if=/dev/block/bootdevice/by-name/boot"' >/dev/null 2>&1; then
    adb shell 'su -c "dd if=/dev/block/bootdevice/by-name/boot"' > "$WORK/boot.img" 2>/dev/null
elif adb shell 'dd if=/dev/block/by-name/boot' >/dev/null 2>&1; then
    adb shell 'dd if=/dev/block/by-name/boot' > "$WORK/boot.img" 2>/dev/null
else
    say "  cannot read the boot partition without root (expected on a"
    say "  non-rooted phone - it is read-protected by Android)."
    say "  Use the on-device script instead:"
    say "    sh scripts/patch-boot.sh   (Termux, extracts from recovery path)"
    say "  or the Magisk app directly (Install -> Select and patch a file)."
    exit 1
fi
SIZE=$(wc -c < "$WORK/boot.img" 2>/dev/null || echo 0)
if [ "$SIZE" -lt 1000000 ]; then
    say "  boot.img looks wrong (${SIZE} bytes) - aborting"
    exit 1
fi
say "  boot.img extracted: $WORK/boot.img ($SIZE bytes)"
cp "$WORK/boot.img" "$OUT/boot.img" 2>/dev/null && say "  backup also saved to $OUT/boot.img"

# --- 4. patch with official magiskboot ------------------------------------------
if [ -x "$MAGISK_DIR/magiskboot" ]; then
    say "patching with official magiskboot..."
    cd "$WORK" || exit 1
    cp "$MAGISK_DIR"/* . 2>/dev/null || true
    "$MAGISK_DIR/magiskboot" unpack boot.img >/dev/null 2>&1 || {
        say "  unpack failed - patch manually: Magisk app -> Install -> Select and patch a file"; exit 1; }
    "$MAGISK_DIR/magiskboot" patch boot.img >/dev/null 2>&1 || {
        say "  patch failed - patch manually via the Magisk app (file is at $OUT/boot.img)"; exit 1; }
    "$MAGISK_DIR/magiskboot" repack boot.img >/dev/null 2>&1 || true
    if [ -f new-boot.img ]; then
        cp new-boot.img "$OUT/magisk_patched.img" 2>/dev/null
        say "  patched image: $OUT/magisk_patched.img"
    else
        say "  repack incomplete - patch manually via the Magisk app"
    fi
else
    say "  magiskboot not available in container (run fetch-magisk.sh)"
    say "  patch manually: Magisk app -> Install -> Select and patch a file"
fi

# --- 5. first-ever write note ----------------------------------------------------
say ""
say "NEXT (first-ever root on this phone):"
say "  Android keeps boot read-only until unlocked; the official paths are:"
say "    a) already-unlocked bootloader + one external fastboot flash"
say "       (the ONLY step in this project that touches a PC; after it,"
say "        everything above is repeatable fully on-device), or"
say "    b) existing root/custom recovery -> Magisk app -> Direct Install"
say "  See docs/PROCESS.md sections 3-5."
