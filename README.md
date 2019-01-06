Note: this project has moved to https://github.com/onnozel/easywebserver. The version in this repository isn't maintained anymore.

# Easy Debian Webserver
You want a reasonably secure webserver based on Debian? Well, you are in luck! This shell script does exactly that.

## Reason
I have to install and configure webservers far too often, but everytime it's the same steps over and over again and that is... boring. Please note that this script is made for my use case and that it may or may not fit your requirements. It won't be the ideal script for everyone. That being said, I think this script will work well for the majority of the basic Debian users like me. If it doesn't, feel free to suggest improvements or changes!

Also, if you have any questions, suggestions or comments, let me know!

## What does it do?
Quite a lot actually! The most important things:

* Installs basic software needed for a complete webserver.
* Creates a user account with correctly set ssh, sudo and folder permissions.
* Creates a backup account with automated daily backups to its home folder.
* Installs and configures a basic firewall.
* Hardens the webserver, SSH, SSL/TLS and MySQL.
* Configures automatic security updates.

For a complete rundown on all the stuff in the script, check the [List of all actions](https://github.com/sveeke/EasyDebianWebserver/wiki/List-of-all-actions).

## Software
Then you might wonder what software will be installed. Below is a short list, check the [wiki](https://github.com/sveeke/EasyDebianWebserver/wiki/Software) for the long list.
Please note that some software is optional, these preferences can be changed in the `USER VARIABLES` section in the top of the script.
* The Apache webserver
* PHP + some extentions (optional)
* MariaDB (optional)
* Let's Encrypt's Certbot for certificates
* Uncomplicated Firewall (UFW)
* Some commonly used software like apt-transport-https, unattended-upgrades, (un)zip, dnsutils, curl etc.

## Requirements
* A clean installation of Debian 8 Jessie or Debian 9 Stretch.
* You must be able to run the script as root.
* The system you are installing this on must have a functioning internet connection and DNS.
* Some free disk space for the packages.

That's all :-).

## How to run the script?
*Note: connecting with SSH makes pasting things like the SSH public key a lot easier.*

1. Become root if you are not already.  
   ```su root```
2. Change directory to a folder to your liking.  
   ```cd /tmp```
3. Download the file with git, direct link (example below) or copy the content from github and paste in nano/vim.  
   ```wget https://raw.githubusercontent.com/sveeke/EasyDebianWebserver/master/EasyDebianWebserver.sh```
5. Give proper permissions to the script.  
   ```chmod 700 EasyDebianWebserver.sh```
6. Execute the script and follow the instructions in it.  
   ```./EasyDebianWebserver.sh ```

## Help and support
Check the [wiki](https://github.com/sveeke/EasyDebianWebserver/wiki) if you have questions or need help. If you still have questions you can post them at [Issues](https://github.com/sveeke/EasyDebianWebserver/issues)'.

## Plans for the future
I would like to incorporate some extra hardening like the Inversoft's hardening [guide](https://www.inversoft.com/guides/2016-guide-to-user-data-security). Some of it is already in the script, but there are still some usefull improvements to be made. This means adding things like:

- libpam-cracklib for strong passwords
- google authenticator for 2FA
- monit for monitoring logins and changes
- Automatically encrypting backups
