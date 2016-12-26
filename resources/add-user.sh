#!/bin/bash

#############################################################################
# Version 1.0.0-alpha.1 (25-12-2016)
#############################################################################

#############################################################################
# Copyright 2016 Sebas Veeke. Released under the AGPLv3 license
# See https://github.com/sveeke/EasyDebianWebserver/blob/master/license.txt
# Source code on GitHub: https://github.com/sveeke/EasyDebianWebserver
#############################################################################

#############################################################################
# VARIABLES
#############################################################################

# COLOURS AND MARKUP
red='\033[0;31m'            # Red
green='\033[0;49;92m'       # Green
yellow='\033[0;49;93m'      # Yellow
white='\033[1;37m'          # White
grey='\033[1;49;30m'        # Grey
nc='\033[0m'                # No color

#############################################################################
# SYSTEM
#############################################################################

# https://lobste.rs/c/4lfcnm (danielrheath)
set -e # stop the script on errors
set -u # unset variables are an error
set -o pipefail # piping a failed process into a successful one is an arror


#############################################################################
# LICENSE AND INTRODUCTION
#############################################################################

clear
echo
echo -e "${yellow}
#############################################################################
# Copyright 2016 Sebas Veeke. Released under the AGPLv3 license             #
# See https://github.com/sveeke/EasyDebianWebserver/blob/master/license.txt #
# Source code on GitHub: https://github.com/sveeke/EasyDebianWebserver      #
#############################################################################${nc}"

echo
echo -e "${white}This script will setup a new user account on your Debian server. Just fill in the 
requested information and the script will do the rest."
echo
echo -e "${white}Note: press ${green}ctrl + c ${white}to abort.${nc}"

sleep 3


#############################################################################
# CHECKING REQUIREMENTS
#############################################################################

echo
echo
echo -e "${yellow}CHECKING REQUIREMENTS"

# Checking if script runs as root
echo -e -n "${white}Script is running as root..."
	if [ "$EUID" -ne 0 ]; then
        echo -e "\t\t\t\t\t${white}[${red}NO${white}]${nc}"
        echo
        echo -e "${red}************************************************************************"
		echo -e "${red}This script should be run as root. Use su root and run the script again."
		echo -e "${red}************************************************************************${nc}"
        echo
		exit
	fi
echo -e "\t\t\t\t\t${white}[${green}YES${white}]${nc}"

sleep 1


#############################################################################
# USER CONFIGURATION
#############################################################################

echo
echo
echo -e "${yellow}USER INPUT"
echo -e "${white}The script will gather some information from you.${nc}"

# Choose username user account
echo
read -p "$(echo -e "${white}Enter account username:                "${green})" USER

# Choose password user account
while true
	do
		read -s -p "$(echo -e "${white}Enter user account password:           "${nc})" USERPASS
		echo
		read -s -p "$(echo -e "${white}Enter user account Password (again):   "${nc})" USERPASS2
			[ "$USERPASS" = "$USERPASS2" ] && break
			echo
			echo
			echo -e "${red}*********************************************"
			echo -e "${red}Your passwords don´t match, please try again."
			echo -e "${red}*********************************************"
		echo
	done

# Add content of AuthorizedKeysFile
echo
read -p "$(echo -e "${white}Enter AuthorizedKeysFile's content:    "${green})" SSH


#############################################################################
# SETTING UP USER ACCOUNT
#############################################################################

echo
echo
echo -e "${yellow}SETTING UP USER ACCOUNT"

# Hashing the password
echo -e -n "${white}Hashing given password...${nc}"
HASH=$(openssl passwd -1 -salt temp $USERPASS)
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Create the user account with chosen password and its own home directory
echo -e -n "${white}Creating user account...${nc}"
useradd $USER -s /bin/bash -m -U -p $HASH
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Create SSH folder
echo -e -n "${white}Creating SSH folder...${nc}"
mkdir /home/$USER/.ssh
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Add public key to AuthorizedKeysFile
echo -e -n "${white}Adding public key...${nc}"
echo "$SSH" > /home/$USER/.ssh/authorized_keys
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Setting folder and file permissions
echo -e -n "${white}Setting folder and file permissions...${nc}"
chown $USER:$USER /home/$USER/.ssh
chown $USER:$USER /home/$USER/.ssh/authorized_keys
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Adding user to sudo
echo -e -n "${white}Adding user account to sudo...${nc}"
cat << EOF > /etc/sudoers.d/$USER
# User privilege specification
$USER   ALL=(ALL:ALL) ALL
EOF
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"


# Notice
echo
echo
echo -e "${white}*******************************************************************"
echo -e "${white}Account created succesfully. To add another, run this script again."
echo -e "${white}*******************************************************************${nc}"

sleep 1

echo
exit
