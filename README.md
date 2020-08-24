# This installation method is for advanced users only

## Make sure you understand [the requirements](https://github.com/home-assistant/architecture/blob/master/adr/0014-home-assistant-supervised.md)

# Installation of Home Assistant Supervised

This installation method provides the full Home Assistant experience on a regular operating system. This means, all components from the Home Assistant method are used, except for the Home Assistant Operating System. This system will run the Home Assistant Supervisor. The Supervisor is not just an application, it is a full appliance that manages the whole system. It will clean up, repair or reset settings to default if they no longer match expected values.

By not using the Home Assistant Operating System, the user is responsible for making sure that all required components are installed and maintained. Required components and their versions will change over time. Home Assistant Supervised is provided as-is as a foundation for community supported do-it-yourself solutions. We only accept bug reports for issues that have been reproduced on a freshly installed, fully updated Debian with no additional packages.

This method is considered advanced and should only be used if one is an expert in managing a Linux operating system, Docker and networking.

## Installation

Section 1 provides links to download Debian 10 and information on installation. If you already have Debian 10 installed and wish to move on to installing Home Assistant, proceed to Section 2. 

### Section 1 – Install Debian 10

**1.1)** Start by downloading `debian-live-10.5.0-amd64-standard.iso.torrent` from [HERE](https://cdimage.debian.org/debian-cd/current-live/amd64/bt-hybrid/). This is a torrent file, so use your favourite torrent program. Alternitively, you can download the `debian-live-10.5.0-amd64-standard.iso` ISO from [HERE](https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/).

Some useful infomation on how to install Debian 10 can be found on the Debain website [HERE](https://www.debian.org/releases/stable/installmanual)


### Section 2 – Install Home Assistant Supervised

With Debian 10 installed, you can move on to installing Home Assistant Supervised.

**2.1)** Start by updating Debian to ensure all the latest updates and security patches are installed. To do this, log into the terminal of your machine, enter the following command.

```
sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y
```

Depending on the speed of your internet connection, this could take anywhere from 30 seconds to 20 minutes to complete. When finished, you will see the prompt.

**2.2)** With the operating system up to date, you can install Home Assistant Supervised. Enter each line of the below commands into the terminal and execute them one at a time.

```
sudo -i

apt-get install -y software-properties-common apparmor-utils apt-transport-https avahi-daemon ca-certificates curl dbus jq network-manager socat

systemctl disable ModemManager

systemctl stop ModemManager

curl -fsSL get.docker.com | sh

curl -sL https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh | bash -s
```

**2.3)** The installation time is generally under 5 mins, however it can take longer so be patient. You can check the progress of Home Assistant setup by connecting to the IP address of your machine in Chrome/Firefox on port 8123. (e.g. http://192.168.1.150:8123) 

Once you can see the login screen, the setup has been completed and you can set up an account name and password. You can now configure any smart devices that Home Assistant has automatically discovered on your network. It is recommended that you log into your machine at least once a month to download security patches and keep the OS up to date.

### Command line arguments
| argument           | default                                                                                                                                                                             | description                                            |
|--------------------|----------------------|--------------------------------------------------------|
| -m \| --machine    |                      | On a special platform they need set a machine type use |
| -d \| --data-share | $PREFIX/share/hassio | data folder for hass.io installation                   |
| -p \| --prefix     | /usr                 | Binary prefix for hass.io installation                 |
| -s \| --sysconfdir | /etc                 | Configuration directory for hass.io installation       |

you can set these parameters by appending ` -- <parameter> <value>` like:

```
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
