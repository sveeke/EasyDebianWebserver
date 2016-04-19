b#!/bin/bash
#
# Script by Sebas Veeke
# License: GNU General Public License version 3 (GPLv3)
#
# Contact:
# > e-mail: mail@sebasveeke.nl
# > GitHub: sveeke

## User input
HOSTNAME=localhost                      # Hostname of the machine
FQDN=localhost                          # Fully Qualified Domain Name

USER1=username1                         # Username of the first user
USER2=username2                         # Username of the second user

MYSQLPW=tijdelijk12345                  # Password for the mysql database



## Colours & markup

red='\033[0;31m'        # Red
lred='\033[1;31m'       # Lightred
purple='\033[1;35m'     # Purple
green='\033[0;32m'      # Green
yellow='\033[1;33m'     # Yellow
orange='\033[0;33m'     # Orange
blue='\033[1;36m'       # Blue
white='\033[1;37m'      # White
nc='\033[0m'            # No color

## Variables


## Beginning script execution
clear
echo
echo
echo -e "${yellow}This script will install and configure a webserver on your Debian 8 server."
echo
echo -e "***********************************************"
echo -e "Created by Sebas Veeke"
echo -e "Licensed under the GNU Public License version 3"
echo -e "***********************************************"
echo
echo -e "Starting install script now..."
echo
echo



## Requirements
echo -e "${blue}CHECKING REQUIREMENTS"



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

echo -e "\t\t\t\t\t${white}[${green}YES${white}]${nc}"

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

echo -e "\t\t\t\t\t${white}[${green}OK${white}]${nc}"

# Checking internet connection
echo -e -n "${white}Connected to the internet...${nc}"
echo -e "\t\t\t\t\t${white}[${green}YES${white}]${nc}"



## Network stuff
echo
echo
echo -e "${blue}NETWORK SETTINGS"
echo -e -n "${white}Changing hostname...${nc}"
        echo "$hostname" > /home/script/hostname
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Changing FQDN...${nc}"
        echo "$FQDN" > /home/script/fqdn
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"



## Accounts & SSH
echo
echo
echo -e "${blue}USER ACCOUNTS AND SSH"
echo -e -n "${white}Creating account $USER1...${nc}"
        useradd $USER1 -s /bin/bash -m -p '$1$yvcdUC8L$ARfnP8AA4Cqy7DbJfJ4YX0'
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Creating SSH-folder for $USER1...${nc}"
        mkdir /home/$USER1/.ssh
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Adding public key for $USER1...${nc}"
        echo "ssh 1234567890" > /home/$USER1/.ssh/authorized_keys
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Creating account $USER2...${nc}"
        useradd $USER2 -s /bin/bash -m -p '$1$yvcdUC8L$ARfnP8AA4Cqy7DbJfJ4YX0'
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Creating SSH-folder for $USER2...${nc}"
        mkdir /home/$USER2/.ssh
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Adding public key for $USER2 $account1...${nc}"
        echo "ssh 1234567890" > /home/$USER2/.ssh/authorized_keys
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Setting folder and file permissions...${nc}"
        chown -R $USER1:$USER1 /home/$USER1/*
        chmod 700 /home/$USER1/.ssh
        chmod 600 /home/$USER1/.ssh/*
        chown -R $USER2:$USER2 /home/$USER2/*
        chmod 700 /home/$USER2/.ssh
        chmod 600 /home/$USER2/.ssh/*
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e "${white}_____________________________________________________________"
echo
echo -e "${white}*** The default passwords '${lred}tijdelijk12345${white}' are being used ***"
echo -e "${white}_____________________________________________________________"



## Replace mirrors in sources.list
echo
echo
echo -e "${blue}REPLACING REPOSITORIES"
echo -e -n "${white}Updating sources.list...${nc}"

echo "
deb http://httpredir.debian.org/debian jessie main contrib non-free
deb-src http://httpredir.debian.org/debian jessie main contrib non-free

deb http://httpredir.debian.org/debian jessie-updates main contrib non-free
deb-src http://httpredir.debian.org/debian jessie-updates main contrib non-free

deb http://security.debian.org/ jessie/updates main contrib non-free
deb-src http://security.debian.org/ jessie/updates main contrib non-free" > /home/script/sources.list

echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"



## Updating OS to the latest version
echo
echo
echo -e "${blue}UPDATING OPERATING SYSTEM"
echo -e -n "${white}Downloading package list from repositories... ${nc}"
#apt-get update &>/dev/null
echo -e "\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Downloading and installing new packages...${nc}"
#apt-get -y upgrade &>/dev/null
echo -e "\t\t\t${white}[${green}DONE${white}]${nc}"



## Installing new software
echo
echo
echo -e "${blue}INSTALLING NEW SOFTWARE"
echo -e -n "${white}Installing zip...${nc}"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Installing unzip...${nc}"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Installing sudo...${nc}"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Installing curl...${nc}"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Installing ufw...${nc}"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Installing mariadb-server...${nc}"
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Installing mariadb-client...${nc}"
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Installing apache2...${nc}"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Installing php5...${nc}"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Installing libapache2-mod-php5...${nc}"
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"



## Configuring webserver
echo
echo
echo -e "${blue}CONFIGURING WEBSERVER"
echo -e -n "${white}Restarting webserver...${nc}"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Activating module mod_rewrite...${nc}"
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Modifying apache2.conf for wordpress...${nc}"
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"




## Configuring firewall
echo
echo
echo -e "${blue}CONFIGURING FIREWALL"
echo -e -n "${white}Configuring firewall for ssh traffic...${nc}"
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Configuring firewall for http traffic...${nc}"
echo -e "\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Configuring firewall for https traffic...${nc}"
echo -e "\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Activating firewall...${nc}"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
