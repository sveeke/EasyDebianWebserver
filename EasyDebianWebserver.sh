#!/bin/bash

#############################################################################
# Version 1.1.0-RELEASE (26-08-2017)
#############################################################################

#############################################################################
# Copyright 2016-2017 Sebas Veeke. Released under the AGPLv3 license
# See https://github.com/sveeke/EasyDebianWebserver/blob/master/license.txt
# Source code on GitHub: https://github.com/sveeke/EasyDebianWebserver
#############################################################################

#############################################################################
# USER VARIABLES
#############################################################################

# Harden SSH configuration (/etc/ssh/sshd_config)
# Please note that this can lock you out when no functioning public key 
# has been provided during user creation. Answer can either be yes or no.
HARDEN_SSH='yes'

# Install MySQL and PHP? Answer can either be yes or now.
INSTALL_MYSQL='yes'
INSTALL_PHP='yes'


#############################################################################
# COLOURS AND MARKUP
#############################################################################

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
# Copyright 2016-2017 Sebas Veeke                                           #
#                                                                           #
# This file is part of EasyDebianWebserver                                  #
#                                                                           #
# EasyDebianWebserver is free software: you can redistribute it and/or      #
# modify it under the terms of the GNU Affero General Public License        #
# version 3 as published by the Free Software Foundation.                   #
#                                                                           #
# EasyDebianWebserver is distributed in the hope that it will be            #
# useful, but without any warranty. See the GNU Affero General Public       #
# License for more details.                                                 #
#                                                                           #
# You should have received a copy of the GNU Affero General Public License  #
# along with EasyDebianWebserver. If not, see http://www.gnu.org/licenses   #
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
sleep 1
    if [ "$EUID" -ne 0 ]; then
        echo -e "\\t\\t\\t\\t\\t${white}[${red}NO${white}]${nc}"
        echo
        echo -e "${red}************************************************************************"
	    echo -e "${red}This script should be run as root. Use su root and run the script again."
	    echo -e "${red}************************************************************************${nc}"
        echo
	    exit
    fi
echo -e "\\t\\t\\t\\t\\t${white}[${green}YES${white}]${nc}"

# Checking Debian version
echo -e -n "${white}Running Debian 8 or 9...${nc}"
sleep 1
    if [ -f /etc/debian_version ]; then
        DEBVER=$(cat /etc/debian_version | cut -d '.' -f 1 | cut -d '/' -f 1)

        if [ "$DEBVER" = "8" ] || [ "$DEBVER" = "jessie" ]; then
            echo -e "\\t\\t\\t\\t\\t${white}[${green}YES${white}]${nc}"
            OS='8'

        elif [ "$DEBVER" = "9" ] || [ "$DEBVER" = "stretch" ]; then
            echo -e "\\t\\t\\t\\t\\t${white}[${green}YES${white}]${nc}"
            OS='9'

        else
            echo -e "\\t\\t\\t\\t\\t${white}[${red}NO${white}]${nc}"
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
sleep 1
wget -q --tries=10 --timeout=20 --spider www.google.com
    if [[ $? -eq 0 ]]; then
        echo -e "\\t\\t\\t\\t\\t${white}[${green}YES${white}]${nc}"
    else
        echo -e "\\t\\t\\t\\t\\t${white}[${red}NO${white}]${nc}"
        echo
        echo -e "${red}**********************************************************************"
        echo -e "${red}Internet connection is required, please connect to the internet first."
        echo -e "${red}**********************************************************************${nc}"
        echo
        exit
    fi

sleep 1


#############################################################################
# USER INPUT AND CONFIGURATION
#############################################################################

echo
echo
echo -e "${yellow}USER INPUT"
echo -e "${white}The script will gather some information from you."

# Choose hostname
echo
read -r -p "Enter server's hostname:                            " HOSTNAME

# Choose username backup account
while true
    do
        read -r -p "Enter backup account username:                      " BACKUPUSER
            [ "$BACKUPUSER" != "backup" ] && break
            echo
            echo -e "${red}****************************************************"
            echo -e "${red}User 'backup' is a system account and can't be used."
            echo -e "${red}****************************************************${white}"
        echo
    done

