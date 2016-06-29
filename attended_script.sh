#!/bin/bash

#############################################################################
# Copyright 2016 Sebas Veeke
# 
# This file is part of SimpleDebianWebserver
#
# SimpleDebianWebserver is free software: you can redistribute it and/or 
# modify it under the terms of the GNU Affero General Public License 
# version 3 as published by the Free Software Foundation. 
#
# SimpleDebianWebserver is distributed in the hope that it will be 
# useful,but without any warranty. See the GNU Affero General Public 
# License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with SimpleDebianWebserver. If not, see <http://www.gnu.org/licenses/>
# 
# Contact:
# > e-mail      mail@sebasveeke.nl
# > GitHub      sveeke
#############################################################################



## Colours & markup

red='\033[0;31m'            # Red
lred='\033[1;31m'           # Light red
purple='\033[1;35m'         # Purple
lpurple='\033[0;49;95m'     # Light purple
green='\033[0;32m'          # Green
lgreen='\033[0;49;92m'      # Light lgreen
yellow='\033[1;33m'         # Yellow
lyellow='\033[0;49;93m'     # Light yellow
orange='\033[0;33m'         # Orange
blue='\033[1;36m'           # Blue
white='\033[1;37m'          # White
grey='\033[1;49;30m'        # Grey
nc='\033[0m'                # No color



## BEGINNING SCRIPT

# https://lobste.rs/c/4lfcnm (danielrheath)
set -e # stop the script on errors
set -u # unset variables are an error
set -o pipefail # piping a failed process into a successful one is an arror

# License and introduction
clear
echo
echo -e "${lyellow}
#############################################################################
# Copyright 2016 Sebas Veeke                                                #
#                                                                           #
# This file is part of SimpleDebianWebserver                                #
#                                                                           #
# SimpleDebianWebserver is free software: you can redistribute it and/or    #
# modify it under the terms of the GNU Affero General Public License        #
# version 3 as published by the Free Software Foundation.                   #
#                                                                           #
# SimpleDebianWebserver is distributed in the hope that it will be          #
# useful,but without any warranty. See the GNU Affero General Public        #
# License for more details.                                                 #
#                                                                           #
# You should have received a copy of the GNU Affero General Public License  #
# along with SimpleDebianWebserver. If not, see http://www.gnu.org/licenses #
#                                                                           #
# Contact:                                                                  #
# > e-mail      mail@sebasveeke.nl                                          #
# > GitHub      sveeke                                                      #
#############################################################################${nc}"
echo
echo -e "${white}This script will install and configure a webserver on your Debian 8 server.${nc}"
echo
echo -e "${white}Starting install script in 5 seconds. Press ${lgreen}ctrl + c ${white}to abort.${nc}"

sleep 5



## REQUIREMENTS
echo
echo
echo -e "${lyellow}CHECKING REQUIREMENTS"

# Check if script runs as root
echo -e -n "${white}Script is running as root..."

if [ "$EUID" -ne 0 ]; then
        echo -e "\t\t\t\t\t${white}[${red}NO${white}]${nc}"
        echo
        echo -e "${red}***********************************************************************************
This script should be run as root. Use sudo -s or su root and run the script again.
***********************************************************************************${nc}"
        echo
        exit
fi

echo -e "\t\t\t\t\t${white}[${lgreen}YES${white}]${nc}"

# Check if OS is Debian 8
echo -e -n "${white}Checking version of Debian...${nc}"

