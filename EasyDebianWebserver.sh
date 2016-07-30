#!/bin/bash
# Copyright 2016 Sebas Veeke. Released under the AGPLv3 license
# See https://github.com/sveeke/EasyDebianWebserver/blob/master/license.txt
# Source code on GitHub: https://github.com/sveeke/EasyDebianWebserver


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
#set -e # stop the script on errors
#set -u # unset variables are an error
#set -o pipefail # piping a failed process into a successful one is an arror

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
# useful, but without any warranty. See the GNU Affero General Public       #
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
        echo -e "${red}************************************************************************
This script should be run as root. Use su root and run the script again.
************************************************************************${nc}"
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

sleep 1



## USER CONFIGURATION ##
echo
echo -e "${lyellow}USER INPUT"
echo -e "${white}The script will gather some information from you.${nc}"
echo
read -p "$(echo -e "${white}Enter the server's hostname: "${lgreen})" HOSTNAME
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
read -p "$(echo -e "${white}Enter your AuthorizedKeysFile: "${lgreen})" SSH
echo
echo -e "${white}*****************************************************************************
       Please note that some more user interaction is required later on
*****************************************************************************${nc}"

sleep 5



## CHANGING HOSTNAME
echo
echo
echo -e "${lyellow}CHANGING HOSTNAME"
echo -e -n "${white}Modifying /etc/hostname...${nc}"
echo "$HOSTNAME" >> /etc/hostname
echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## REPLACE REPOSITORIES
echo
echo
echo -e "${lyellow}REPLACING REPOSITORIES"
echo -e -n "${white}Modifying sources.list...${nc}"

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

## UPDATE OPERATING SYSTEM
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
echo -e "${white}The following software will be installed:

- apt-transport-https           For using apt with https
- unattended-upgrades           For automatically upgrading Debian with security updates
- ntp                           Network Time Protocol                      
- ufw                           This is an easy to use firewall frontend voor iptables
- sudo                          Allows the user to execute commands as root
- zip                           For making zip archives
- unzip                         For extracting zip archives
- sysstat                       Some handy system performance tools
- curl                          Transfer data in different ways
- mariadb-server                The MySQL based database server
- mariadb-client                The MySQL based database client 
- apache2                       The Apache webserver
- php5                          Popular hypertext preprocessor for dynamic content
- php5-mysql                    PHP5 extention for interaction with mysql
- php5-gd                       PHP5 extention for handling images from php
- libapache2-mod-php5           Integrated php in the apache webserver
- python-certbot-apache         The official Let's Encrypt client


Note: user interaction required when installing MySQL/MariaDB!

Starting in 10 seconds.${grey}"
sleep 10
echo
echo
apt-get -y install apt-transport-https unattended-upgrades ntp ufw sudo zip unzip sysstat curl mariadb-server mariadb-client apache2 php5 php5-mysql php5-gd libapache2-mod-php5
apt-get -y install python-certbot-apache -t jessie-backports



## Accounts & SSH
echo
echo

HASH=$(openssl passwd -1 -salt temp $PASS)

echo -e "${lyellow}USER ACCOUNT"
echo -e -n "${white}Creating user account...${nc}"
        useradd $USER -s /bin/bash -m -U -p $HASH
    echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Creating SSH folder...${nc}"
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
        ufw default deny incoming
echo
echo -e "${white}Configuring firewall for ssh, http and https traffic...${grey}"
        ufw allow ssh
        ufw allow http
        ufw allow https
echo
echo -e "${white}Activating logging...${grey}"
        ufw logging on
echo
echo -e -n "${white}Activating firewall on next boot...${lgreen}"
	sed -i.bak 's/ENABLED=no/ENABLED=yes/g' /etc/ufw/ufw.conf
    chmod 0644 /etc/ufw/ufw.conf
    echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## CONFIGURING UNATTENDED-UPGRADES
echo
echo
echo -e "${lyellow}CONFIGURING UNATTENDED-UPGRADES"
echo -e -n "${white}Activating unattended-upgrades...${nc}"
echo -e "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\n" > /etc/apt/apt.conf.d/20auto-upgrades
echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## CONFIGURING WEBSERVER
echo
echo
echo -e "${lyellow}CONFIGURING WEBSERVER"
echo -e "${white}Activating apache2 modules...${grey}"
        a2enmod rewrite
        a2enmod actions
        a2enmod ssl
echo

echo -e -n "${white}Restarting webserver...${grey}"
        service apache2 restart
    echo -e "\t\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

sleep 1



## BACKUP
echo
echo
echo -e "${lyellow}CONFIGURING AUTOMATIC BACKUP"
echo -e -n "${white}Creating backup folders...${nc}"
        mkdir /home/$USER/backup
        mkdir /home/$USER/backup/script
        mkdir /home/$USER/backup/files
        mkdir /home/$USER/backup/databases
    echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Creating backup script...${nc}"

echo -e "
#!/bin/bash
# Copyright 2016 Sebas Veeke. Released under the AGPLv3 license
# See https://github.com/sveeke/EasyDebianWebserver/blob/master/license.txt
# Source code on GitHub: https://github.com/sveeke/EasyDebianWebserver

### This script will backup folders and MySQL databases. You can modify it to include more folders or change the backup retention. If you want to change the time or frequency you should use crontab -e.

## USER VARIABLES
BACKUP_PATH_FILES='/home/$USER/backup/files'
BACKUP_PATH_SQL='/home/$USER/backup/databases'
BACKUP_FOLDERS='/var/www/html/. /etc/apache2 /etc/ssl /etc/php5' # To add more folders, place the folder path you want to add between the quotation marks below. Make sure the folders are seperated with a space. If you also want to include hidden files, add '/.' to the location.
BACKUP_SQL='/var/lib/mysql/.' # This is the default folder where databases are stored.
RETENTION='14' # Backup retention in number of days