# Choose password backup account
while true
    do
        read -r -s -p "Enter backup account password:                      " BACKUPPASS
        echo
        read -r -s -p "Enter backup account Password (again):              " BACKUPPASS2
            [ "$BACKUPPASS" = "$BACKUPPASS2" ] && break
            echo
            echo
            echo -e "${red}*********************************************"
            echo -e "${red}Your passwords don´t match, please try again."
            echo -e "${red}*********************************************${white}"
        echo
    done

# Check whether the user wants to create a user account
echo
while true
    do
        read -r -p "Add a user account? (yes/no):                       " ADDACCOUNT
            [ "$ADDACCOUNT" = "yes" ] || [ "$ADDACCOUNT" = "no" ] || [ "$ADDACCOUNT" = "y" ] || [ "$ADDACCOUNT" = "n" ] && break
            echo
            echo -e "${red}**************************************************"
            echo -e "${red}Please type yes or no and press enter to continue."
            echo -e "${red}**************************************************${white}"
        echo
    done

## Choose username user account
if [ "$ADDACCOUNT" = "yes" ] || [ "$ADDACCOUNT" = "y" ]; then
    read -r -p "Enter account username:                             " USER

## Choose password user account
while true
    do
        read -r -s -p "Enter user account password:                        " USERPASS
        echo
        read -r -s -p "Enter user account Password (again):                " USERPASS2
            [ "$USERPASS" = "$USERPASS2" ] && break
            echo
            echo
            echo -e "${red}*********************************************"
            echo -e "${red}Your passwords don´t match, please try again."
            echo -e "${red}*********************************************${white}"
        echo
    done

## Add content of AuthorizedKeysFile
    echo
    read -r -p "Enter AuthorizedKeysFile's content:                 " SSH
fi


# Choose MariaDB/MYSQL root password
while true
    do
    read -r -s -p "Enter MariaDB/MySQL root password:                  " MYSQLPASS
        echo
        read -r -s -p "Enter MariaDB/MYSQL root Password (again):          " MYSQLPASS2
            [ "$MYSQLPASS" = "$MYSQLPASS2" ] && break
            echo
            echo
            echo -e "${red}*********************************************"
            echo -e "${red}Your passwords don´t match, please try again."
            echo -e "${red}*********************************************${white}"
        echo
    done

# Tip
echo
echo
echo -e "${white}*******************************************************************************"
echo -e "${white}Tip! Add more user accounts with add-user.sh in the EasyDebianWebserver folder."
echo -e "${white}*******************************************************************************"

sleep 1


#############################################################################
# CHANGE HOSTNAME
#############################################################################

echo
echo
echo -e "${yellow}MODIFYING HOSTNAME"
echo -e "${white}Modifying /etc/hostname...${nc}"
echo "$HOSTNAME" > /etc/hostname

sleep 1


#############################################################################
# REPLACE REPOSITORIES
#############################################################################

echo
echo
echo -e "${yellow}REPLACING REPOSITORIES"
echo -e "${white}Modifying sources.list...${nc}"

if [ "$OS" = "8" ]; then
    wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/master/resources/debian8-sources.list -O /etc/apt/sources.list --no-check-certificate

elif [ "$OS" = "9" ]; then
    wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/master/resources/debian9-sources.list -O /etc/apt/sources.list --no-check-certificate
fi

sleep 1


#############################################################################
# UPDATE OPERATING SYSTEM
#############################################################################

echo
echo

# Update the package list from the Debian repositories
echo -e "${yellow}UPDATING OPERATING SYSTEM"
echo -e "${white}Downloading package list from repositories... ${nc}"
apt update

# Upgrade operating system with new package list
echo
echo -e "${white}Downloading and installing updated packages...${nc}"
apt -y upgrade

sleep 1


#############################################################################
# INSTALL NEW SOFTWARE
#############################################################################

echo
echo
echo -e "${yellow}INSTALLING SOFTWARE"
echo -e "${white}The following software will be installed:

