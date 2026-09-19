#!/bin/sh
# NovaOS Android Root - connect to the phone from inside the on-phone container
#
# Two ways to reach the phone with adb:
#
# A) Wireless debugging (localhost - the phone is the same machine):
#    Settings -> Developer options -> Wireless debugging
#    - "Pair device with pairing code": shows IP:PAIR_PORT + 6-digit code
#        ./adb-connect.sh pair <ip>:<pair_port> <code>
#    - "IP address & Port" section: shows IP:CONNECT_PORT
#        ./adb-connect.sh connect <ip>:<connect_port>
#
# B) USB (OTG): plug in an OTG cable with the phone on the other end is
#    unusual; normally you connect via wireless debugging above.
set -eu

say() { printf '%s\n' "$*"; }

if [ "$#" -lt 2 ]; then
    say "usage:"
    say "  ./adb-connect.sh pair    <ip>:<pair_port>   <6-digit-code>"
    say "  ./adb-connect.sh connect <ip>:<connect_port>"
    say "  ./adb-connect.sh usb                        (list USB devices)"
    exit 1
fi

case "$1" in
    pair)
        adb pair "$2" "$3"
        ;;
    connect)
        adb connect "$2"
        ;;
    usb)
        adb devices -l
        ;;
    *)
        say "unknown: $1"; exit 1 ;;
esac

say ""
say "devices now visible to adb:"
adb devices -l
