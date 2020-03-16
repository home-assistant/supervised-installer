[![Build Status](https://dev.azure.com/home-assistant/Hass.io/_apis/build/status/hassio-installer?branchName=master)](https://dev.azure.com/home-assistant/Hass.io/_build/latest?definitionId=6&branchName=master)

# Install Home Assistant Supervised

As an alternative to using the images which include the Home Assistant operating-system and Docker, it is also possible to run Home Assistant on a generic system running another Linux of your choice such as Ubuntu, Debian, etc as Supervised. Because of all the various possible install options, these are more of a community supported installation choice. It follows that the more esoteric of a choice made with the OS, the less a user will find in terms of information and support from the community.

## Requirements

We only support Linux distributions that follow the [FHS 3.0](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)!

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

**Important**: Don't only install NetworkManager, you need also use it on your system.

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
- odroid-n2
- odroid-xu
- qemuarm
- qemuarm-64
- qemux86
- qemux86-64
- raspberrypi
- raspberrypi2
- raspberrypi3
- raspberrypi4
- raspberrypi3-64
- raspberrypi4-64
- tinker

