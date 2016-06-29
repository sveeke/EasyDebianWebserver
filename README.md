# SimpleDebianWebserver
A simple Debian bashscript to create a basic webserver from a clean Debian 8 Jessie install.

Note: the script is around version 0.91. I still need to add the automatic configuration of unattended-upgrades. The rest is fully functional though.

I have to install and configure Debian based webservers far to often, but everytime it's the same steps over and over again and that is... boring :(. I didn't know how to use bash so creating a script that would save me a lot of time in the long run seemed like a good enough reason to start learning it. If you have any questions, suggestions or comments, let me know!

Please note that this script is made for my use case and that it probably won't be the ideal script for everyone. That being said, I think this script will work for the majority of the basic Debian users like me. If it doesn't, feel free to suggest improvements or changes.

# What does the script do?

It:
- adds a user with correctly set up SSH folder permissions.
- installs sudo and adds the user to the sudoers file.
- replaces the repositories in sources.list.
- installs and configures a basic firewall (UFW).
- takes care of its own updates and upgrades.
- installs a well-known webserver (apache2)
- installs other standard software like php5.
- installs a comprehensive database server (MariaDB).
- It installs the Let's Encrypt client certbot so TLS will be easier than pie.
- It installs some handy tools like apt-transport-https, (un)zip, and sysstat.

# How to get the script?
You have a couple of options:

1) Download the script with Git.
2) Unzip 'wget https://github.com/sveeke/EasyDebianWebserver/archive/master.zip' after downloading.
Of course you can use git 

# How to run the script?
Just execute the following commands in the same folder where you have stored the installscript.sh file:

```sudo -s [or] su root (if you are not root)
chmod 777 installscript.sh
./installscript.sh```



TO DO

- Edit SSHD_Config
- Backup ?
- unattendedupgrades
- apt-listchanges
- needrestart

