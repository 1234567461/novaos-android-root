#!/bin/sh
# NovaOS Android Root - PC-side one-command route (OPTIONAL)
#
# Deploys the same automation as a Docker container on the PC, then
# reaches the phone over the network (wireless debugging) or USB.
#
# The IP below is a PLACEHOLDER - replace it with the IP your router
# assigned to YOUR phone (Settings -> About phone -> Status -> IP, or
# the "IP address & Port" line under Wireless debugging).
#
# Usage (on the PC, in this repo):
#   sh container/pc.sh connect 192.168.1.5:37000   # connect to the phone
#   sh container/pc.sh usb                          # USB-connected phone
#   sh container/pc.sh build                        # just build the image
set -eu

IMAGE=novaos-root

say() { printf '%s\n' "$*"; }

# --- build image (once) --------------------------------------------------------
build() {
    if docker image inspect "$IMAGE" >/dev/null 2>&1; then
        say "image $IMAGE already built"
    else
        say "building $IMAGE (first build downloads Debian base)..."
        docker build -f container/Dockerfile -t "$IMAGE" .
    fi
}

# --- run container with USB passthrough ------------------------------------------
run_container() {
    exec docker run --rm -it \
        --name novaos-root \
        --device /dev/bus/usb \
        -v "$(pwd)/scripts":/opt/novaos-root/scripts:ro \
        "$IMAGE" "$@"
}

case "${1:-build}" in
    build)
        build
        say "built. Next: sh container/pc.sh connect <phone-ip>:<port>"
        ;;
    connect)
        build
        say "connecting to phone at $2 (this must be the IP your router"
        say "assigned to the phone - change it in this command if different)"
        run_container "adb connect $2 && adb devices -l && echo '---' && ./auto-root.sh"
        ;;
    usb)
        build
        say "using USB-connected phone"
        run_container "adb devices -l && echo '---' && ./auto-root.sh"
        ;;
    *)
        say "usage:"
        say "  sh container/pc.sh build"
        say "  sh container/pc.sh connect <phone-ip>:<wireless-debug-port>"
        say "  sh container/pc.sh usb"
        exit 1
        ;;
esac
