# Install Home Assistant Supervised

As an alternative to using the images which include the Home Assistant operating-system and Docker, it is also possible to run Home Assistant on a generic system running another Linux of your choice such as Ubuntu, Debian, etc as Supervised. Because of all the various possible install options, these are more of a community supported installation choice. It follows that the more esoteric of a choice made with the OS, the less a user will find in terms of information and support from the community.

## Warning

The Supervisord system is designed to provide a full-featured environment that is comparable with Kubernetes, which is also a bad idea to run it by the side of another orchestrator on the same Host. The Supervisor is also not caring for other software they run on your Host, and it can affect things bad on both sides. You also need to know that the Home Assistant OS runs with less overhead on your Proxmox or other Hypervisor as if you install first Debian and Ubuntu. In most cases, it's not the best choice to run the Supervisord on top of a Linux, if you not 100% sure what you do. **It is not just a container inside Docker!**

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
curl -sL https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh | bash -s
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
curl -sL https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh | bash -s -- -m MY_MACHINE
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

## Troubleshooting

If somethings going wrong, use `journalctl -f` to get your system logs. If you are not familiar with Linux and how you can fix issues, we recommend do use our Home Assistant OS.
