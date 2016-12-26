#!/bin/bash

#############################################################################
# Version 1.1.0-alpha.4 (26-12-2016)
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
echo -e "${white}This script will install and configure a webserver on your Debian server.${nc}"
echo
echo -e "${white}Starting install script in 5 seconds. Press ${green}ctrl + c ${white}to abort.${nc}"

sleep 5


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
		DEBVER=`cat /etc/debian_version | cut -d '.' -f 1 | cut -d '/' -f 1`

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
		echo -e "${red}******************************************************************************************"
		echo -e "${red}This script needs a functioning internet connection. Please connect to the internet first."
		echo -e "${red}******************************************************************************************${nc}"
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
read -p "$(echo -e "${white}Enter server's hostname:               "${green})" HOSTNAME

# Choose username backup account
read -p "$(echo -e "${white}Enter backup account username:         "${green})" BACKUPUSER

# Choose password backup account
while true
	do
		read -s -p "$(echo -e "${white}Enter backup account password:         "${nc})" BACKUPPASS
		echo
		read -s -p "$(echo -e "${white}Enter backup account Password (again): "${nc})" BACKUPPASS2
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
		read -p "$(echo -e "${white}Add another user account? (yes/no):    "${green})" ADDACCOUNT
			[ "$ADDACCOUNT" = "yes" ] || [ "$ADDACCOUNT" = "no" ] || [ "$ADDACCOUNT" = "y" ] || [ "$ADDACCOUNT" = "n" ] && break
			echo
			echo -e "${red}**************************************************"
			echo -e "${red}Please type yes or no and press enter to continue."
			echo -e "${red}**************************************************"
		echo
	done

## Choose username user account
if [ "$ADDACCOUNT" = "yes" ] || [ "$ADDACCOUNT" = "y" ]; then
	read -p "$(echo -e "${white}Enter account username:                "${green})" USER

## Choose password user account
	while true
		do
			read -s -p "$(echo -e "${white}Enter user account password:           "${nc})" USERPASS
			echo
			read -s -p "$(echo -e "${white}Enter user account Password (again):   "${nc})" USERPASS2
				[ "$BACKUPPASS" = "$BACKUPPASS2" ] && break
				echo
				echo
				echo -e "${red}*********************************************"
				echo -e "${red}Your passwords don´t match, please try again."
				echo -e "${red}*********************************************"
			echo
		done

## Add content of AuthorizedKeysFile
	echo
	read -p "$(echo -e "${white}Enter AuthorizedKeysFile's content:    "${green})" SSH
fi

echo
echo -e "${white}*******************************************************************************************"
echo -e "${white}Add more user accounts later on with /home/[backup account]/EasyDebianWebserver/add-user.sh"
echo -e "${white}*******************************************************************************************"

sleep 3

	
# Notice
echo
echo
echo -e "${white}*****************************************************************************"
echo -e "${white}Please note that some more user interaction is required when installing MySQL"
echo -e "${white}Just sit back and relax some while the script installs everything :-)."
echo -e "${white}*****************************************************************************${nc}"

sleep 5


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
	wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/Release-1.1/resources/debian8-sources.list -O /etc/apt/sources.list
	echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

elif [ "$OS" = "9" ]; then
	wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/Release-1.1/resources/debian9-sources.list -O /etc/apt/sources.list
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
apt-get update

# Upgrade operating system with new package list
echo
echo -e "${white}Downloading and installing new packages...${grey}"
apt-get -y upgrade

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
- Some php extentions    		PHP extention for interaction with mysql, handling images etc.
- libapache2-mod-php      		Integrate php in the apache webserver
- python-certbot-apache			The official Let's Encrypt client

Note: user interaction required when installing MySQL/MariaDB!

Starting in 10 seconds...${grey}"

sleep 10
echo
echo

# Install packages for Debian 8 Jessie
if [ "$OS" = "8" ]; then
	apt-get -y install apt-transport-https unattended-upgrades ntp ufw sudo zip unzip sysstat curl mariadb-server mariadb-client apache2 php5 php5-mysql php5-gd libapache2-mod-php5
	apt-get -y install python-certbot-apache -t jessie-backports

# Install packages for Debian 9 Stretch
elif [ "$OS" = "9" ]; then
	apt-get -y install apt-transport-https unattended-upgrades ntp ufw sudo zip unzip sysstat curl mariadb-server mariadb-client apache2 php7.0 php7.0-mysql php7.0-gd libapache2-mod-php7.0 python-certbot-apache
fi

sleep 1


#############################################################################
# SETTING UP BACKUP ACCOUNT
#############################################################################

echo
echo

# Hashing the password
HASH=$(openssl passwd -1 -salt temp $BACKUPPASS)

# Create the backup user account with chosen password and its own home directory
echo -e "${yellow}BACKUP USER ACCOUNT"
echo -e -n "${white}Creating user account...${nc}"
useradd $BACKUPUSER -s /bin/bash -m -U -p $HASH
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Creating backup folders within the given backup account's home directory
echo -e -n "${white}Creating backup folders...${nc}"
mkdir /home/$BACKUPUSER/EasyDebianWebserver
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"

# Adding handy scripts to EasyDebianWebserver folder
echo -e -n "${white}Creating backup script...${nc}"
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/Release-1.1/resources/backup-daily.sh -O /home/$BACKUPUSER/backup/backup-daily.sh
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/Release-1.1/resources/backup-weekly.sh -O /home/$BACKUPUSER/backup/backup-weekly.sh
echo -e "\t\t\t\t\t${white}[${green}DONE${white}]${nc}"



sleep 1


#############################################################################
# OPTIONAL: SETTING UP USER ACCOUNT
#############################################################################

if [ "$ADDACOUNT" = "y" ] || [ "$ADDACCOUNT" = "yes" ]; then
echo
echo

# Hashing the password
HASH=$(openssl passwd -1 -salt temp $USERPASS)

# Create the user account with chosen password and its own home directory
echo -e "${yellow}USER ACCOUNT"
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
ufw allow ssh
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
# CREATE AUTOMATIC BACKUP
#############################################################################

echo
echo
echo -e "${yellow}CONFIGURING AUTOMATIC BACKUP"

# Creating backup folders within the given backup account's home directory
echo -e -n "${white}Creating backup folders...${nc}"
mkdir /home/$BACKUPUSER/backup
mkdir /home/$BACKUPUSER/backup/files
mkdir /home/$BACKUPUSER/backup/databases
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
chown $BACKUPUSER:root /home/$BACKUPUSER/backup
chown $BACKUPUSER:root /home/$BACKUPUSER/backup/files
chown $BACKUPUSER:root /home/$BACKUPUSER/backup/databases
chown $BACKUPUSER:root /home/$BACKUPUSER/backup/backup-daily.sh
chown $BACKUPUSER:root /home/$BACKUPUSER/backup/backup-weekly.sh
chmod 770 /home/$BACKUPUSER/backup
chmod 770 /home/$BACKUPUSER/backup/files
chmod 770 /home/$BACKUPUSER/backup/databases
chmod 770 /home/$BACKUPUSER/backup/backup-daily.sh
chmod 770 /home/$BACKUPUSER/backup/backup-weekly.sh
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

