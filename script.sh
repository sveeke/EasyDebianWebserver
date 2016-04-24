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
echo -e "${grey}
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
        echo -e "\t\t\t\t\t${white}[${red}NO${white}]${nc}"
        echo
        echo -e "${white}____________________________________________________________________________________
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
        echo -e "\t\t\t\t\t${white}[${red}NO${white}]${nc}"
        echo
        echo -e "${white}____________________________________________________________________________________
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
        echo -e "\t\t\t\t\t${white}[${red}NO${white}]${nc}"
        echo
echo -e "${white}____________________________________________________________________________________
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
read -p "$(echo -e "${grey}Enter your username: "${lpurple})" USER
while true
	do
		read -s -p "$(echo -e "${grey}Enter your password: ${nc}")" PASS
        echo
		read -s -p "$(echo -e "${grey}Enter your Password (again): ${nc}")" PASS2
		[ "$PASS" = "$PASS2" ] && break
        echo
        echo -e "${lred}---------------------------------------------"
		echo -e "${lred}Your passwords don´t match, please try again."
        echo -e "${lred}---------------------------------------------"
	done
echo
echo
while true
	do
		read -s -p "$(echo -e "${grey}Enter your MySQL root password: "${nc})" MYSQL
		echo
		read -s -p "$(echo -e "${grey}Enter your MySQL root password (again): "${nc})" MYSQL2
		[ "$MYSQL" = "$MYSQL2" ] && break
		echo
        echo -e "${lred}---------------------------------------------"
		echo -e "${lred}Your passwords don´t match, please try again."
        echo -e "${lred}---------------------------------------------"
	done
echo
read -p "$(echo -e "${grey}Enter your public SSH key: "${lpurple})" SSH
echo

sleep 1



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
deb-src http://security.debian.org/ jessie/updates main contrib non-free" > /home/script/sources.list

echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## Updating OS to the latest version
echo
echo
echo -e "${lyellow}UPDATING OPERATING SYSTEM"
echo -e -n "${white}Downloading package list from repositories... ${nc}"
#       apt-get update &>/dev/null
echo -e "\t\t\t${white}[${lgreen}DONE${white}]${nc}"
echo -e -n "${white}Downloading and installing new packages...${nc}"
        apt-get -y upgrade &>/dev/null
echo -e "\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## Accounts & SSH
echo
echo

HASH=$(openssl passwd -1 -salt temp $PASS)

echo -e "${lyellow}USER ACCOUNTS AND SSH"

echo -e -n "${white}Creating user account...${nc}"
        useradd $USER -s /bin/bash -m -p $HASH &> /dev/null
echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Creating SSH-folder...${nc}"
        mkdir /home/$USER/.ssh &> /dev/null
echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Adding public key...${nc}"
        echo "$SSH" > /home/$USER/.ssh/authorized_keys &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Setting folder and file permissions...${nc}"
        chown $USER:$USER /home/$USER/.ssh &> /dev/null
        chown $USER:$USER /home/$USER/.ssh/authorized_keys &> /dev/null
        chmod 700 /home/$USER/.ssh &> /dev/null
        chmod 600 /home/$USER/.ssh/authorized_keys &> /dev/null
echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## Installing new software
echo
echo
echo -e "${lyellow}INSTALLING SOFTWARE"
echo -e -n "${white}Installing ufw...${nc}"
        apt-get -y install ufw &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Installing sudo...${nc}"
       	apt-get -y install sudo &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Installing zip...${nc}"
        apt-get -y install zip &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Installing unzip...${nc}"
        apt-get -y install unzip &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Installing curl...${nc}"
        apt-get -y install curl &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Installing mariadb-server...${nc}"
        export DEBIAN_FRONTEND="noninteractive"
        debconf-set-selections <<< "mariadb-server mysql-server/root_password password $MYSQL"
        debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password $MYSQL"
        apt-get -y install mariadb-server &> /dev/null
echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Installing mariadb-client...${nc}"
        apt-get -y install mariadb-client &> /dev/null
echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Installing apache2...${nc}"
        apt-get -y install apache2 &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Installing php5...${nc}"
        apt-get -y install php5 &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Installing libapache2-mod-php5...${nc}"
        apt-get -y install libapache2-mod-php5 &> /dev/null
echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 3



## Configuring firewall
echo
echo
echo -e "${lyellow}CONFIGURING FIREWALL"
echo -e -n "${white}Configuring firewall for incoming traffic...${nc}"
        ufw default deny &> /dev/null
echo -e "\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Configuring firewall for ssh traffic...${nc}"
        ufw allow ssh &> /dev/null
echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Configuring firewall for http traffic...${nc}"
        ufw allow http &> /dev/null
echo -e "\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Configuring firewall for https traffic...${nc}"
        ufw allow https &> /dev/null
echo -e "\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Activating logging...${nc}"
        ufw logging on &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Activating firewall...${nc}"
#	ufw enable &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## Configuring sudo
echo
echo
echo -e "${lyellow}CONFIGURING SUDO"
echo -e -n "${white}Adding user to the sudoers file...${nc}"
echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## Configuring webserver
echo
echo
echo -e "${lyellow}CONFIGURING WEBSERVER"
echo -e -n "${white}Creating folders...${nc}"
        mkdir /var/www/html/web &> /dev/null
        mkdir /var/www/html/tools &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Setting folder ownership...${nc}"
        chown www-data:www-data /var/www/html/web &> /dev/null
        chown www-data:www-data /var/www/html/tools &> /dev/null
echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Activating apache2 modules...${nc}"
        a2enmod rewrite &> /dev/null
        a2enmod actions &> /dev/null
        a2enmod ssl &> /dev/null
echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Modifying apache2.conf for wordpress...${nc}"
echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Restarting webserver...${nc}"
        service apache2 restart &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



# Backup

# Set rights

# Restart apache
