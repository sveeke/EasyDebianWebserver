#!/bin/bash

#############################################################################
# Version 1.1.0-alpha.6 (10-07-2017)
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
#set -e # stop the script on errors
#set -u # unset variables are an error
#set -o pipefail # piping a failed process into a successful one is an arror

#############################################################################
# LICENSE AND INTRODUCTION
#############################################################################

clear
echo
echo -e "${yellow}
#############################################################################
# Copyright 2016 Sebas Veeke                                                #
#                                                                           #
# This file is part of EasyDebianWebserver                                #
#                                                                           #
# EasyDebianWebserver is free software: you can redistribute it and/or    #
# modify it under the terms of the GNU Affero General Public License        #
# version 3 as published by the Free Software Foundation.                   #
#                                                                           #
# EasyDebianWebserver is distributed in the hope that it will be          #
# useful, but without any warranty. See the GNU Affero General Public       #
# License for more details.                                                 #
#                                                                           #
# You should have received a copy of the GNU Affero General Public License  #
# along with EasyDebianWebserver. If not, see http://www.gnu.org/licenses #
#                                                                           #
# Contact:                                                                  #
# > e-mail      mail@sebasveeke.nl                                          #
# > GitHub      sveeke                                                      #
#############################################################################${nc}"

echo
echo -e "${white}This script will install and configure a webserver on your Debian machine.${nc}"
echo
echo -e "${white}Press ${green}ctrl + c ${white}during the script to abort.${nc}"

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

# Checking Debian version
echo -e -n "${white}Running Debian 8 or 9...${nc}"
    if [ -f /etc/debian_version ]; then
        DEBVER=$(cat /etc/debian_version | cut -d '.' -f 1 | cut -d '/' -f 1)

        if [ "$DEBVER" = "8" ] || [ "$DEBVER" = "jessie" ]; then
            echo -e "\t\t\t\t\t${white}[${green}YES${white}]${nc}"
            OS='8'
            sleep 2

        elif [ "$DEBVER" = "9" ] || [ "$DEBVER" = "stretch" ]; then
            echo -e "\t\t\t\t\t${white}[${green}YES${white}]${nc}"
            OS='9'
            sleep 2

        else
            echo -e "\t\t\t\t\t${white}[${red}NO${white}]${nc}"
            echo
            echo -e "${red}**********************************************************************"
            echo -e "${red}This script will only work on Debian 8 (Jessie) or Debian 9 (Stretch)."
            echo -e "${red}**********************************************************************${nc}"
            echo
            exit 1
        fi
    fi

# Checking internet connection
echo -e -n "${white}Connected to the internet...${nc}"
wget -q --tries=10 --timeout=20 --spider www.google.com
    if [[ $? -eq 0 ]]; then
        echo -e "\t\t\t\t\t${white}[${green}YES${white}]${nc}"
    else
        echo -e "\t\t\t\t\t${white}[${red}NO${white}]${nc}"
        echo
        echo -e "${red}**********************************************************************"
        echo -e "${red}Internet connection is required, please connect to the internet first."
        echo -e "${red}**********************************************************************${nc}"
        echo
        exit
    fi

sleep 1


#############################################################################
# USER CONFIGURATION
#############################################################################

echo
echo -e "${yellow}USER INPUT"
echo -e "${white}The script will gather some information from you.${nc}"

# Choose hostname
echo
read -p "$(echo -e "${white}Enter server's hostname:               		"${green})" HOSTNAME

# Choose username backup account
while true
    do
        read -p "$(echo -e "${white}Enter backup account username:         		"${green})" BACKUPUSER
            [ "$BACKUPUSER" != "backup" ] && break
            echo
            echo -e "${red}****************************************************"
            echo -e "${red}User 'backup' is a system account and can't be used."
            echo -e "${red}****************************************************"
        echo
    done

