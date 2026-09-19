#!/bin/sh
# NovaOS Android Root - status of existing root (Magisk / KernelSU / su)
# Read-only. Tells you which root stack is installed and how to remove it.
set -u

say()  { printf '%s\n' "$*"; }

say "NovaOS Android Root - installed root status"
say "==========================================="

FOUND=0

# --- Magisk ----------------------------------------------------------------
if [ -d /data/adb/magisk ] || [ -x /data/adb/magisk/magisk ]; then
    FOUND=1
    say "  stack: Magisk"
    if [ -f /data/adb/magisk/util_functions.sh ]; then
        say "  magisk files present at /data/adb/magisk"
    fi
    if command -v magisk >/dev/null 2>&1; then
        say "  version: $(magisk -V 2>/dev/null) ($(magisk -v 2>/dev/null))"
    fi
    say "  remove (official): open Magisk app -> Uninstall -> Restore images"
fi

# --- KernelSU ---------------------------------------------------------------
if [ -e /data/adb/ksu ] || [ -e /data/adb/ksu.img ]; then
    FOUND=1
    say "  stack: KernelSU"
    say "  ksu files present at /data/adb/ksu"
    say "  remove (official): restore original boot.img (see docs/PROCESS.md §6)"
fi

# --- plain su ----------------------------------------------------------------
for p in /system/bin/su /system/xbin/su /sbin/su; do
    if [ -e "$p" ]; then
        FOUND=1
        say "  su binary at $p (legacy/other stack)"
    fi
done

# --- selinux -----------------------------------------------------------------
if command -v getenforce >/dev/null 2>&1; then
    say "  selinux: $(getenforce 2>/dev/null)"
fi

if [ "$FOUND" = 0 ]; then
    say "  no root stack detected - device is in factory state"
    say "  to start: sh scripts/check.sh"
fi