- apt-transport-https            For using apt with https
- unattended-upgrades            For automatically upgrading Debian with security updates
- ntp                            Network Time Protocol                      
- ufw                            This is an easy to use firewall frontend for iptables
- sudo                           Allows the user to execute commands as root
- zip                            For making zip archives
- unzip                          For extracting zip archives
- sysstat                        Some handy system performance tools
- curl                           Transfer data in different ways
- dnsutils                       Frequently used DNS utilities
- apache2                        The Apache webserver
- certbot                        The official Let's Encrypt client

Optional:
- mariadb-server                 The MySQL based database server
- mariadb-client                 The MySQL based database client 
- php                            Popular hypertext preprocessor for dynamic content
- some php extentions            Some widely used PHP extention
- libapache2-mod-php             Integrate php in the apache webserver


Starting in 5 seconds...${nc}"

sleep 5
echo

# Checking choices for install
if [ "$INSTALL_MYSQL" = "yes" ]; then
    MYSQL='mariadb-server mariadb-client'
else
    MYSQL=''
fi

if [ "$INSTALL_PHP" = "yes" ]; then
    PHP5='php5 php5-mysql php5-gd php5-curl libapache2-mod-php5'
    PHP7='php7.0 php7.0-mysql php7.0-gd php7.0-curl libapache2-mod-php7.0'
else
    PHP5=''
    PHP7=''
fi

# Install packages for Debian 8 Jessie
if [ "$OS" = "8" ]; then
    apt -y install apt-transport-https ca-certificates unattended-upgrades ntp ufw sudo zip unzip sysstat curl dnsutils apache2 $MYSQL $PHP5
    apt -y install python-certbot-apache -t jessie-backports

# Install packages for Debian 9 Stretch
elif [ "$OS" = "9" ]; then
    apt -y install apt-transport-https unattended-upgrades ntp ufw sudo zip unzip sysstat curl apache2 python-certbot-apache dnsutils $MYSQL $PHP7
fi

sleep 1


#############################################################################
# SETTING UP BACKUP ACCOUNT
#############################################################################

echo
echo

# Hashing the password
BACKUPHASH=$(openssl passwd -1 -salt temp "$BACKUPPASS")

# Create the backup user account with chosen password and its own home directory
echo -e "${yellow}BACKUP USER ACCOUNT"
echo -e "${white}Creating user account...${nc}"
useradd "$BACKUPUSER" -s /bin/bash -m -U -p "$BACKUPHASH"

# Creating folders within the given backup account's home directory
echo -e "${white}Creating backup folders...${nc}"
mkdir /home/"$BACKUPUSER"/EasyDebianWebserver

# Adding handy scripts and readme to EasyDebianWebserver folder
echo -e "${white}Adding handy scripts...${nc}"
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/master/EasyDebianWebserver.sh -O /home/"$BACKUPUSER"/EasyDebianWebserver/EasyDebianWebserver.sh
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/master/resources/add-user.sh -O /home/"$BACKUPUSER"/EasyDebianWebserver/add-user.sh
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/master/resources/readme -O /home/"$BACKUPUSER"/EasyDebianWebserver/README

# Setting folder and file permissions
echo -e "${white}Setting folder and file permissions...${nc}"
chown -R "$BACKUPUSER":root /home/"$BACKUPUSER"/EasyDebianWebserver
chmod -R 770 /home/"$BACKUPUSER"/EasyDebianWebserver

sleep 1


#############################################################################
# OPTIONAL: SETTING UP USER ACCOUNT
#############################################################################

if [ "$ADDACCOUNT" = "y" ] || [ "$ADDACCOUNT" = "yes" ]; then
echo
echo

# Hashing the password
USERHASH=$(openssl passwd -1 -salt temp "$USERPASS")

# Create the user account with chosen password and its own home directory
echo -e "${yellow}USER ACCOUNT"
echo -e "${white}Creating user account...${nc}"
useradd "$USER" -s /bin/bash -m -U -p "$USERHASH"

# Create SSH folder
echo -e "${white}Creating SSH folder...${nc}"
mkdir /home/"$USER"/.ssh

