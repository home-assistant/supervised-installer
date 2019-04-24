#!/bin/bash
set -e

ARCH=$(uname -m)
DOCKER_REPO=homeassistant
DATA_SHARE=/usr/share/hassio
URL_VERSION="https://s3.amazonaws.com/hassio-version/stable.json"
URL_BIN_HASSIO="https://raw.githubusercontent.com/home-assistant/hassio-installer/master/files/hassio-supervisor"
URL_BIN_APPARMOR="https://raw.githubusercontent.com/home-assistant/hassio-installer/master/files/hassio-apparmor"
URL_SERVICE_HASSIO="https://raw.githubusercontent.com/home-assistant/hassio-installer/master/files/hassio-supervisor.service"
URL_SERVICE_APPARMOR="https://raw.githubusercontent.com/home-assistant/hassio-installer/master/files/hassio-apparmor.service"
URL_APPARMOR_PROFILE="http://s3.amazonaws.com/hassio-version/apparmor.txt"

# Check env
command -v systemctl > /dev/null 2>&1 || { echo "[Error] Only systemd is supported!"; exit 1; }
command -v docker > /dev/null 2>&1 || { echo "[Error] Please install docker first"; exit 1; }
command -v jq > /dev/null 2>&1 || { echo "[Error] Please install jq first"; exit 1; }
command -v curl > /dev/null 2>&1 || { echo "[Error] Please install curl first"; exit 1; }
command -v avahi-daemon > /dev/null 2>&1 || { echo "[Error] Please install avahi first"; exit 1; }
command -v dbus-daemon > /dev/null 2>&1 || { echo "[Error] Please install dbus first"; exit 1; }
command -v apparmor_parser > /dev/null 2>&1 || echo "[Warning] No AppArmor support on host."
command -v nmcli > /dev/null 2>&1 || echo "[Warning] No NetworkManager support on host."

function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

# Parse command line parameters
while [[ $# -gt 0 ]]; do
    arg="$1"

    case $arg in
        -m|--machine)
            MACHINE=$2
            shift
            ;;
        -d|--data-share)
            DATA_SHARE=$2
            shift
            ;;
        *)
            echo "[Error] Unrecognized option $1"
            exit 1
            ;;
    esac
    shift
done

# Generate hardware options
case $ARCH in
    "i386" | "i686")
        MACHINE=${MACHINE:=qemux86}
        HOMEASSISTANT_DOCKER="$DOCKER_REPO/$MACHINE-homeassistant"
        HASSIO_DOCKER="$DOCKER_REPO/i386-hassio-supervisor"
    ;;
    "x86_64")
        MACHINE=${MACHINE:=qemux86-64}
        HOMEASSISTANT_DOCKER="$DOCKER_REPO/$MACHINE-homeassistant"
        HASSIO_DOCKER="$DOCKER_REPO/amd64-hassio-supervisor"
    ;;
    "arm" | "armv7l" | "armv6l")
        if [ -z $MACHINE ]; then
            echo "[ERROR] Please set machine for $ARCH"
            exit 1
        fi
        HOMEASSISTANT_DOCKER="$DOCKER_REPO/$MACHINE-homeassistant"
        HASSIO_DOCKER="$DOCKER_REPO/armhf-hassio-supervisor"
    ;;
    "aarch64")
        if [ -z $MACHINE ]; then
            echo "[ERROR] Please set machine for $ARCH"
            exit 1
        fi
        HOMEASSISTANT_DOCKER="$DOCKER_REPO/$MACHINE-homeassistant"
        HASSIO_DOCKER="$DOCKER_REPO/aarch64-hassio-supervisor"
    ;;
    *)
        echo "[Error] $ARCH unknown!"
        exit 1
    ;;
esac

if [ -z "${HOMEASSISTANT_DOCKER}" ]; then
    echo "[Error] Found no Home Assistant Docker images for this host!"
fi

### Main

# Init folders
if [ ! -d "$DATA_SHARE" ]; then
    mkdir -p "$DATA_SHARE"
fi

# Read infos from web
HASSIO_VERSION=$(curl -s $URL_VERSION | jq -e -r '.supervisor')

##
# Write config
cat > /etc/hassio.json <<- EOF
{
    "supervisor": "${HASSIO_DOCKER}",
    "homeassistant": "${HOMEASSISTANT_DOCKER}",
    "data": "${DATA_SHARE}"
}
EOF

##
# Check DNS settings
DOCKER_VERSION="$(docker --version | grep -Po "\d{2}\.\d{2}\.\d")"
if version_gt "18.09.0" "${DOCKER_VERSION}" && [ ! -e "/etc/docker/daemon.json" ]; then
    echo "[Warning] Create DNS settings for Docker to avoid systemd bug!"
    mkdir -p /etc/docker
    echo '{"dns": ["8.8.8.8", "8.8.4.4"]}' > /etc/docker/daemon.json

    echo "[Info] Restart Docker and wait 30 seconds"
    systemctl restart docker.service && sleep 30
fi

##
# Pull supervisor image
echo "[Info] Install supervisor Docker container"
docker pull "$HASSIO_DOCKER:$HASSIO_VERSION" > /dev/null
docker tag "$HASSIO_DOCKER:$HASSIO_VERSION" "$HASSIO_DOCKER:latest" > /dev/null

##
# Install Hass.io Supervisor
echo "[Info] Install supervisor startup scripts"
curl -sL ${URL_BIN_HASSIO} > /usr/sbin/hassio-supervisor
curl -sL ${URL_SERVICE_HASSIO} > /etc/systemd/system/hassio-supervisor.service

chmod a+x /usr/sbin/hassio-supervisor
systemctl enable hassio-supervisor.service

#
# Install Hass.io AppArmor
if command -v apparmor_parser > /dev/null 2>&1; then
    echo "[Info] Install AppArmor scripts"
    mkdir -p "${DATA_SHARE}"/apparmor
    curl -sL ${URL_BIN_APPARMOR} > /usr/sbin/hassio-apparmor
    curl -sL ${URL_SERVICE_APPARMOR} > /etc/systemd/system/hassio-apparmor.service
    curl -sL ${URL_APPARMOR_PROFILE} > "${DATA_SHARE}"/apparmor/hassio-supervisor

    chmod a+x /usr/sbin/hassio-apparmor
    systemctl enable hassio-apparmor.service

    systemctl start hassio-apparmor.service
fi

##
# Init system
echo "[Info] Run Hass.io"
systemctl start hassio-supervisor.service
