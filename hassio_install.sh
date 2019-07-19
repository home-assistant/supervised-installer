#!/bin/bash
set -e

ARCH=$(uname -m)
DOCKER_DAEMON_CONFIG=/etc/docker/daemon.json
SNAP=false
DOCKER_REPO=homeassistant
DOCKER_SERVICE=docker.service
DATA_SHARE=/usr/share/hassio
CONFIG=/etc/hassio.json
URL_VERSION="https://version.home-assistant.io/stable.json"
URL_BIN_HASSIO="https://raw.githubusercontent.com/home-assistant/hassio-installer/master/files/hassio-supervisor"
URL_BIN_APPARMOR="https://raw.githubusercontent.com/home-assistant/hassio-installer/master/files/hassio-apparmor"
URL_SERVICE_HASSIO="https://raw.githubusercontent.com/home-assistant/hassio-installer/master/files/hassio-supervisor.service"
URL_SERVICE_APPARMOR="https://raw.githubusercontent.com/home-assistant/hassio-installer/master/files/hassio-apparmor.service"
URL_APPARMOR_PROFILE="https://version.home-assistant.io/apparmor.txt"

# Check env
command -v systemctl > /dev/null 2>&1 || { echo "[Error] Only systemd is supported!"; exit 1; }
command -v docker > /dev/null 2>&1 || { echo "[Error] Please install docker first"; exit 1; }
command -v jq > /dev/null 2>&1 || { echo "[Error] Please install jq first"; exit 1; }
command -v curl > /dev/null 2>&1 || { echo "[Error] Please install curl first"; exit 1; }
command -v avahi-daemon > /dev/null 2>&1 || { echo "[Error] Please install avahi first"; exit 1; }
command -v dbus-daemon > /dev/null 2>&1 || { echo "[Error] Please install dbus first"; exit 1; }
command -v apparmor_parser > /dev/null 2>&1 || echo "[Warning] No AppArmor support on host."
command -v nmcli > /dev/null 2>&1 || echo "[Warning] No NetworkManager support on host."

#detect if running on snapped docker
if snap list docker >/dev/null 2>&1; then
    SNAP=true
    DOCKER_DAEMON_CONFIG=/root/snap/docker/current/etc/docker/daemon.json
    DATA_SHARE=/root/snap/docker/common/hassio
    CONFIG=$DATA_SHARE/hassio.json
    DOCKER_SERVICE="snap.docker.dockerd.service"
fi

function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }
function adjust_snap() { sed "s,/usr/bin/docker,/snap/bin/docker,; s,docker.service,$DOCKER_SERVICE,; s,/etc/hassio.json,$CONFIG," -i "$1"; }

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
    "arm" |"armv6l")
        if [ -z $MACHINE ]; then
            echo "[ERROR] Please set machine for $ARCH"
            exit 1
        fi
        HOMEASSISTANT_DOCKER="$DOCKER_REPO/$MACHINE-homeassistant"
        HASSIO_DOCKER="$DOCKER_REPO/armhf-hassio-supervisor"
    ;;
    "armv7l")
        if [ -z $MACHINE ]; then
            echo "[ERROR] Please set machine for $ARCH"
            exit 1
        fi
        HOMEASSISTANT_DOCKER="$DOCKER_REPO/$MACHINE-homeassistant"
        HASSIO_DOCKER="$DOCKER_REPO/armv7-hassio-supervisor"
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
cat > $CONFIG <<- EOF
{
    "supervisor": "${HASSIO_DOCKER}",
    "homeassistant": "${HOMEASSISTANT_DOCKER}",
    "data": "${DATA_SHARE}"
}
EOF

##
# Check DNS settings
DOCKER_VERSION="$(docker --version | grep -Po "\d{2}\.\d{2}\.\d")"
if version_gt "18.09.0" "${DOCKER_VERSION}" && [ ! -e "$DOCKER_DAEMON_CONFIG" ]; then
    echo "[Warning] Create DNS settings for Docker to avoid systemd bug!"
    mkdir -p $(dirname ${DOCKER_DAEMON_CONFIG})
    echo '{"dns": ["8.8.8.8", "8.8.4.4"]}' > $DOCKER_DAEMON_CONFIG

    echo "[Info] Restart Docker and wait 30 seconds"
    systemctl restart $DOCKER_SERVICE && sleep 30
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

#adjust paths for snap
if [ "$SNAP" = "true" ]; then
    adjust_snap /usr/sbin/hassio-supervisor
    adjust_snap /etc/systemd/system/hassio-supervisor.service
fi

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

    #adjust paths for snap
    if [ "$SNAP" = "true" ]; then
        adjust_snap /usr/sbin/hassio-apparmor
        adjust_snap /etc/systemd/system/hassio-apparmor.service
    fi

    chmod a+x /usr/sbin/hassio-apparmor
    systemctl enable hassio-apparmor.service
    systemctl start hassio-apparmor.service
fi

##
# Init system
echo "[Info] Run Hass.io"
systemctl start hassio-supervisor.service