# Choose password backup account
while true
    do
        read -s -p "$(echo -e "${white}Enter backup account password:         		"${nc})" BACKUPPASS
        echo
        read -s -p "$(echo -e "${white}Enter backup account Password (again): 		"${nc})" BACKUPPASS2
            [ "$BACKUPPASS" = "$BACKUPPASS2" ] && break
            echo
            echo
            echo -e "${red}*********************************************"
            echo -e "${red}Your passwords don´t match, please try again."
            echo -e "${red}*********************************************"
        echo
    done

# Check whether the user wants to create another account
echo
while true
    do
        read -p "$(echo -e "${white}Add another user account? (yes/no):    		"${green})" ADDACCOUNT
            [ "$ADDACCOUNT" = "yes" ] || [ "$ADDACCOUNT" = "no" ] || [ "$ADDACCOUNT" = "y" ] || [ "$ADDACCOUNT" = "n" ] && break
            echo
            echo -e "${red}**************************************************"
            echo -e "${red}Please type yes or no and press enter to continue."
            echo -e "${red}**************************************************"
        echo
    done

## Choose username user account
if [ "$ADDACCOUNT" = "yes" ] || [ "$ADDACCOUNT" = "y" ]; then
    read -p "$(echo -e "${white}Enter account username:                		"${green})" USER

## Choose password user account
while true
    do
        read -s -p "$(echo -e "${white}Enter user account password:           		"${nc})" USERPASS
        echo
        read -s -p "$(echo -e "${white}Enter user account Password (again):   		"${nc})" USERPASS2
            [ "$USERPASS" = "$USERPASS2" ] && break
            echo
            echo
            echo -e "${red}*********************************************"
            echo -e "${red}Your passwords don´t match, please try again."
            echo -e "${red}*********************************************"
        echo
    done

## Add content of AuthorizedKeysFile
    echo
    read -p "$(echo -e "${white}Enter AuthorizedKeysFile's content:    		"${green})" SSH
fi

echo
echo -e "${white}****************************************************************************************"
echo -e "${white}Tip! add more user accounts later on with add-user.sh in the EasyDebianWebserver folder."
echo -e "${white}****************************************************************************************"

# Choose MariaDB/MYSQL root password
read -s -p "$(echo -e "${white}Enter MariaDB/MySQL root password:         		"${nc})" MYSQLPASS
    echo
    read -s -p "$(echo -e "${white}Enter MariaDB/MYSQL root Password (again): 		"${nc})" MYSQLPASS2
        [ "$MYSQLPASS" = "$MYSQLPASS2" ] && break
        echo
        echo
        echo -e "${red}*********************************************"
        echo -e "${red}Your passwords don´t match, please try again."
        echo -e "${red}*********************************************"
    echo

sleep 3


#############################################################################
# CHANGE HOSTNAME
#############################################################################

echo
echo
echo -e "${yellow}CHANGING HOSTNAME"
echo -e -n "${white}Modifying /etc/hostname...${nc}"
echo "$HOSTNAME" > /etc/hostname
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

sleep 1


#############################################################################
# REPLACE REPOSITORIES
#############################################################################

echo
echo
echo -e "${yellow}REPLACING REPOSITORIES"
echo -e -n "${white}Modifying sources.list...${nc}"

if [ "$OS" = "8" ]; then
    wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/Release-1.1/resources/debian8-sources.list -O /etc/apt/sources.list --no-check-certificate
    echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

elif [ "$OS" = "9" ]; then
    wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/Release-1.1/resources/debian9-sources.list -O /etc/apt/sources.list --no-check-certificate
    echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"
fi

sleep 1


#############################################################################
# UPDATE OPERATING SYSTEM
#############################################################################

echo
echo

# Update the package list from the Debian repositories
echo -e "${yellow}UPDATING OPERATING SYSTEM"
echo -e "${white}Downloading package list from repositories... ${grey}"
apt update

# Upgrade operating system with new package list
echo
echo -e "${white}Downloading and installing new packages...${grey}"
apt -y upgrade