# Add public key to AuthorizedKeysFile
echo -e "${white}Adding public key...${nc}"
echo "$SSH" > /home/"$USER"/.ssh/authorized_keys

# Adding user to sudo
echo -e "${white}Adding user account to sudo...${nc}"
cat << EOF > /etc/sudoers.d/"$USER"
# User privilege specification
$USER   ALL=(ALL:ALL) ALL
EOF

# Setting folder and file permissions
echo -e "${white}Setting folder and file permissions...${nc}"
chown "$USER":"$USER" /home/"$USER"/.ssh
chown "$USER":"$USER" /home/"$USER"/.ssh/authorized_keys
chown root:root /etc/sudoers.d/"$USER"
chmod 700 /home/"$USER"/.ssh
chmod 600 /home/"$USER"/.ssh/authorized_keys
chmod 440 /etc/sudoers.d/"$USER"

fi

sleep 1


#############################################################################
# OPTIONAL: HARDEN SSH
#############################################################################

if [ "$HARDEN_SSH" = "yes" ]; then
    echo
    echo
    echo -e "${yellow}HARDENING SSH"
    echo -e "${green}***************************************************************************"
    echo -e "${green}Please make sure your public key is added properly before rebooting Debian."
    echo -e "${green}***************************************************************************${white}"
    sleep 3
    echo
    echo -e "${white}Replacing sshd_config...${nc}"
    wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/master/resources/sshd_config -O /etc/ssh/sshd_config

# Adding ed25519 host key to Debian 8 ssh folder
elif [ "$OS" = "8"]; then
    echo -e "${white}Adding ed25519 host key to ssh folder...${nc}"
    ssh-keygen -q -f /etc/ssh/ssh_host_ed25519_key -N "" -t ed25519
fi

systemctl restart sshd

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

# Make logging more usefull on UFW
echo
echo -e "${white}Activating logging...${grey}"
ufw logging on

# UFW isn't activated by default, this activates it
echo
echo -e "${white}Activating firewall on next boot...${green}"
sed -i.bak 's/ENABLED=no/ENABLED=yes/g' /etc/ufw/ufw.conf
chmod 0644 /etc/ufw/ufw.conf

sleep 1


#############################################################################
# CONFIGURE UNATTENDED-UPGRADES
#############################################################################

echo
echo
echo -e "${yellow}CONFIGURING UNATTENDED-UPGRADES"
echo -e "${white}Activating unattended-upgrades...${nc}"
echo -e "APT::Periodic::Update-Package-Lists \"1\";\\nAPT::Periodic::Unattended-Upgrade \"1\";\\n" > /etc/apt/apt.conf.d/20auto-upgrades

sleep 1


#############################################################################
# CONFIGURE WEBSERVER
#############################################################################

echo
echo
echo -e "${yellow}CONFIGURING WEBSERVER"

# Adding hardenend configurations for http security headers and SSL
echo -e "${white}Adding hardened configuration for http security headers...${grey}"
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/master/resources/security.conf -O /etc/apache2/conf-available/security.conf

echo -e "${white}Adding hardenend configuration for TLS/SSL/Let's Encrypt...${grey}"
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/master/resources/options-ssl-apache.conf -O /etc/letsencrypt/options-ssl-apache.conf

# Activate relevant apache2 modules and configurations
echo -e "${white}Activating apache2 modules and configurations...${grey}"
a2enmod rewrite
a2enmod actions
a2enmod ssl
a2enmod headers
a2enconf security.conf
echo

# Restart webserver so changes can take effect
echo -e "${white}Restarting webserver...${grey}"
systemctl restart apache2

sleep 1


#############################################################################
# CONFIGURE MYSQL
#############################################################################

