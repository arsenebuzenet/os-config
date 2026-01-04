# My Personal Fedora Setup

Automated setup script for configuring a Fedora 43 system with development tools, multimedia support, and essential applications.

This repository is tested on **Fedora 43** for personal installation. Older versions are not tested.

This repo is inspired by:
- <https://github.com/aaaaadrien/fedora-config>
- <https://gist.github.com/yokoffing/3f36b995461c443844a5517fc271ca23>
- <https://github.com/wz790/Fedora-Noble-Setup>

## Overview

The `fedora_setup.sh` script automates the complete setup of a fresh Fedora installation by:
- Configuring package managers (DNF and Flatpak)
- Installing multimedia codecs and video/audio support
- Adding development tools and applications
- Applying system optimizations
- Configuring DNS and keyboard shortcuts

## Prerequisites

- **Fedora 43** installed
- **Root privileges** (must run with `sudo` or as root user)
- **Active internet connection** (for downloading packages)
- **Network Manager** installed (for DNS configuration)

## Usage / Installation

### Quick Start

1. Clone or download this repository:
   ```bash
   cd ~/setup
   ```

2. Run the main setup script with root privileges:
   ```bash
   sudo bash fedora_setup.sh
   ```

3. Monitor the progress with:
   ```bash
   tail -f /tmp/config-progress.log
   ```

### What Each Script Does

- **`fedora_setup.sh`** - Main setup script that handles all system configuration and package installation
- **`conf_dns.sh`** - Configures Quad9 DNS servers (privacy-focused DNS service)
- **`conf_shortcuts.sh`** - Sets up custom keyboard shortcuts (Ctrl+Alt+T for terminal)
- **`test.sh`** - Testing utilities for the setup

## What's Installed

### System Configuration
- DNF package manager optimization (parallel downloads, fastest mirror)
- Flatpak support with Flathub repository
- RPM Fusion repositories (free and non-free)
- System security (sudo password feedback)

### Multimedia Support
- FFmpeg (unrestricted version with all codecs)
- GStreamer plugins (video/audio processing)
- Multimedia and sound-and-video groups
- OpenH264, LAME, and additional codecs

### GNOME Desktop Enhancement
- `gnome-tweaks` - GNOME settings customization
- `gnome-extensions-app` - Extension manager
- `gnome-shell-extension-user-theme` - Custom theme support
- `gnome-shell-extension-dash-to-dock` - Improved dock
- `gnome-shell-extension-appindicator` - System tray integration

### Applications
- **VSCodium** - Open-source code editor (from official repository)
- **VLC** - Multimedia player
- **Bruno** (Flatpak) - API testing tool
- **Zen Browser** (Flatpak) - Privacy-focused web browser

### Performance Optimizations
- Disable NetworkManager wait-online service for faster boot times
- DNF configuration for faster package operations

## Post-Installation

After the script completes, you may need to:
1. Import your VS Code profile (if you have one)
2. Add Zen Browser accounts and extensions
3. Reboot the system (the script will prompt you)

## Troubleshooting

- **Check logs**: Review `/tmp/config-progress.log` for detailed execution logs
- **Reboot required**: If system updates require a reboot, you'll be prompted at the end
- **Failed packages**: Some flatpak installations may fail due to connectivity; they can be installed manually later


## License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

You are free to:
- Use this project for any purpose
- Modify and distribute the code
- Use it commercially or privately
- Include it in other projects

The only requirement is to include a copy of the license with your distribution.
