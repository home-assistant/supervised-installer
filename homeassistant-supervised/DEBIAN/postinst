#!/usr/bin/env bash
set -e
function info { echo -e "\e[32m[info] $*\e[39m"; }
function warn  { echo -e "\e[33m[warn] $*\e[39m"; }
function error { echo -e "\e[31m[error] $*\e[39m"; exit 1; }
. /usr/share/debconf/confmodule
ARCH=$(uname -m)

BINARY_DOCKER=/usr/bin/docker

DOCKER_REPO="ghcr.io/home-assistant"

SERVICE_DOCKER="docker.service"
SERVICE_NM="NetworkManager.service"

# Read infos from web
URL_VERSION_HOST="version.home-assistant.io"
URL_VERSION="https://version.home-assistant.io/stable.json"
HASSIO_VERSION=$(curl -s $URL_VERSION | jq -e -r '.supervisor')
URL_APPARMOR_PROFILE="https://version.home-assistant.io/apparmor.txt"


# Restart NetworkManager
info "Restarting NetworkManager"
systemctl restart "${SERVICE_NM}"

# Restart Docker service
info "Restarting docker service"
systemctl restart "$SERVICE_DOCKER"

# Check network connection
while ! ping -c 1 -W 1 ${URL_VERSION_HOST}; do
    info "Waiting for ${URL_VERSION_HOST} - network interface might be down..."
    sleep 2
done

# Get primary network interface
PRIMARY_INTERFACE=$(ip route | awk '/^default/ { print $5 }')
IP_ADDRESS=$(ip -4 addr show dev "$PRIMARY_INTERFACE" | awk '/inet / { sub("/.*", "", $2); print $2 }')

case $ARCH in
    "i386" | "i686")
        MACHINE=${MACHINE:=qemux86}
        HASSIO_DOCKER="$DOCKER_REPO/i386-hassio-supervisor"
    ;;
    "x86_64")
        MACHINE=${MACHINE:=qemux86-64}
        HASSIO_DOCKER="$DOCKER_REPO/amd64-hassio-supervisor"
    ;;
    "arm" |"armv6l")
        if [ -z $MACHINE ]; then
             db_input critical ha/machine-type | true
             db_go || true
             db_get ha/machine-type || true
             MACHINE="$RET"
             db_stop
        fi
        HASSIO_DOCKER="$DOCKER_REPO/armhf-hassio-supervisor"
    ;;
    "armv7l")
        if [ -z $MACHINE ]; then
             db_input critical ha/machine-type | true
             db_go || true
             db_get ha/machine-type || true
             MACHINE="$RET"
             db_stop
        fi
        HASSIO_DOCKER="$DOCKER_REPO/armv7-hassio-supervisor"
    ;;
    "aarch64")
        if [ -z $MACHINE ]; then
             db_input critical ha/machine-type | true
             db_go || true
             db_get ha/machine-type || true
             MACHINE="$RET"
             db_stop

        fi
        HASSIO_DOCKER="$DOCKER_REPO/aarch64-hassio-supervisor"
    ;;
    *)
        error "$ARCH unknown!"
    ;;
esac
PREFIX=${PREFIX:-/usr}
SYSCONFDIR=${SYSCONFDIR:-/etc}
DATA_SHARE=${DATA_SHARE:-$PREFIX/share/hassio}
CONFIG=$SYSCONFDIR/hassio.json
cat > "$CONFIG" <<- EOF
{
    "supervisor": "${HASSIO_DOCKER}",
    "machine": "${MACHINE}",
    "data": "${DATA_SHARE}"
}
EOF

# Pull Supervisor image
info "Install supervisor Docker container"
docker pull "$HASSIO_DOCKER:$HASSIO_VERSION" > /dev/null
docker tag "$HASSIO_DOCKER:$HASSIO_VERSION" "$HASSIO_DOCKER:latest" > /dev/null

# Install Supervisor
info "Install supervisor startup scripts"
sed -i "s,%%HASSIO_CONFIG%%,${CONFIG},g" "${PREFIX}"/sbin/hassio-supervisor
sed -i -e "s,%%BINARY_DOCKER%%,${BINARY_DOCKER},g" \
       -e "s,%%SERVICE_DOCKER%%,${SERVICE_DOCKER},g" \
       -e "s,%%BINARY_HASSIO%%,${PREFIX}/sbin/hassio-supervisor,g" \
       "${SYSCONFDIR}/systemd/system/hassio-supervisor.service"

chmod a+x "${PREFIX}/sbin/hassio-supervisor"
systemctl enable hassio-supervisor.service > /dev/null 2>&1;

# Install AppArmor
info "Install AppArmor scripts"
curl -sL ${URL_APPARMOR_PROFILE} > "${DATA_SHARE}/apparmor/hassio-supervisor"
sed -i "s,%%HASSIO_CONFIG%%,${CONFIG},g" "${PREFIX}/sbin/hassio-apparmor"
sed -i -e "s,%%SERVICE_DOCKER%%,${SERVICE_DOCKER},g" \
    -e "s,%%HASSIO_APPARMOR_BINARY%%,${PREFIX}/sbin/hassio-apparmor,g" \
    "${SYSCONFDIR}/systemd/system/hassio-apparmor.service"

chmod a+x "${PREFIX}/sbin/hassio-apparmor"
systemctl enable hassio-apparmor.service > /dev/null 2>&1;
systemctl start hassio-apparmor.service

# Start Supervisor 
info "Start Home Assistant Supervised"
systemctl start hassio-supervisor.service


# Install HA CLI
info "Installing the 'ha' cli"
chmod a+x "${PREFIX}/bin/ha"


info "Within a few minutes you will be able to reach Home Assistant at:"
info "http://homeassistant.local:8123 or using the IP address of your"
info "machine: http://${IP_ADDRESS}:8123"