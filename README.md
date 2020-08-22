# This installation method is for advanced users only

## Make sure you understand [the requirements](https://github.com/home-assistant/architecture/blob/master/adr/0014-home-assistant-supervised.md)

# Install Home Assistant Supervised

This installation method provides the full Home Assistant experience on a regular operating system. This means, all components from the Home Assistant method are used, except for the Home Assistant Operating System. This system will run the Home Assistant Supervisor. The Supervisor is not just an application, it is a full appliance that manages the whole system. It will clean up, repair or reset settings to default if they no longer match expected values.

By not using the Home Assistant Operating System, the user is responsible for making sure that all required components are installed and maintained. Required components and their versions will change over time. Home Assistant Supervised is provided as-is as a foundation for community supported do-it-yourself solutions. We only accept bug reports for issues that have been reproduced on a freshly installed, fully updated Debian with no additional packages.

This method is considered advanced and should only be used if one is an expert in managing a Linux operating system, Docker and networking.

## Installation

If you are new to Home Assistant, you can now proceed to Section 1 if you need assistance with installing Debian 10. If you already have Debian 10 installed and wish to move on to installing Home Assistant, proceed to Section 2. 

### Section 1 – Install Debian

<details>
  <summary>If you would like a step by step guide on how to install Debian 10 to your machine, click here to expand for instructions</summary>


**1.1)** Start by downloading `debian-live-10.5.0-amd64-standard.iso.torrent` from [HERE](https://cdimage.debian.org/debian-cd/current-live/amd64/bt-hybrid/). This is a torrent file, so use your favourite torrent program.

**1.2)** While Debian is downloading, you will need some other programs to help with the setup and installation. To burn the Debian ISO image to a USB thumb drive, you will use a program called Rufus which can be downloaded from [HERE](https://rufus.ie/). 

**1.3)** You will now create a bootable USB drive using Rufus and the Debian image you have downloaded. Insert a blank USB drive of at least 8gb into your PC, open Rufus and choose your USB from the drop-down menu. Now select the Debian ISO image you downloaded, and click Start. If you get any prompts, select OK or Yes to continue. When this has completed, you can move on.

**1.4)** Insert the USB you have just made into the new machine, connect a monitor, Ethernet cable, keyboard and mouse, and power on the machine. You will need to select the USB drive as the boot device, to do this, you will need to press something like F12 or DEL on your keyboard immediately when the machine is powered on.

**1.5)**	The first screen you should be able to select from is **Main Menu**, on this screen, select **Graphical Debian Installer**

**1.6)**	Next will be **Language**. Choose your language and click continue.

**1.7)**	Next will be **Select your location**. Choose your country and click continue.

**1.8)**	Next will be **Configure the keyboard**. Select your keyboard type and click continue. The installer will now perform some automated tasks which will take 1-2 minutes.

**1.9)**	Next will be **Configure the network**. Here you can name your machine, the default name will be `debian`. Choose a name and click continue. You can skip the next page by clicking continue as you do not need to set a domain name. 

**1.10)**	Next will be **Set up users and passwords**. You will be asked to create a password for the root user. Make a note of the password you choose here, and click continue.

**1.11)**	Next will be **Set up users and passwords** again. Enter a username, click continue and on the next screen, enter a password for this user account. Make note of both of these, you will need them later.

**1.12)**	Next will be **Configure the clock**. Select the correct time zone and click continue.

**1.13)**	Next will be **Partition Disks**. Select **Guided - use entire disk** and then click continue. On the next screen make sure the correct disk is selected and click continue. On the next screen select **All files in one partition** and click continue. On the next screen, make sure **Finish partitioning and write changes to disk** is selected, and click continue. On the next screen, select **Yes** and then click continue. The installer will now perform some automated tasks. This will take 1-2 mins.

**1.14)**	Next will be **Configure the package manager**. Select **No** and click continue. Select your Country and click continue. You can leave the default selection **deb.debian.org** selected and click continue. Leave the next page blank and click continue. The installer will now perform some automated tasks. This will take a few minutes.

**1.15)**	Next will be **Install the GRUB bootloader**. Select **Yes** and click continue. Now select the drive you are installing Debian on, and click continue. The installer will now perform some automated tasks. This will take 1-2 mins and then installation will be complete.

**1.16)** In Debian, your user will not be a member of the sudo group so cannot run administrative commands. After the system has rebooted, log in as the root user and the password you set during **Step 1.10.** To add your user to the sudo group enter this command, and press Enter. 

```
usermod -aG sudo username
```

where *username* is the one you setup during **Step 1.11**

**1.17)**	Log out of the root account by pressing ctrl-d on your keyboard then to login to the machine using the username and password you created in **Step 1.11**.

**1.18)**	Before you start installing Home Assistant Supervised, you will need to update the operating system. Enter this command, and press enter.

```
sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y
```

**1.19)**	Once this has completed, you will need to find the IP address of the machine. You can do this by checking your router, or by typing this command into the terminal.

```
ip a
```

You should now see some information on your screen showing network configuration. You are looking for information like `inet 192.168.1.150/24`, or, `inet 10.1.1.50/24` depending on your network setup. This is the IP of the machine and you can now use this to connect to the machine from another PC.
</details>

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

Once you can see the login screen, the setup has been completed and you can set up an account name and password. You can now configure any smart devices that Home Assistant has automatically discovered on your network. It is recommended that you log into your machine at least once a month and use the following command to download security patches and keep the OS up to date.

```
sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove –y
```

To do this, you can use use the official **Terminal and SSH** add-on available in the add-ons store of the Supervisor panel in Home Assistant, or execute from the terminal of the machine.

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
