# This installation method is for advanced users only

## Make sure you understand [the requirements](https://github.com/home-assistant/architecture/blob/master/adr/0014-home-assistant-supervised.md)

# Install Home Assistant Supervised

This installation method provides the full Home Assistant experience on a regular operating system. This means, all components from the Home Assistant method are used, except for the Home Assistant Operating System. This system will run the Home Assistant Supervisor. The Supervisor is not just an application, it is a full appliance that manages the whole system. It will clean up, repair or reset settings to default if they no longer match expected values.

By not using the Home Assistant Operating System, the user is responsible for making sure that all required components are installed and maintained. Required components and their versions will change over time. Home Assistant Supervised is provided as-is as a foundation for community supported do-it-yourself solutions. We only accept bug reports for issues that have been reproduced on a freshly installed, fully updated Debian with no additional packages.

This method is considered advanced and should only be used if one is an expert in managing a Linux operating system, Docker and networking.

## Installation

Run the following commands as root (`su -` or `sudo su -` on machines with sudo installed):

Step 1: Install the following dependencies with this command:

```bash
apt install \
apparmor \
jq \
wget \
curl \
udisks2 \
libglib2.0-bin \
network-manager \
dbus \
lsb-release \
systemd-journal-remote -y
```

Step 2: Install Docker-CE with the following command:

```bash
curl -fsSL get.docker.com | sh
```

Step 3: Install the OS-Agent:

Instructions for installing the OS-Agent can be found [here](https://github.com/home-assistant/os-agent/tree/main#using-home-assistant-supervised-on-debian)

Step 4: Install the Home Assistant Supervised Debian Package:

```bash
wget https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
apt install ./homeassistant-supervised.deb
```

## Supported Machine types

- generic-x86-64
- odroid-c2
- odroid-c4
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
- khadas-vim3

## Configuration

The default path for our `$DATA_SHARE` is `/usr/share/hassio`.
This path is used to store all home assistant related things.

You can reconfigure this path during installation with

```bash
DATA_SHARE=/my/own/homeassistant dpkg --force-confdef --force-confold -i homeassistant-supervised.deb
```

## Troubleshooting

If something's going wrong, use `journalctl -f` to get your system logs. If you are not familiar with Linux and how you can fix issues, we recommend to use our Home Assistant OS.
