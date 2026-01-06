#! /usr/bin/env bash

#################
# VARIABLES
#################

# Log file
LOGFILE="/tmp/config-progress.log"

DNFVERSION="$(readlink $(which dnf))"

#################
# FUNCTIONS
#################

need_reboot()
{
	if [[ ${DNFVERSION} == "dnf-3" ]]
	then
		needs-restarting -r >> "$LOGFILE" 2>&1
		if [[ $? -eq 0 ]]; then
			return 1  # reboot needed
		fi
	fi
	if [[ ${DNFVERSION} == "dnf5" ]]
	then
		dnf needs-restarting -r >> "$LOGFILE" 2>&1
		if [[ $? -eq 0 ]]; then
			return 1  # reboot needed
		fi
	fi
	return 0  # no reboot needed
}

ask_reboot()
{
	echo -n -e "\033[5;33m/\ REBOOT REQUIRED\033[0m\033[33m : Do you want to reboot the system now ? [y/N] : \033[0m"
	read rebootuser
	rebootuser=${rebootuser:-n}
	if [[ ${rebootuser,,} == "y" ]]
	then
		echo -e "\n\033[0;35m Rebooting via systemd ... \033[0m"
		sleep 2
		systemctl reboot
		exit
	fi
}

check_cmd()
{
if [[ $? -eq 0 ]]
then
    	echo -e "\033[32mOK\033[0m"
else
    	echo -e "\033[31mERREUR\033[0m"
fi
}

set_config_value() {
    local file="$1"
    local key="$2"
    local value="$3"

    # Key exists
    if grep -q "^${key}=" "$file"; then
        local current
        current=$(grep "^${key}=" "$file" | cut -d= -f2-)

        if [[ "$current" != "$value" ]]; then
            sed -i "s|^${key}=.*|${key}=${value}|" "$file" >> "$LOGFILE" 2>&1
        fi
    else
        # Key does not exist → add it
        echo "${key}=${value}" | tee -a "$file" >> "$LOGFILE" 2>&1
    fi

    return $?
}

add_pkg()
{
    dnf install -y --nogpgcheck "$1" >> "$LOGFILE" 2>&1
}

add_flatpak()
{
	timeout 300 flatpak install flathub --noninteractive -y "$1" >> "$LOGFILE" 2>&1
}

#################
# MAIN
#################

# Log file info
echo -e "\033[36m"
echo "To follow the progress of updates : tail -f $LOGFILE"
echo -e "\033[0m"

# Date dans le log
echo '-------------------' >> "$LOGFILE"
date >> "$LOGFILE"

# Check if root
if [[ $(id -u) -ne "0" ]]
then
	echo -e "\033[31mERROR\033[0m Run the script with root privileges (su - root or sudo)"
	exit 1;
fi

### DNF CONFIGURATION
echo "01- Checking DNF configuration"

DNF_CONF="/etc/dnf/dnf.conf"

echo -n "- - - max_parallel_downloads : "
set_config_value "$DNF_CONF" "max_parallel_downloads" "10"
check_cmd

echo -n "- - - deltarpm : "
set_config_value "$DNF_CONF" "deltarpm" "false"
check_cmd

echo -n "- - - fastestmirror : "
set_config_value "$DNF_CONF" "fastestmirror" "True"
check_cmd

echo -n "- - - Cache refresh : "
dnf check-update --refresh systemd > /dev/null 2>&1
check_cmd

### RPM UPDATE
echo -n "02- Updating DNF system : "
dnf update -y >> "$LOGFILE" 2>&1
check_cmd

### FLATPAK UPDATE
echo -n "03- Updating FLATPAK system : "
flatpak update --noninteractive >> "$LOGFILE"  2>&1
check_cmd

### FEDORA UPGRADE
echo -n "03- Upgrading the system : "
dnf upgrade -y >> "$LOGFILE"  2>&1
check_cmd

# Check if reboot is needed
if need_reboot
then
    ask_reboot
fi

### REPOSITORY CONFIGURATION
echo "04- Checking repository configuration"

echo -n "- - - Installation RPM Fusion Free : "
add_pkg https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
check_cmd


# Get the nonfree repository (NVIDIA drivers, some codecs)
echo -n "- - - Installation RPM Fusion Nonfree : "
add_pkg https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
check_cmd

