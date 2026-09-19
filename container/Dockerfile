# NovaOS Android Root - ADB control container
#
# NOTE: the primary deployment is the ON-PHONE container (proot-distro,
# see setup-container.sh). This Dockerfile is the optional PC-side build
# of the same automation - useful for the one-time external fastboot step
# or batch handling of several phones.
#
# Build:  docker build -f container/Dockerfile -t novaos-root .
# Run:    docker run --rm -it --device /dev/bus/usb -p 5037:5037 -p 5555:5555 novaos-root
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        android-sdk-platform-tools \
        wget unzip ca-certificates curl usbutils \
    && rm -rf /var/lib/apt/lists/* \
    && echo "platform-tools: $(adb --version | head -1)"

WORKDIR /opt/novaos-root

COPY scripts/ ./scripts/
COPY container/fetch-magisk.sh ./fetch-magisk.sh
RUN sh ./fetch-magisk.sh && rm -f ./fetch-magisk.sh

COPY container/auto-root.sh ./auto-root.sh
COPY container/adb-connect.sh ./adb-connect.sh

EXPOSE 5037 5555
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["adb start-server && adb devices -l && echo 'container ready: run ./auto-root.sh'"]
