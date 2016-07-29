# EasyDebianWebserver
A bash script to create a basic reasonably secured webserver from a clean Debian 8 Jessie install - the easy way.

I have to install and configure webservers far to often, but everytime it's the same steps over and over again and that is... boring. I did not know how to use bash scripts so creating a script that would save me a lot of time in the long run seemed like a good enough reason to start learning it. Please note that this script is made for my use case and that it probably won't be the ideal script for everyone. That being said, I think this script will work for the majority of the basic Debian users like me. If it doesn't, feel free to suggest improvements or changes.

If you have any questions, suggestions or comments, let me know!

## What does the script do?

- Creates a user with correctly set up SSH folder permissions.
- Installs sudo and adds the user to the sudoers file.
- Replaces the repositories in sources.list.
- Installs and configures a basic firewall (UFW).
- Takes care of its own security updates.
- Automatically backups files and databases.
- Installs a well-known webserver (apache2)
- Installs other standard software like php5 and MySQL (MariaDB).
- Installs the Let's Encrypt client certbot so TLS will be easier than pie.
- Installs some handy tools like apt-transport-https, (un)zip, and sysstat.

## How to run the script?
*Note: connecting with SSH makes pasting things like the SSH-key a lot easier.*

1. Become root if you are not already.  
   ```su root```
2. Change directory to /tmp or another folder to you liking.  
   ```cd /tmp```
3. Download the file with git, direct link (example below) or copy and paste the content from github over in your text editor.  
   ```wget https://raw.githubusercontent.com/sveeke/easydebianwebserver/master/EasyDebianWebserver.sh```
5. Give proper permissions to the script.  
   ```chmod 700 EasyDebianWebserver.sh```
6. Execute the script and follow the instructions in it.  
   ```./EasyDebianWebserver.sh ```