sleep 1


#############################################################################
# INSTALL NEW SOFTWARE
#############################################################################

echo
echo
echo -e "${yellow}INSTALLING SOFTWARE"
echo -e "${white}The following software will be installed:

- apt-transport-https       	For using apt with https
- unattended-upgrades        	For automatically upgrading Debian with security updates
- ntp                       	Network Time Protocol                      
- ufw                      		This is an easy to use firewall frontend for iptables
- sudo                     		Allows the user to execute commands as root
- zip                      		For making zip archives
- unzip                    		For extracting zip archives
- sysstat                  		Some handy system performance tools
- curl                      	Transfer data in different ways
- mariadb-server          		The MySQL based database server
- mariadb-client         		The MySQL based database client 
- apache2                  		The Apache webserver
- php                     		Popular hypertext preprocessor for dynamic content
- Some php extentions    		Some widely used PHP extention
- libapache2-mod-php      		Integrate php in the apache webserver
- python-certbot-apache			The official Let's Encrypt client

Starting in 10 seconds...${grey}"

sleep 10
echo
echo

# Install packages for Debian 8 Jessie
if [ "$OS" = "8" ]; then
    apt-get -y install apt-transport-https ca-certificates unattended-upgrades ntp ufw sudo zip unzip sysstat curl mariadb-server mariadb-client apache2 php5 php5-mysql php5-gd php5-curl libapache2-mod-php5
    apt-get -y install python-certbot-apache -t jessie-backports

# Install packages for Debian 9 Stretch
elif [ "$OS" = "9" ]; then
    apt-get -y install apt-transport-https unattended-upgrades ntp ufw sudo zip unzip sysstat curl mariadb-server mariadb-client apache2 php7.0 php7.0-mysql php7.0-gd php7.0-curl libapache2-mod-php7.0 python-certbot-apache
fi

sleep 1


#############################################################################
# SETTING UP BACKUP ACCOUNT
#############################################################################

echo
echo

# Hashing the password
BACKUPHASH=$(openssl passwd -1 -salt temp $BACKUPPASS)

# Create the backup user account with chosen password and its own home directory
echo -e "${yellow}BACKUP USER ACCOUNT"
echo -e -n "${white}Creating user account...${nc}"
useradd $BACKUPUSER -s /bin/bash -m -U -p $BACKUPHASH
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Creating folders within the given backup account's home directory
echo -e -n "${white}Creating backup folders...${nc}"
mkdir /home/$BACKUPUSER/EasyDebianWebserver
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Adding handy scripts and readme to EasyDebianWebserver folder
echo -e -n "${white}Adding handy scripts...${nc}"
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/Release-1.1/EasyDebianWebserver.sh -O /home/$BACKUPUSER/EasyDebianWebserver/EasyDebianWebserver.sh
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/Release-1.1/resources/add-user.sh -O /home/$BACKUPUSER/EasyDebianWebserver/add-user.sh
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/Release-1.1/resources/readme -O /home/$BACKUPUSER/EasyDebianWebserver/README
echo -e "\t\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Setting folder and file permissions
echo -e -n "${white}Setting folder and file permissions...${nc}"
chown -R $BACKUPUSER:root /home/$BACKUPUSER/EasyDebianWebserver
chmod -R 770 /home/$BACKUPUSER/EasyDebianWebserver
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

sleep 1


#############################################################################
# OPTIONAL: SETTING UP USER ACCOUNT
#############################################################################

if [ "$ADDACCOUNT" = "y" ] || [ "$ADDACCOUNT" = "yes" ]; then
echo
echo

# Hashing the password
USERHASH=$(openssl passwd -1 -salt temp $USERPASS)

