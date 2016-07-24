# SimpleDebianWebserver
A simple Debian bash script to create a basic webserver from a clean Debian 8 Jessie install.

*Note: the script is around version 0.95. I still need to add the automatic backups. The rest is fully functional though.*

I have to install and configure Debian based webservers far to often, but everytime it's the same steps over and over again and that is... boring :(. I did not know how to use bashscripts so creating a script that would save me a lot of time in the long run seemed like a good enough reason to start learning it. If you have any questions, suggestions or comments, let me know!

Please note that this script is made for my use case and that it probably won't be the ideal script for everyone. That being said, I think this script will work for the majority of the basic Debian users like me. If it doesn't, feel free to suggest improvements or changes.

# What does the script do?

- Creates a user with correctly set up SSH folder permissions.
- Installs sudo and adds the user to the sudoers file.
- Replaces the repositories in sources.list.
- Installs and configures a basic firewall (UFW).
- Takes care of its own security updates.
- Installs a well-known webserver (apache2)
- Installs other standard software like php5.
- Installs a comprehensive database server (MariaDB).
- Installs the Let's Encrypt client certbot so TLS will be easier than pie.
- Installs some handy tools like apt-transport-https, (un)zip, and sysstat.

# How to run the script?
Note: connecting with SSH makes pasting things like the SSH-key easier.

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

# To do
The script is fully functional and works like a charm, but I have not added all features I would like. I want to add automated backup of mysql databases before I make it 1.0.

# FAQ
### I installed the script, what now?
You can deploy your website(s)! Below are some steps to help you on your way.

1. Delete the stock Apache index.html (```rm /var/www/html/index.html```)
2. Create a folder for your website (```mkdir /var/www/html/website```)
3. Make sure the DNS of your domain(s) is properly setup. For example:  
   
   A domain.tld server-ip TTL=3600  
   A www.domain.tld server-ip TTL=3600  
4. Create an apache configuration file (```nano /etc/apache2/sites-available/website.conf```) with the following content:  
   
   ```<VirtualHost *:80>```  
      ```ServerName www.domain.tld```  
      ```ServerAlias domain.tld```  
      ```ServerAdmin mail@yourdomain.tld```  
      ```DocumentRoot /var/www/html/website```  

      ```ErrorLog ${APACHE_LOG_DIR}/error.log```  
      ```CustomLog ${APACHE_LOG_DIR}/access.log combined```

5. Add certificates to the website (```certbot --apache```) and choose secure automated setup
6. Activate both the configurations (```a2ensite /etc/apache2/sites-available/website*```)
7. Restart the webserver (```service apache2 restart```)
8. Install your website in /var/www/html/website

### Will this script also run on Ubuntu or other Debian based distributions?
Probably, but I have not tested it. Ubuntu for example comes with UFW already installed but that should not matter much for the script to run properly. Just try it to see if it works :).

### What is backupped to where?
There will be daily local backups of /etc/apache2, etc/ssl, etc/php5, /var/www/html and the MySQL databases to /youruseraccount/backup. From there you can copy or sync them with rsync, syncthing, (s)ftp, scp etc. to your backupserver.
