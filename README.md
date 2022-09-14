# Wingpanel NordVPN Indicator

unofficial indicator for Pantheon-based desktops made by [José Muñoz](https://josemunoz.dev)

![settings dialog and indicator body on a screenshot](https://raw.githubusercontent.com/jdmg94/wingpanel-indicator-nordvpn/main/assets/screenshot.jpeg)


## Installation

You can install the PPA Repository by running the lines below:

```
curl -s --compressed "https://jdmg94.github.io/ppa/ubuntu/KEY.gpg" | sudo apt-key add -
sudo curl -s --compressed -o /etc/apt/sources.list.d/josemunozdev.list "https://jdmg94.github.io/ppa/ubuntu/josemunozdev.list"
```

After that you should be able to update and install `wingpanel-caffeine` as regular package:

```
sudo apt update
sudo apt install wingpanel-indicator-nordvpn
```

### Installing as .DEB package

Please download [the latest .deb package](https://github.com/jdmg94/wingpanel-indicator-nordvpn/releases) you can install by running:

```
  sudo dpkg -i wingpanel-indicator-nordvpn_<version>_amd64.deb
```


## Building From Source

You'll need the following dependencies:

```
libnotify
libwingpanel-2.0-dev
meson
valac
nordvpn
```

Run `meson` to configure the build environment and then `ninja` to build

```bash
meson build --prefix=/usr
cd build
ninja
```

To install, use `ninja install`

```bash
sudo ninja install
```

Then run `killall io.elementary.wingpanel` to restart