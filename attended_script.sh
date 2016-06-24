
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
lgreen='\033[0;32m'         # lgreen
lgreen='\033[0;49;92m'      # Light lgreen
yellow='\033[1;33m'         # Yellow
lyellow='\033[0;49;93m'     # Light yellow
orange='\033[0;33m'         # Orange
blue='\033[1;36m'           # Blue
white='\033[1;37m'          # White
grey='\033[1;49;30m'        # Grey
nc='\033[0m'                # No color



## Beginning script execution
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



## Requirements
echo
echo
echo -e "${lyellow}CHECKING REQUIREMENTS"

# Check if script runs as root
echo -e -n "${white}Script is running as root..."

if [ "$EUID" -ne 0 ]; then
        echo -e "\t\t\t\t\t${white}[${lred}NO${white}]${nc}"
        echo
        echo -e "${lred}____________________________________________________________________________________
Hi,
This script should be run as root. Use sudo -s or su root and run the script again.
Good luck!
____________________________________________________________________________________${nc}"
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
        echo -e "\t\t\t\t\t${white}[${lred}NO${white}]${nc}"
        echo
        echo -e "${lred}____________________________________________________________________________________
Hi,
This script can only run on Debian 8, you are running $DIST.
Please install Debian 8 Jessie first.
Good Luck!
____________________________________________________________________________________${nc}"
        echo
        exit
fi

echo -e "\t\t\t\t\t${white}[${lgreen}OK${white}]${nc}"

# Checking internet connection
echo -e -n "${white}Connected to the internet...${nc}"
wget -q --tries=10 --timeout=20 --spider www.google.com
if [[ $? -eq 0 ]]; then
        echo -e "\t\t\t\t\t${white}[${lgreen}YES${white}]${nc}"
else
        echo -e "\t\t\t\t\t${white}[${lred}NO${white}]${nc}"
        echo
echo -e "${lred}____________________________________________________________________________________
Hi,
This script needs a functioning internet connection.
Please connect to the internet first.
Good Luck!
____________________________________________________________________________________${nc}"
        echo
        exit
fi

sleep 1



## USER CONFIGURATION ##
echo
echo -e "${lyellow}USER INPUT"
echo -e "${white}The script will gather some information from you.${nc}"
echo
read -p "$(echo -e "${white}Enter your username: "${lpurple})" USER
while true
	do
		read -s -p "$(echo -e "${white}Enter your password: ${nc}")" PASS
        echo
		read -s -p "$(echo -e "${white}Enter your Password (again): ${nc}")" PASS2
		[ "$PASS" = "$PASS2" ] && break
        echo
        echo -e "${lred}---------------------------------------------"
		echo -e "${lred}Your passwords don´t match, please try again."
        echo -e "${lred}---------------------------------------------"
	done
echo
echo
echo
read -p "$(echo -e "${white}Enter your public SSH key: "${lpurple})" SSH
echo
echo -e "${white}During the installation of mysql-server (password) and the setup of the UFW firewall (activation) some more user interaction is required.${nc}"

sleep 5



## Replace mirrors in sources.list
echo
echo
echo -e "${lyellow}REPLACING REPOSITORIES"
echo -e -n "${white}Updating sources.list...${nc}"

echo "
deb http://httpredir.debian.org/debian jessie main contrib non-free
deb-src http://httpredir.debian.org/debian jessie main contrib non-free
deb http://httpredir.debian.org/debian jessie-updates main contrib non-free
deb-src http://httpredir.debian.org/debian jessie-updates main contrib non-free
deb http://security.debian.org/ jessie/updates main contrib non-free
deb-src http://security.debian.org/ jessie/updates main contrib non-free" > /etc/apt/sources.list

echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## Updating OS to the latest version
echo
echo
echo -e "${lblue}UPDATING OPERATING SYSTEM"
echo -e "${lyellow}Downloading package list from repositories... ${nc}"
echo
       	apt-get update
echo

echo -e "${lyellow}Downloading and installing new packages...${nc}"
echo
        apt-get -y upgrade

sleep 1



## Accounts & SSH
echo
echo

HASH=$(openssl passwd -1 -salt temp $PASS)

echo -e "${lyellow}USER ACCOUNTS AND SSH"

echo -e "${lyellow}Creating user account...${nc}"
        useradd $USER -s /bin/bash -m -p $HASH
echo

echo -e "${lyellow}Creating SSH-folder...${nc}"
        mkdir /home/$USER/.ssh
echo

echo -e "${lyellow}Adding public key...${nc}"
        echo "$SSH" > /home/$USER/.ssh/authorized_keys
echo

echo -e "${lyellow}Setting folder and file permissions...${nc}"
        chown $USER:$USER /home/$USER/.ssh
        chown $USER:$USER /home/$USER/.ssh/authorized_keys
        chmod 700 /home/$USER/.ssh
        chmod 600 /home/$USER/.ssh/authorized_keys

sleep 1



## Installing new software
echo
echo
echo -e "${lyellow}INSTALLING SOFTWARE"
echo -e "${lyellow}Installing ufw...${nc}"
        apt-get -y install ufw
echo

echo -e "${lyellow}Installing sudo...${nc}"
       	apt-get -y install sudo
echo

echo -e "${lyellow}Installing zip...${nc}"
        apt-get -y install zip
echo

echo -e "${lyellow}Installing unzip...${nc}"
        apt-get -y install unzip
echo

echo -e "${lyellow}Installing curl...${nc}"
        apt-get -y install curl
echo

echo -e "${lyellow}Installing mariadb-server...${nc}"
        apt-get -y install mariadb-server
echo

echo -e "${lyellow}Installing mariadb-client...${nc}"
        apt-get -y install mariadb-client
echo

echo -e "${lyellow}Installing apache2...${nc}"
        apt-get -y install apache2
echo

echo -e "${lyellow}Installing php5...${nc}"
        apt-get -y install php5
echo

echo -e "${lyellow}Installing libapache2-mod-php5...${nc}"
        apt-get -y install libapache2-mod-php5

sleep 3



## Configuring firewall
echo
echo
echo -e "${lyellow}CONFIGURING FIREWALL"
echo -e "${lyellow}Configuring firewall for incoming traffic...${nc}"
        ufw default deny
echo

echo -e "${lyellow}Configuring firewall for ssh traffic...${nc}"
        ufw allow ssh
echo

echo -e "${lyellow}Configuring firewall for http traffic...${nc}"
        ufw allow http
echo

echo -e "${lyellow}Configuring firewall for https traffic...${nc}"
        ufw allow https
echo

echo -e "${lyellow}Activating logging...${nc}"
        ufw logging on
echo

echo -e "${lyellow}Activating firewall...${nc}"
	ufw enable

sleep 1



## Configuring sudo
echo
echo
echo -e "${lyellow}CONFIGURING SUDO"
echo -e -n "${lyellow}Adding user to the sudoers file...${nc}"
echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## Configuring webserver
echo
echo
echo -e "${lyellow}CONFIGURING WEBSERVER"
echo -e "${lyellow}Creating folders...${nc}"
        mkdir /var/www/html/web
        mkdir /var/www/html/tools
echo

echo -e "${lyellow}Setting folder ownership...${nc}"
        chown www-data:www-data /var/www/html/web
        chown www-data:www-data /var/www/html/tools
echo

echo -e "${lyellow}Activating apache2 modules...${nc}"
        a2enmod rewrite
        a2enmod actions
        a2enmod ssl
echo

echo -e "${lyellow}Modifying apache2.conf for wordpress...${nc}"
echo

echo -e "${lyellow}Restarting webserver...${nc}"
        service apache2 restart

sleep 1