## Set default file permissions
umask 007

## Backup folders
tar -cpzf \$BACKUP_PATH_FILES/backup-daily-$( date '+%Y-%m-%d_%H-%M-%S' ).tar.gz \$BACKUP_FOLDERS

## Backup MySQL databases
# Note: in order to minimize the risk of getting inconsistencies because of pending transactions, apache2 and MySQL will be stopped temporary.
service apache2 stop
sleep 10
service mysql stop
sleep 5
tar -cpzf \$BACKUP_PATH_SQL/backup-daily-$( date '+%Y-%m-%d_%H-%M-%S' ).tar.gz \$BACKUP_SQL
service mysql start
sleep 5
service apache2 start

## Set backup ownership
chown $USER:root /home/$USER/backup/files/*
chown $USER:root /home/$USER/backup/databases/*

## Delete backups older than the RETENTION parameter
find \$BACKUP_PATH_FILES/backup-daily* -mtime +\$RETENTION -type f -delete
find \$BACKUP_PATH_SQL/backup-daily* -mtime +\$RETENTION -type f -delete



### Note: to restore backups use 'tar -xpzf /path/to/backup.tar.gz -C /path/to/place/backup'" > /home/$USER/backup/script/backup-daily.sh

echo "
#!/bin/bash
# Copyright 2016 Sebas Veeke. Released under the AGPLv3 license
# See https://github.com/sveeke/EasyDebianWebserver/blob/master/license.txt
# Source code on GitHub: https://github.com/sveeke/EasyDebianWebserver

### This script will backup folders and MySQL databases. You can modify it to include more folders or change the backup retention. If you want to change the time or frequency you should use crontab -e.

## USER VARIABLES
BACKUP_PATH_FILES='/home/$USER/backup/files'
BACKUP_PATH_SQL='/home/$USER/backup/databases'
BACKUP_FOLDERS='/var/www/html/. /etc/apache2 /etc/ssl /etc/php5' # To add more folders, place the folder path you want to add between the quotation marks below. Make sure the folders are seperated with a space. If you also want to include hidden files, add '/.' to the location.
BACKUP_SQL='/var/lib/mysql/.' # This is the default folder where databases are stored.
RETENTION='180' # Backup retention in number of days



## Set default file permissions
umask 007

## Backup folders
tar -cpzf \$BACKUP_PATH_FILES/backup-weekly-$( date '+%Y-%m-%d_%H-%M-%S' ).tar.gz \$BACKUP_FOLDERS

## Backup MySQL databases
# Note: in order to minimize the risk of getting inconsistencies because of pending transactions, apache2 and MySQL will be stopped temporary.
service apache2 stop
sleep 10
service mysql stop
sleep 5
tar -cpzf \$BACKUP_PATH_SQL/backup-weekly-$( date '+%Y-%m-%d_%H-%M-%S' ).tar.gz \$BACKUP_SQL
service mysql start
sleep 5
service apache2 start

## Set backup ownership
chown $USER:root /home/$USER/backup/files/*
chown $USER:root /home/$USER/backup/databases/*

## Delete backups older than the RETENTION parameter
find \$BACKUP_PATH_FILES/backup-weekly* -mtime +\$RETENTION -type f -delete
find \$BACKUP_PATH_SQL/backup-weekly* -mtime +\$RETENTION -type f -delete



### Note: to restore backups use 'tar -xpzf /path/to/backup.tar.gz -C /path/to/place/backup'" > /home/$USER/backup/script/backup-weekly.sh
echo -e "\t\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Setting folder and file permissions...${nc}"
        chown $USER:root /home/$USER/backup
        chown $USER:root /home/$USER/backup/script
        chown $USER:root /home/$USER/backup/files
        chown $USER:root /home/$USER/backup/databases
        chown $USER:root /home/$USER/backup/script/backup-daily.sh
        chown $USER:root /home/$USER/backup/script/backup-weekly.sh
        chmod 770 /home/$USER/backup
        chmod 770 /home/$USER/backup/script
        chmod 770 /home/$USER/backup/files
        chmod 770 /home/$USER/backup/databases
        chmod 770 /home/$USER/backup/script/backup-daily.sh
        chmod 770 /home/$USER/backup/script/backup-weekly.sh
    echo -e "\t\t\t\t${white}[${lgreen}DONE${white}]${nc}"

echo -e -n "${white}Adding cronjob for backup script...${nc}"
(crontab -l 2>/dev/null; echo "# This cronjob activates the backup_daily.sh script every day at 4:00.
0 4 * * 1-6 /home/$USER/backup/script/backup_daily.sh

# This cronjob activates the backup_weekly.sh script every week on sunday at 4:00.
0 4 * * 0 /home/$USER/backup/script/backup_daily.sh ") | crontab -
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

Although you now have a fully functional Debian based webserver, you still need to do a few things 
in order to make it more secure.

    1:  You should make sure that you can log in with your newly created user account and private key. 
        If succesfull, disable password authentication so only key authentication is allowed. 

        You can do this by editing /etc/ssh/sshd_config and changing the following two lines:
        - Delete the pound (#) before '#AuthorizedKeysFile      %h/.ssh/authorized_keys'
        - Change '#PasswordAuthentication yes' to 'PasswordAuthentication no' (delete pound + yes>no)

    2:  You should reboot your server to enable the hostname, firewall and possibly also kernel updates.

        You can do this by using the command 'shutdown -r now' or 'reboot'.


I hope you are happy with your new webserver and that it serves you well. If you have any questions
you can post them on https://github.com/sveeke/EasyDebianWebserver.

Good luck!

******************************************************************************************************"
echo
echo
exit

