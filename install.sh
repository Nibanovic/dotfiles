#!/usr/bin/env bash
#
# Script for installing basic Ubuntu packages and my dotfiles.
# Use with caution.

# Set the colours you can use
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
cyan=$(tput setaf 6)
# Resets the style
reset=$(tput sgr0)

# Color-echo.
# arg $1 = Color
# arg $2 = message
cecho() {
  echo "${1}${2}${reset}"
}
cechon() {
  echo -n "${1}${2}${reset}"
}
echon() {
  echo -e "\n"
}

InstallThis(){
	for pkg in "$@"; do
		sudo DEBIAN_FRONTEND=noninteractive apt install -y "${pkg}" || true;
		sudo dpkg --configure -a || true;
		sudo apt-get autoclean && sudo apt-get clean;
	done
}
InstallThisQuietly(){
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$1" < /dev/null > /dev/null || true
}

echon
cecho "${yellow}" "######################################"
cecho "${yellow}" "#       Running install script...    #"
cecho "${yellow}" "######################################"
echon

ReposInstaller(){
	cecho "${yellow}" "Updating packages..."
	sudo apt-get update -qq || true;
	sudo dpkg --configure -a || true;
	sudo -k sed -i -r 's"enabled=1"enabled=0"' /etc/default/apport # disable crash reporting
	# install basic linux tools
	if ! command -v wget >/dev/null; then
		InstallThisQuietly wget
	fi

	if ! command -v curl > /dev/null; then
		InstallThisQuietly curl
	fi

	if ! command -v gdebi > /dev/null; then
		InstallThisQuietly gdebi
	fi
	
	cecho "${yellow}" "Adding apt repositories..."
	
	# alacritty terminal simulator
	sudo add-apt-repository ppa:aslatter/ppa
}

InstallTerminalSupport(){
	echon
	cecho "${yellow}" "######################################"
	cecho "${yellow}" "#    Installing terminal support...  #"
	cecho "${yellow}" "######################################"
	echon

	InstallThis alacritty tmux
}

Cleanup(){
	sudo apt-get clean && rm -rf -- *.deb* *.gpg* *.py*
	cecho "${green}" "##### Finished and cleaned up. ######"
    	echon
	echo "Note that some of these changes require a logout/restart to take effect."
        cechon "${cyan}" "Restart? (y/n): "
	read -r response
        if [[ "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            sudo shutdown -r now
        fi
}

########################################
########### THE SETUP ##################
########################################
ReposInstaller
InstallTerminalSupport
Cleanup