# Update everything so it all plays nice together
echo -n "- - - Upgrade group core : "
dnf group upgrade core -y >> "$LOGFILE" 2>&1
check_cmd

echo -n "- - - Cache refresh : "
dnf check-update >> /dev/null 2>&1
check_cmd

# FLATHUB
echo -n "- - - Installation Flathub : "
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo > /dev/null
check_cmd

### VIDEO/AUDIO CONFIGURATION
echo "06- Configuring video/audio codecs"

# Replace the neutered ffmpeg with the real one
echo -n "- - - Swapping ffmpeg : "
dnf swap -y ffmpeg-free ffmpeg --allowerasing > /dev/null 2>&1
check_cmd

# Install all the GStreamer plugins
echo -n "- - - Adding codecs : "
dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} \
  gstreamer1-plugin-openh264 gstreamer1-libav lame\* \
  --exclude=gstreamer1-plugins-bad-free-devel >> "$LOGFILE" 2>&1
check_cmd

# Install multimedia groups
echo -n "- - - Adding multimedia groups : "
dnf group install -y multimedia >> "$LOGFILE" 2>&1
check_cmd

echo -n "- - - Adding sound-and-video groups : "
dnf group install -y sound-and-video >> "$LOGFILE" 2>&1
check_cmd

### FASTER BOOTS
echo "07- Configuration faster boots"

echo -n "- - - Configuration faster boots : "
systemctl disable NetworkManager-wait-online.service >> "$LOGFILE" 2>&1
check_cmd

### INSTALL GNOME TOOLS
echo "08- Checking GNOME components"

gnom_tools=(\
gnome-tweaks \
gnome-extensions-app \
gnome-shell-extension-user-theme \
gnome-shell-extension-dash-to-dock \
gnome-shell-extension-appindicator\
)

for tool in ${gnom_tools[@]}; do
    echo -n "- - - Installing GNOME component $tool : "
    add_pkg "$tool"
    check_cmd  
done

### INSTALL APP
echo "09- Installing app"

echo "- - - Install VSCodium"

echo -n "- - - Add the GPG key of the repository : "
rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg  > /dev/null 2>&1
check_cmd


echo -n "- - - Add VSCodium repository : "
printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h\n" | tee -a /etc/yum.repos.d/vscodium.repo  > /dev/null 2>&1
check_cmd

echo -n "- - - Install VS Codium : "
add_pkg codium
check_cmd

echo -n "- - - Install VLC : "
add_pkg vlc
check_cmd

echo -n "- - - Install nano : "
add_pkg nano
check_cmd

echo -n "- - - Install Bruno : "
add_flatpak com.usebruno.Bruno
check_cmd

echo -n "- - - Install Zen Browser : "
add_flatpak app.zen_browser.zen
check_cmd

### System config
echo "10- Configuring system"

echo -n "- - - Configuring dns : "
bash ./conf_dns.sh >> "$LOGFILE" 2>&1
check_cmd

echo -n "- - - Add shortcuts : "
bash ./conf_shortcuts.sh >> "$LOGFILE" 2>&1
check_cmd

echo -n "- - - Configuring Caps Lock for numbers : "
FR_SYMBOLS="/usr/share/X11/xkb/symbols/fr"
if ! grep -q 'include "mswindows-capslock"' "$FR_SYMBOLS"; then
    sed -i '/include "latin"/a\    include "mswindows-capslock"' "$FR_SYMBOLS" >> "$LOGFILE" 2>&1
fi
check_cmd

echo -n "- - - Enabling sudo password feedback (*) : "
FILE="/etc/sudoers.d/pwfeedback"
echo "Defaults pwfeedback" | sudo tee "$FILE" && sudo chmod 440 "$FILE" > /dev/null 2>&1
check_cmd

### Cleaning install
echo "11- Cleaning install"

# Clean package cache
echo -n "- - - Clean all : "
dnf clean all >> "$LOGFILE" 2>&1
check_cmd

# Remove orphaned packages
echo -n "- - - Autoremove : "
dnf autoremove -y >> "$LOGFILE" 2>&1
check_cmd

echo "12- TODO Manually"
echo "- Import vs code profile"
echo "- Add Zen-browser accounts and extension"

if need_reboot
then
	ask_reboot
fi

exit 0;