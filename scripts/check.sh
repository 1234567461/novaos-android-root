#!/bin/sh
# NovaOS Android Root - device readiness checker
# Runs in Termux (or any POSIX shell with toybox/coreutils).
# Outputs a PASS/FAIL readiness report. Never modifies the device.
set -u

say()  { printf '%s\n' "$*"; }
pass() { printf '  [PASS] %s\n' "$*"; }
warn() { printf '  [WARN] %s\n' "$*"; }
fail() { printf '  [FAIL] %s\n' "$*"; }

say "NovaOS Android Root - readiness check"
say "====================================="

# --- 1. shell environment ------------------------------------------------
if command -v getprop >/dev/null 2>&1; then
    ON_DEVICE=1
else
    ON_DEVICE=0
fi

if [ "$ON_DEVICE" = 1 ]; then
    pass "running on Android device"
else
    warn "not on Android (running in adb shell / desktop?) - device checks skipped"
fi

# --- 2. architecture (32 / 64 bit) ---------------------------------------
MACHINE=$(uname -m 2>/dev/null || echo unknown)
case "$MACHINE" in
    aarch64|arm64)  ARCH="arm64-v8a (64-bit)";;
    armv7l|armv8l)  ARCH="armeabi-v7a (32-bit)";;
    x86_64|amd64)   ARCH="x86_64 (64-bit)";;
    i686|i386)      ARCH="x86 (32-bit)";;
    *)              ARCH="unknown ($MACHINE)";;
esac
say "  architecture: $ARCH"

# --- 3. Android version ---------------------------------------------------
if [ "$ON_DEVICE" = 1 ]; then
    SDK=$(getprop ro.build.version.sdk 2>/dev/null || echo 0)
    REL=$(getprop ro.build.version.release 2>/dev/null || echo "?")
    if [ "$SDK" -ge 21 ] 2>/dev/null; then
        pass "Android $REL (API $SDK) >= 5.0"
    else
        fail "Android $REL (API $SDK) < 5.0 - too old for current tooling"
    fi
else
    warn "Android version unknown (off-device)"
fi

# --- 4. already rooted? ---------------------------------------------------
SU_BIN=""
for p in /system/bin/su /system/xbin/su /sbin/su /system/xbin/magisk /data/adb/magisk/busybox; do
    [ -e "$p" ] && SU_BIN="$SU_BIN $p"
done
if [ -n "$SU_BIN" ]; then
    warn "root already present:$SU_BIN (run scripts/status.sh for details)"
else
    pass "no existing root found - clean state"
fi

# --- 5. bootloader / flash access -----------------------------------------
if [ "$ON_DEVICE" = 1 ]; then
    LOCK=$(getprop ro.boot.flash.locked 2>/dev/null || echo "?")
    VERITY=$(getprop ro.boot.veritymode 2>/dev/null || echo "?")
    say "  bootloader locked flag: ${LOCK:-?}"
    say "  verity mode: ${VERITY:-?}"
    # fastboot availability (checked via shell only; real check is in fastboot)
    if command -v fastboot >/dev/null 2>&1; then
        pass "fastboot binary available"
    else
        warn "fastboot not in this shell - run from PC with platform-tools"
    fi
else
    warn "bootloader state requires on-device check"
fi

# --- 6. summary -----------------------------------------------------------
say "-------------------------------------"
if [ "$ON_DEVICE" = 0 ]; then
    warn "off-device: only partial check possible"
    say "on the phone (Termux) run:  sh scripts/check.sh"
    say "then follow docs/PROCESS.md sections 2-4"
else
    say "check done. See SUPPORTED.md + docs/PROCESS.md before proceeding."
fi
