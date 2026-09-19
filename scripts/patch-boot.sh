#!/bin/sh
# NovaOS Android Root - helper: extract the CURRENT boot.img for patching
#
# This is the only safe source for Magisk / KernelSU patching: the boot
# image currently running on YOUR device (not one downloaded from the net).
# Run inside Termux on the phone; output goes to /sdcard/Download/.
#
# After extraction, follow docs/PROCESS.md:
#   1. copy boot.img to a PC   (or use the Magisk app directly on-device)
#   2. Magisk app -> Install -> Select and patch a file -> boot.img
#   3. fastboot boot patched   (temporary)  OR  fastboot flash (permanent)
set -u

OUT=/sdcard/Download
BOOT=/dev/block/bootdevice/by-name/boot

say() { printf '%s\n' "$*"; }

# --- prerequisites -----------------------------------------------------------
if ! command -v dd >/dev/null 2>&1; then
    echo "FAIL: dd not found - run inside Termux (pkg install coreutils)"
    exit 1
fi
if [ ! -b "$BOOT" ]; then
    echo "WARN: $BOOT not found - locating boot partition..."
    # common alternative paths (samsung / pixel / qcom)
    for alt in \
        /dev/block/by-name/boot \
        /dev/block/platform/*/by-name/boot \
        /dev/block/bootdevice/by-name/boot_a \
        /dev/block/bootdevice/by-name/boot_b; do
        if [ -b "$alt" ]; then
            BOOT="$alt"
            echo "  using $BOOT"
            break
        fi
    done
    [ -b "$BOOT" ] || { echo "FAIL: cannot locate boot partition on this device"; exit 1; }
fi

# --- backup -------------------------------------------------------------------
if [ -e "$OUT" ]; then :; else mkdir -p "$OUT" || { echo "FAIL: cannot create $OUT"; exit 1; }; fi

SIZE=$(blockdev --getsize64 "$BOOT" 2>/dev/null || echo 67108864)
echo "extracting $BOOT (${SIZE} bytes) -> $OUT/boot.img ..."
dd if="$BOOT" of="$OUT/boot.img" bs=4096 count=$((SIZE / 4096)) 2>/dev/null || {
    echo "FAIL: dd failed (permission?). Grant storage access, then retry."
    exit 1
}

md5sum "$OUT/boot.img" 2>/dev/null || true
echo ""
echo "DONE: boot.img saved to $OUT/boot.img"
echo "Never download a boot.img from the internet - always use THIS file."
echo "Next: docs/PROCESS.md §4 (Magisk patch) -> §5 (temp/permanent)."
