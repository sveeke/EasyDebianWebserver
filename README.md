# SimpleDebianWebserver
A simple Debian bash script to create a basic webserver from a clean Debian 8 Jessie install.

*Note: the script is around version 0.91. I still need to add the automatic configuration of unattended-upgrades. The rest is fully functional though.*

I have to install and configure Debian based webservers far to often, but everytime it's the same steps over and over again and that is... boring :(. I didn't know how to use bash so creating a script that would save me a lot of time in the long run seemed like a good enough reason to start learning it. If you have any questions, suggestions or comments, let me know!

Please note that this script is made for my use case and that it probably won't be the ideal script for everyone. That being said, I think this script will work for the majority of the basic Debian users like me. If it doesn't, feel free to suggest improvements or changes.

# What does the script do?

- Adds a user with correctly set up SSH folder permissions.
- Installs sudo and adds the user to the sudoers file.
- Replaces the repositories in sources.list.
- Installs and configures a basic firewall (UFW).
- Takes care of its own updates and upgrades.
- Installs a well-known webserver (apache2)
- Installs other standard software like php5.
- Installs a comprehensive database server (MariaDB).
- Installs the Let's Encrypt client certbot so TLS will be easier than pie.
- Installs some handy tools like apt-transport-https, (un)zip, and sysstat.

# How to run the script?
1. Become root if you are not already.  
   ```sudo -s [or] su root```
2. Change directory to /tmp or another folder to you liking.  
   ```cd /tmp```
3. Download the file with git, direct link (example below) or copy and paste the content from github over in your text editor.  
   ```wget https://github.com/sveeke/EasyDebianWebserver/archive/master.zip```
4. Unzip the archived repository.  
   ```unzip master.zip```
5. Give proper permissions to the script.  
   ```chmod 777 installscript.sh```
6. Execute the script and follow the instructions in it.  
   ```./installscript.sh
```

# To do
The script is fully functional and works like a charm, but I have not added all features I would like. I want to add the following things before I make it a version 1.0:

- [ ] Automated backup
- [ ] Automatic configured unattended-upgrades, apt-listchanges and needrestart
