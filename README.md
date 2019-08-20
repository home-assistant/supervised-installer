[![Build Status](https://dev.azure.com/home-assistant/Hass.io/_apis/build/status/hassio-installer?branchName=master)](https://dev.azure.com/home-assistant/Hass.io/_build/latest?definitionId=6&branchName=master)

# Install Hass.io

As an alternative to using the images which include the HassOS operating system and Docker, it is also possible to run Hass.io on a generic system running another OS of your choice such as Ubuntu, Debian, etc. Because of all the various possible install options, these are more of a community supported installation choice. It follows that the more esoteric of a choice made with the OS, the less a user will find in terms of information and support from the community.

## Requirements

```
docker-ce
bash
jq
curl
avahi-daemon
dbus
```

## Optional

```
apparmor-utils
network-manager
```

## Run

Run as root (sudo su):

```bash
curl -sL https://raw.githubusercontent.com/home-assistant/hassio-installer/master/hassio_install.sh | bash -s
```

### Command line arguments
| argument           | default                                                                                                                                                                             | description                                            |
|--------------------|----------------------|--------------------------------------------------------|
| -m \| --machine    |                      | On a special platform they need set a machine type use |
| -d \| --data-share | $PREFIX/share/hassio | data folder for hass.io installation                   |
| -p \| --prefix     | /usr                 | Binary prefix for hass.io installation                 |
| -s \| --sysconfdir | /etc                 | Configuration directory for hass.io installation       |

you can set these parameters by appending ` -- <parameter> <value>` like:

```bash
curl -sL https://raw.githubusercontent.com/home-assistant/hassio-installer/master/hassio_install.sh | bash -s -- -m MY_MACHINE
```

## Supported Machine types

- intel-nuc
- odroid-c2
- odroid-xu
- orangepi-prime
- qemuarm
- qemuarm-64
- qemux86
- qemux86-64
- raspberrypi
- raspberrypi2
- raspberrypi3
- raspberrypi3-64
- tinker

## !!!WARNING!!! DO NOT DELETE CREATED CONTAINERS

This installer will create the base `homeassistant` container for you, but if you delete it (`docker rm` or `docker prune`) the supervisor will not be able to re-create it for you. Hass.io is an Ecosystem and Container Orchestrator and does not support manual adjustments.

If you wish to still safely use `docker containers prune` it is strongly advised to add the `--filter` flag to your command.

Example:
```sh
$ docker container prune --filter label!=homeassistant
```
or, for a greater peace of mind, you can add the following config to your `~/.docker/config.json`:
```javascript
{
  "pruneFilters": ["label!=homeassistant", "label!=hassio_supervisor", "label!=addon*"]
}
```
