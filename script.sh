#!/bin/bash
#
# Script by Sebas Veeke
# License: GNU General Public License version 3 (GPLv3)
#
# Contact:
# > e-mail      mail@sebasveeke.nl
# > GitHub      sveeke



### USER CONFIGURATION ###

# NETWORK STUFF
HOSTNAME=localhost                      # Hostname of the machine (for example 'webserver.sebasveeke.nl')
FQDN="localhost"                        # Fully Qualified Domain Name (for example 'webserver.sebasveeke.nl ')

# FIRST USERNAME AND PUBLIC SSH KEY
USER1=username1
SSH1="ssh 1234567890"

# SECOND USERNAME AND PUBLIC SSH KEY
USER2=username2
SSH2="ssh 1234567890"

# MYSQL ROOT PASSWORD
MYSQL=password








###############################################################################################

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
DEFAULTPASS=tijdelijk12345



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
echo -e "Starting install script in 5 seconds. Press ctrl + c to abort."
sleep 5



## Requirements
echo
echo
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
wget -q --tries=10 --timeout=20 --spider www.google.com
if [[ $? -eq 0 ]]; then
        echo -e "\t\t\t\t\t${white}[${green}YES${white}]${nc}"
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

sleep 1

## Updating OS to the latest version
echo
echo
echo -e "${blue}UPDATING OPERATING SYSTEM"
echo -e -n "${white}Downloading package list from repositories... ${nc}"
#       apt-get update &>/dev/null
echo -e "\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e -n "${white}Downloading and installing new packages...${nc}"
        apt-get -y upgrade &>/dev/null
echo -e "\t\t\t${white}[${green}DONE${white}]${nc}"

sleep 1

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

sleep 1

## Accounts & SSH
echo
echo

HASH=$(openssl passwd -1 -salt temp $DEFAULTPASS)

echo -e "${blue}USER ACCOUNTS AND SSH"

echo -e -n "${white}Creating account $USER1...${nc}"
        useradd $USER1 -s /bin/bash -m -p $HASH &> /dev/null
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Creating SSH-folder for $USER1...${nc}"
        mkdir /home/$USER1/.ssh &> /dev/null
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Adding public key for $USER1...${nc}"
        echo "SSH1" > /home/$USER1/.ssh/authorized_keys
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Creating account $USER2...${nc}"
        useradd $USER2 -s /bin/bash -m -p $HASH &> /dev/null
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Creating SSH-folder for $USER2...${nc}"
        mkdir /home/$USER2/.ssh &> /dev/null
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Adding public key for $USER2...${nc}"
        echo "$SSH2" > /home/$USER2/.ssh/authorized_keys
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Setting folder and file permissions...${nc}"
        chown $USER1:$USER1 /home/$USER1/.ssh &> /dev/null
        chown $USER1:$USER1 /home/$USER1/.ssh/authorized_keys &> /dev/null
        chmod 700 /home/$USER1/.ssh &> /dev/null
        chmod 600 /home/$USER1/.ssh/authorized_keys &> /dev/null
        chown $USER2:$USER2 /home/$USER2/.ssh &> /dev/null
        chown $USER2:$USER2 /home/$USER2/.ssh/authorized_keys &> /dev/null
        chmod 700 /home/$USER2/.ssh &> /dev/null
        chmod 600 /home/$USER2/.ssh/authorized_keys &> /dev/null
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"
echo -e "${white}___________________________________________________________"
echo
echo -e "${white}*** The default password '${lred}$DEFAULTPASS${white}' is being used ***"
echo -e "${white}___________________________________________________________"

sleep 4

## Installing new software
echo
echo
echo -e "${blue}INSTALLING SOFTWARE"
echo -e -n "${white}Installing ufw...${nc}"
        apt-get -y install ufw &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Installing sudo...${nc}"
#       apt-get -y install sudo &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Installing zip...${nc}"
        apt-get -y install zip &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Installing unzip...${nc}"
        apt-get -y install unzip &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Installing curl...${nc}"
        apt-get -y install curl &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Installing mariadb-server...${nc}"
        export DEBIAN_FRONTEND="noninteractive"
        debconf-set-selections <<< "mariadb-server mysql-server/root_password password $MYSQL"
        debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password $MYSQL"
        apt-get -y install mariadb-server &> /dev/null
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Installing mariadb-client...${nc}"
        apt-get -y install mariadb-client &> /dev/null
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Installing apache2...${nc}"
        apt-get -y install apache2 &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Installing php5...${nc}"
        apt-get -y install php5 &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Installing libapache2-mod-php5...${nc}"
        apt-get -y install libapache2-mod-php5 &> /dev/null
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

sleep 3

## Configuring firewall
echo
echo
echo -e "${blue}CONFIGURING FIREWALL"
echo -e -n "${white}Configuring firewall for ssh traffic...${nc}"
        ufw allow ssh &> /dev/null
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Configuring firewall for http traffic...${nc}"
        ufw allow http &> /dev/null
echo -e "\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Configuring firewall for https traffic...${nc}"
        ufw allow https &> /dev/null
echo -e "\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Activating firewall...${nc}"
#        ufw enable &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

sleep 1

## Configuring sudo
echo
echo
echo -e "${blue}CONFIGURING SUDO"
echo -e -n "${white}Adding $USER1 to the sudoers file...${nc}"
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Adding $USER2 to the sudoers file...${nc}"
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

sleep 1

## Configuring webserver
echo
echo
echo -e "${blue}CONFIGURING WEBSERVER"
echo -e -n "${white}Creating folders...${nc}"
        mkdir /var/www/html/web &> /dev/null
        mkdir /var/www/html/tools &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Setting folder ownership...${nc}"
        chown www-data:www-data /var/www/html/web &> /dev/null
        chown www-data:www-data /var/www/html/tools &> /dev/null
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Activating apache2 modules...${nc}"
        a2enmod rewrite &> /dev/null
        a2enmod actions &> /dev/null
        a2enmod ssl &> /dev/null
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Modifying apache2.conf for wordpress...${nc}"
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Restarting webserver...${nc}"
        service apache2 restart &> /dev/null
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

sleep 1

# Backup

# Set rights

# Restart apache
