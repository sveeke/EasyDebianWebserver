#!/bin/bash

#############################################################################
# Version 1.1.0-alpha.2 (24-12-2016)
#############################################################################

#############################################################################
# Copyright 2016 Sebas Veeke. Released under the AGPLv3 license
# See https://github.com/sveeke/EasyDebianWebserver/blob/master/license.txt
# Source code on GitHub: https://github.com/sveeke/EasyDebianWebserver
#############################################################################

#############################################################################
# INTRODUCTION
# This script will backup relevant folders and MySQL databases. 
# You can modify it to include more folders or change the backup retention. 
# To change the time or frequency, edit /etc/cron.d/automated-backup.
#############################################################################


#############################################################################
# USER VARIABLES
#############################################################################

# The file backups will be stored here.
BACKUP_PATH_FILES='/home/$BACKUPUSER/backup/files'

# The MySQL database backups will be stored here.
BACKUP_PATH_SQL='/home/$BACKUPUSER/backup/databases'

# To add more folders, place the folder path you want to add between the
# quotation marks below. Make sure the folders are seperated with a space.
# If you also want to include hidden files, add '/.' to the location.
BACKUP_FOLDERS='/var/www/html/. /etc/apache2 /etc/ssl /etc/php5'

# This is the default folder where MySQL databases are stored.
BACKUP_SQL='/var/lib/mysql/.'

# Backup retention in number of days.
RETENTION='14'

#############################################################################
# SET DEFAULT FILE PERMISSIONS
#############################################################################

umask 007

#############################################################################
# BACKUP FOLDERS
#############################################################################

tar -cpzf $BACKUP_PATH_FILES/backup-daily-files-$( date '+%Y-%m-%d-%H-%M-%S' ).tar.gz $BACKUP_FOLDERS

#############################################################################
# BACKUP MYSQL DATABASES
#############################################################################

# In order to minimize the risk of getting inconsistencies because of pending 
# transactions, apache2 and MySQL will be stopped temporary.

service apache2 stop
sleep 10
service mysql stop
sleep 5
tar -cpzf $BACKUP_PATH_SQL/backup-daily-sql$( date '+%Y-%m-%d-%H-%M-%S' ).tar.gz $BACKUP_SQL
service mysql start
sleep 5
service apache2 start

#############################################################################
# SET BACKUP OWNERSHIP
#############################################################################

chown $BACKUPUSER:root /home/$BACKUPUSER/backup/files/*
chown $BACKUPUSER:root /home/$BACKUPUSER/backup/databases/*

#############################################################################
# DELETE OLDER BACKUPS
#############################################################################

find $BACKUP_PATH_FILES/backup-daily* -mtime +$RETENTION -type f -delete
find $BACKUP_PATH_SQL/backup-daily* -mtime +$RETENTION -type f -delete

#############################################################################
# RESTORING BACKUPS
# To restore earlier created backups, use the command below:
# tar -xpzf /path/to/backup.tar.gz -C /path/to/place/backup
#############################################################################