# Create the user account with chosen password and its own home directory
echo -e "${yellow}USER ACCOUNT"
echo -e -n "${white}Creating user account...${nc}"
useradd $USER -s /bin/bash -m -U -p $USERHASH
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Create SSH folder
echo -e -n "${white}Creating SSH folder...${nc}"
mkdir /home/$USER/.ssh
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Add public key to AuthorizedKeysFile
echo -e -n "${white}Adding public key...${nc}"
echo "$SSH" > /home/$USER/.ssh/authorized_keys
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Adding user to sudo
echo -e -n "${white}Adding user account to sudo...${nc}"
cat << EOF > /etc/sudoers.d/$USER
# User privilege specification
$USER   ALL=(ALL:ALL) ALL
EOF
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Setting folder and file permissions
echo -e -n "${white}Setting folder and file permissions...${nc}"
chown $USER:$USER /home/$USER/.ssh
chown $USER:$USER /home/$USER/.ssh/authorized_keys
chown root:root /etc/sudoers.d/$USER
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys
chmod 440 /etc/sudoers.d/$USER
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

fi

sleep 1


#############################################################################
# CONFIGURE FIREWALL
#############################################################################

echo
echo
echo -e "${yellow}CONFIGURING FIREWALL"

# Deny incoming traffic by default
echo -e "${white}Configuring firewall for incoming traffic...${grey}"
ufw default deny incoming

# Allow ssh (22), http (80) and http (443) traffic through the firewall
echo
echo -e "${white}Configuring firewall for ssh, http and https traffic...${grey}"
ufw limit ssh
ufw allow http
ufw allow https
echo

# Make logging more usefull on UFW
echo -e "${white}Activating logging...${grey}"
ufw logging on

# UFW isn't activated by default, this activates it
echo
echo -e -n "${white}Activating firewall on next boot...${green}"
sed -i.bak 's/ENABLED=no/ENABLED=yes/g' /etc/ufw/ufw.conf
chmod 0644 /etc/ufw/ufw.conf
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

sleep 1


#############################################################################
# CONFIGURE UNATTENDED-UPGRADES
#############################################################################

echo
echo
echo -e "${yellow}CONFIGURING UNATTENDED-UPGRADES"
echo -e -n "${white}Activating unattended-upgrades...${nc}"
echo -e "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\n" > /etc/apt/apt.conf.d/20auto-upgrades
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

sleep 1


#############################################################################
# CONFIGURE WEBSERVER
#############################################################################

echo
echo
echo -e "${yellow}CONFIGURING WEBSERVER"

# Activate relevant apache2 modules
echo -e "${white}Activating apache2 modules...${grey}"
a2enmod rewrite
a2enmod actions
a2enmod ssl
echo

# Restart webserver so changes can take effect
echo -e -n "${white}Restarting webserver...${grey}"
service apache2 restart
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

sleep 1


#############################################################################
# CONFIGURE MYSQL
#############################################################################

echo
echo
echo -e "${yellow}CONFIGURING MYSQL"

# Harden MariaDB/MYSQL installation
echo -e -n "${white}Adding password...${grey}"
mysql -u root -e "UPDATE mysql.user SET Password=PASSWORD('$MYSQLPASS') WHERE User='root'"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Disallow remote root login...${grey}"
mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Remove anonymous users...${grey}"
mysql -u root -e "DELETE FROM mysql.user WHERE User=''"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Remove test database and access to it...${grey}"
mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

echo -e -n "${white}Flushing privileges...${grey}"
mysql -u root -e "FLUSH PRIVILEGES"
echo -e "\t\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

sleep 1


#############################################################################
# CREATE AUTOMATIC BACKUP
#############################################################################

echo
echo
echo -e "${yellow}CONFIGURING AUTOMATIC BACKUP"

