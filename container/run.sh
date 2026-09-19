#!/bin/sh
# NovaOS Android Root - enter the on-phone Debian container
#
# Usage (in Termux on the phone, after setup-container.sh):
#   sh container/run.sh
set -eu
exec proot-distro login debian -- "$@"