VER=$(cat /etc/debian_version)
DEBVER=${VER:0:1}
OS=$(cat /etc/issue)
DIST=${OS::-6}
RELEASE=$(head -n 1 /etc/*-release)

if [[ $DEBVER != "8" ]]; then
        echo -e "\t\t\t\t\t${white}[${red}NO${white}]${nc}"
        echo
        echo -e "${red}**************************************************************************************************
This script can only run on Debian 8, you are running $DIST. 
Please install Debian 8 Jessie first.
**************************************************************************************************${nc}"
        echo
        exit
fi

echo -e "\t\t\t\t\t${white}[${lgreen}OK${white}]${nc}"

# Checking internet connection
echo -e -n "${white}Checking internet connection...${nc}"
wget -q --tries=10 --timeout=20 --spider www.google.com
if [[ $? -eq 0 ]]; then
        echo -e "\t\t\t\t\t${white}[${lgreen}YES${white}]${nc}"
    else
        echo -e "\t\t\t\t\t${white}[${red}NO${white}]${nc}"
        echo
echo -e "${red}******************************************************************************************
This script needs a functioning internet connection. Please connect to the internet first.
******************************************************************************************${nc}"
        echo
        exit
fi



## USER CONFIGURATION ##
echo
echo -e "${lyellow}USER INPUT"
echo -e "${white}The script will gather some information from you.${nc}"
echo
read -p "$(echo -e "${white}Enter your username: "${lgreen})" USER
while true
	do
		read -s -p "$(echo -e "${white}Enter your password: ${nc}")" PASS
        echo
		read -s -p "$(echo -e "${white}Enter your Password (again): ${nc}")" PASS2
		[ "$PASS" = "$PASS2" ] && break
        echo
        echo
        echo -e "${red}*********************************************"
		echo -e "${red}Your passwords don´t match, please try again."
        echo -e "${red}*********************************************"
        echo
	done
echo
echo
read -p "$(echo -e "${white}Enter your public SSH key: "${lgreen})" SSH
echo
echo -e "${white}*****************************************************************************
       Please note that some more user interaction is required later on
*****************************************************************************${nc}"

sleep 5



## REPLACE REPOSITORIES
echo
echo
echo -e "${lyellow}REPLACING REPOSITORIES"
echo -e -n "${white}Updating sources.list...${nc}"

echo "
# Standard repositories
deb http://httpredir.debian.org/debian jessie main contrib
deb-src http://httpredir.debian.org/debian jessie main contrib
deb http://httpredir.debian.org/debian jessie-updates main contrib
deb-src http://httpredir.debian.org/debian jessie-updates main contrib

# Security repositories
deb http://security.debian.org/ jessie/updates main contrib
deb-src http://security.debian.org/ jessie/updates main contrib

# Backport repositories
deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list

echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



# UPDATE OPERATING SYSTEM
echo
echo
echo -e "${lyellow}UPDATING OPERATING SYSTEM"
echo -e "${white}Downloading package list from repositories... ${grey}"
       	apt-get update
echo

echo -e "${white}Downloading and installing new packages...${grey}"
        apt-get -y upgrade

sleep 1



## INSTALLING NEW SOFTWARE
echo
echo
echo -e "${lyellow}INSTALLING SOFTWARE"
echo -e "${white}Note: user interaction required when installing MySQL/MariaDB!"
echo

sleep 2

echo -e "${white}Installing apt-transport-https...${grey}"
        apt-get -y install apt-transport-https
echo

echo -e "${white}Installing aunattended-upgrades...${grey}"
        apt-get -y install unattended-upgrades
        apt-get -y install apt-listchanges
echo

echo -e "${white}Installing ufw...${grey}"
        apt-get -y install ufw
echo

echo -e "${white}Installing sudo...${grey}"
       	apt-get -y install sudo
echo

echo -e "${white}Installing zip...${grey}"
        apt-get -y install zip
echo

echo -e "${white}Installing unzip...${grey}"
        apt-get -y install unzip
echo

echo -e "${white}Installing sysstat...${grey}"
        apt-get -y install sysstat
echo

echo -e "${white}Installing curl...${grey}"
        apt-get -y install curl
echo

echo -e "${white}Installing mariadb-server...${grey}"
        apt-get -y install mariadb-server
echo

echo -e "${white}Installing mariadb-client...${grey}"
        apt-get -y install mariadb-client
echo

echo -e "${white}Installing apache2...${grey}"
        apt-get -y install apache2
echo

echo -e "${white}Installing php5...${grey}"
        apt-get -y install php5
        apt-get -y install php5-mysql
        apt-get -y install php5-gd
echo

echo -e "${white}Installing libapache2-mod-php5...${grey}"
        apt-get -y install libapache2-mod-php5
echo

echo -e "${white}Installing certbot...${grey}"
        apt-get -y install python-certbot-apache -t jessie-backports

sleep 3



## Accounts & SSH
echo
echo

HASH=$(openssl passwd -1 -salt temp $PASS)

echo -e "${lyellow}USER ACCOUNT"

echo -e -n "${white}Creating user account...${nc}"
        useradd $USER -s /bin/bash -m -p $HASH
    echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Creating SSH-folder...${nc}"
        mkdir /home/$USER/.ssh
    echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Adding public key...${nc}"
    echo "$SSH" > /home/$USER/.ssh/authorized_keys
    echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Setting folder and file permissions...${nc}"
        chown $USER:$USER /home/$USER/.ssh
        chown $USER:$USER /home/$USER/.ssh/authorized_keys
        chmod 700 /home/$USER/.ssh
        chmod 600 /home/$USER/.ssh/authorized_keys
    echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Adding user account to sudoers file...${nc}"
echo "
# User privilege specification
$USER   ALL=(ALL:ALL) ALL" >> /etc/sudoers
    echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## CONFIGURING FIREWALL
echo
echo
echo -e "${lyellow}CONFIGURING FIREWALL"

echo -e "${white}Configuring firewall for incoming traffic...${grey}"
        ufw default deny
echo

echo -e "${white}Configuring firewall for ssh traffic...${grey}"
        ufw allow ssh
echo

echo -e "${white}Configuring firewall for http traffic...${grey}"
        ufw allow http
echo

echo -e "${white}Configuring firewall for https traffic...${grey}"
        ufw allow https
echo

echo -e "${white}Activating logging...${grey}"
        ufw logging on
echo

echo -e "${white}Activating firewall...${lgreen}"
	ufw enable

sleep 1



## CONFIGURING UNATTENDED-UPGRADES
echo
echo
echo -e "${lyellow}CONFIGURING UNATTENDED-UPGRADES"
echo -e -n "${white}Adding user to the sudoers file...${nc}"
echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## CONFIGURING WEBSERVER
echo
echo
echo -e -n "${white}Activating apache2 modules...${grey}"
        a2enmod rewrite
        a2enmod actions
        a2enmod ssl
echo

echo -e -n "${white}Restarting webserver...${grey}"
        service apache2 restart
    echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"
sleep 1



## CONFIGURING PHP5
echo
echo
echo -e "${lyellow}CONFIGURING PHP5"
echo -e -n "${white}Adding user to the sudoers file...${nc}"
echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## NOTES
echo
echo
echo
echo
echo -e "${white}
******************************************************************************************************
                                            ${lyellow}IMPORTANT!${white}
******************************************************************************************************

Although you now have a fully functional Debian based web server, you still need to do a few things 
in order to make it more secure.

    1:  You should make sure that you can log in with your newly created user account and private key. 
        If succesfull, disable password authentication so only key authentication is allowed. 

        You can do this by editing /etc/ssh/sshd_config and changing the following two lines:
        - Delete the pound (#) before '#AuthorizedKeysFile      %h/.ssh/authorized_keys'
        - Change '#PasswordAuthentication yes' to 'PasswordAuthentication no' (delete pound + yes>no)

    2:  You should reboot your server in case of updates that require a fresh startup.

        You can do this by using the command 'shutdown -r now' or 'reboot'.


I hope you are happy with your new web server and that it serves you well. If you have any questions
you can post them on https://github.com/sveeke/EasyDebianWebserver/issues/1.

Good luck!

******************************************************************************************************"
sleep 10
echo
echo
exit