if [ "$OS" = "9" ]; then
    echo
    echo
    echo -e "${yellow}CONFIGURING MYSQL"

    # Harden MariaDB/MYSQL installation
    echo -e "${white}Adding password...${grey}"
    mysql -u root -e "UPDATE mysql.user SET Password=PASSWORD('$MYSQLPASS') WHERE User='root'"

    echo -e "${white}Disallow remote root login...${grey}"
    mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"

    echo -e "${white}Remove anonymous users...${grey}"
    mysql -u root -e "DELETE FROM mysql.user WHERE User=''"

    echo -e "${white}Remove test database and access to it...${grey}"
    mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"

    echo -e "${white}Flushing privileges...${grey}"
    mysql -u root -e "FLUSH PRIVILEGES"

fi

sleep 1


#############################################################################
# CREATE AUTOMATIC BACKUP
#############################################################################

echo
echo
echo -e "${yellow}CONFIGURING AUTOMATIC BACKUP"

# Creating backup folders within the given backup account's home directory
echo -e "${white}Creating backup folders...${nc}"
mkdir -p /home/"$BACKUPUSER"/backup/files /home/"$BACKUPUSER"/backup/databases

# Adding backupscripts to folders
echo -e "${white}Creating backup script...${nc}"
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/master/resources/backup-daily.sh -O /home/"$BACKUPUSER"/backup/backup-daily.sh
wget -q https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/master/resources/backup-weekly.sh -O /home/"$BACKUPUSER"/backup/backup-weekly.sh

# Replacing '$BACKUPUSER' in script with $BACKUPUSER variable value
echo -e "${white}Customizing backup script...${nc}"
sed -i s/'$BACKUPUSER'/"$BACKUPUSER"/g /home/"$BACKUPUSER"/backup/backup-daily.sh
sed -i s/'$BACKUPUSER'/"$BACKUPUSER"/g /home/"$BACKUPUSER"/backup/backup-weekly.sh

# Setting folder and file permissions
echo -e "${white}Setting folder and file permissions...${nc}"
chown -R "$BACKUPUSER":root /home/"$BACKUPUSER"/backup
chmod -R 770 /home/"$BACKUPUSER"/backup

# Add cronjobs for backup scripts
echo -e "${white}Adding cronjob for backup script...${nc}"
cat << EOF > /etc/cron.d/automated-backup
# This cronjob activates the backup_daily.sh script every day at 4:00.
0 4 * * 1-6 root /home/$BACKUPUSER/backup/backup-daily.sh

# This cronjob activates the backup-weekly.sh script every week on sunday at 4:00.
0 4 * * 0 root /home/$BACKUPUSER/backup/backup-weekly.sh
EOF

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

            README and handy scripts:            /home/$BACKUPUSER/EasyDebianWebserver
            Weekly and daily backup scripts:     /home/$BACKUPUSER/backup
            The archived file backups:           /home/$BACKUPUSER/backup/files
            The archived database backups:       /home/$BACKUPUSER/backup/databases
            File with backup cronjobs:           /etc/cron.d/automated-backup
            Sudo file from optional account:     /etc/sudoers.d/$USER

    3.	${yellow}FIREWALL${white}
        UFW is a very user friendly frond-end for Debian's firewall. A comprehensive list of commands
        can be found in the README. Some examples to get you started:

            List all rules:                      sudo ufw status
            List all rules numbered:             sudo ufw status numbered
            List all rules verbose:              sudo ufw status verbose
            Enable firewall:                     sudo ufw enable
            Disable firewall:                    sudo ufw disable
            Allow incoming traffic on udp+tcp:   sudo ufw allow [port] (i.e. 1000)
            Allow incoming traffic on proto:     sudo ufw allow [port]/[proto] (i.e. 1000/tcp)
            Delete firewall rule:                sudo ufw delete [rule number]

        Note that UFW is not active yet. It will be automatically enabled when you restart your server.

    4. 	${yellow}REBOOT SERVER!${white}
        You should reboot the server to enable the new hostname, firewall and pending kernel updates.
        Do this by running one of the following commands:

            'shutdown -r now' or 'reboot'.

    I hope you are happy with your new webserver and that it serves you (and others ;) well. If you
    have any questions you can post them on https://github.com/sveeke/EasyDebianWebserver/issues.

******************************************************************************************************
                                            ${yellow}GOOD LUCK!${white}
******************************************************************************************************"
echo
echo
exit