# Creating backup folders within the given backup account's home directory
echo -e -n "${white}Creating backup folders...${nc}"
mkdir -P /home/$BACKUPUSER/backup/files /home/$BACKUPUSER/backup/databases
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Adding backupscripts to folders
echo -e -n "${white}Creating backup script...${nc}"
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/Release-1.1/resources/backup-daily.sh -O /home/$BACKUPUSER/backup/backup-daily.sh
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/Release-1.1/resources/backup-weekly.sh -O /home/$BACKUPUSER/backup/backup-weekly.sh
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Replacing '$BACKUPUSER' in script with $BACKUPUSER variable value
echo -e -n "${white}Customizing backup script...${nc}"
sed -i s/'$BACKUPUSER'/$BACKUPUSER/g /home/$BACKUPUSER/backup/backup-daily.sh
sed -i s/'$BACKUPUSER'/$BACKUPUSER/g /home/$BACKUPUSER/backup/backup-weekly.sh
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Setting folder and file permissions
echo -e -n "${white}Setting folder and file permissions...${nc}"
chown -R $BACKUPUSER:root /home/$BACKUPUSER/backup
chmod -R 770 /home/$BACKUPUSER/backup
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Add cronjobs for backup scripts
echo -e -n "${white}Adding cronjob for backup script...${nc}"
cat << EOF > /etc/cron.d/automated-backup
# This cronjob activates the backup_daily.sh script every day at 4:00.
0 4 * * 1-6 /home/$BACKUPUSER/backup/backup-daily.sh

# This cronjob activates the backup-weekly.sh script every week on sunday at 4:00.
0 4 * * 0 /home/$BACKUPUSER/backup/backup-weekly.sh
EOF
echo -e "\t\t\t\t${white}[${green}DONE${white}]${nc}"

sleep 1


#############################################################################
# NOTES
#############################################################################

echo
echo
echo
echo
echo -e "${white}
******************************************************************************************************
                                            ${yellow}IMPORTANT!${white}
******************************************************************************************************

Although you now have a fully functional Debian based webserver, you still need to reboot 
in order to make it more secure. Below is some additional information on your new server.

	1.	${yellow}README${white}
		A README file and some scripts to help you on your way can be found in:

			/home/$BACKUPUSER/EasyDebianWebserver

	2. 	${yellow}FILE LAYOUT${white}
		Since a lot of different file locations are being used by all the modifications from this
		script, finding them can be quite cumbersome. Therefore I wrote an overview below.

			README and handy scripts:			/home/$BACKUPUSER/EasyDebianWebserver
			Weekly and daily backup scripts:	/home/$BACKUPUSER/backup
			The archived file backups:			/home/$BACKUPUSER/backup/files
			The archived database backups:		/home/$BACKUPUSER/backup/databases
			Sources.list						/etc/apt/sources.list
			File with cronjobs:					/etc/cron.d/automated-backup
			Sudo file from optional account:	/etc/sudoers.d/$USER

	3.	${yellow}FIREWALL${white}
		UFW is a very user friendly frond-end for Debian's firewall. A comprehensive list of commands 
		can be found in the README. Some examples to get you started:
		
			List all rules:						sudo ufw status
			List all rules numbered:			sudo ufw status numbered
			List all rules verbose:				sudo ufw status verbose
			Enable firewall:					sudo ufw enable
			Disable firewall:					sudo ufw disable
			Allow incoming traffic on udp+tcp:	sudo ufw allow [port] (i.e. 1000)
			Allow incoming traffic on proto:	sudo ufw allow [port]/[proto] (i.e. 1000/tcp)
			Delete firewall rule:				sudo ufw delete [rule number]

		Note that UFW is not active yet. It will be automatically enabled when you restart your server. 

	4. 	${yellow}REBOOT SERVER!${white}
		You should reboot the server to enable the new hostname, firewall and pending kernel updates.
		Do this by running one of the following commands:

			'shutdown -r now' or 'reboot'.

I hope you are happy with your new webserver and that it serves you (and others ;) well. If you have 
any questions you can post them on https://github.com/sveeke/EasyDebianWebserver/issues.

Good luck!

******************************************************************************************************"
echo
echo
exit
