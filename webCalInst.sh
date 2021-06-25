#!/bin/bash

# This script installs WebCalendar 1.2.4 on fresh install of Ubuntu Server 20.04.2 LTS. 
# WebCalendar 1.2.4 has the vulnerability CVE:2012-1495 that allows arbitrary code 
# injection as www-data. This exploit is included in Metasploit.

# This challenge has a half setup WebCalendar that is stored in the
# /var/www/html/admin directory. The site admin stored it in admin until they have
# time to complete the configuration. The admin directory can be found with tools such
# as gobuster, dirbuster etc. 

# Writtten by: Joseph Burgess


# Add required repos
add-apt-repository -y ppa:ondrej/php
apt-get -y update

# Install Apache and PHP5
apt-get install -y php5.6 php5.6-mysql php5.6-gd php5.6-mcrypt php5.6-mbstring php5.6-sqlite3 apache2 libapache2-mod-php5.6

# Install MariaDB/MySQL
sudo apt-get install -y mysql-server mysql-client

# Install unzip
apt install -y unzip

# Download WebCalendar
curl -o /tmp/calendar.zip https://www.exploit-db.com/apps/621867c09db9d8afc490ca0fc77dee50-WebCalendar-1.2.4.zip

# Unzip WebCalendar. Moving to /admin so it can found with gobuster and
# other tools.
mkdir /var/www/html/admin
unzip -d /var/www/html/admin/ /tmp/calendar.zip

# Create database, user and set permissions
mysqladmin create intranet
mysql -u root -e "CREATE USER 'webcalendar'@'localhost' IDENTIFIED BY 'password123'"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'webcalendar'@'localhost' WITH GRANT OPTION"
mysql -u root -e "FLUSH PRIVILEGES"

# Build database from WebCalendar sql file
mysql intranet < /var/www/html/admin/WebCalendar-1.2.4/install/sql/tables-mysql.sql

# Configure settings.php file
cp -r /var/www/html/admin/WebCalendar-1.2.4/includes/settings.php.orig settings.php

declare -a fieldArr                                                             
declare -a parArr                                                               
                                                                                
fieldArr=('db_type:' 'db_host:' 'db_login:' 'db_password:' 'db_database:')      
parArr=('mysql' 'localhost' 'webcalendar' 'password123' 'intranet')
                       
for ((i = 0 ; i <= 4 ; i++)); do                                                
sed -i "s/^${fieldArr[i]}.*/${fieldArr[i]} ${parArr[i]}/g" /var/www/html/admin/WebCalendar-1.2.4/includes/settings.php
done   

# Set includes directory permissions
chmod -R 777 /var/www/html/admin/WebCalendar-1.2.4/includes

# Build index.html page with some hints
tee -a /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<body>

<h1>UNDER CONSTRUCTION</h1>
<p>Web Calendar will be coming soon. Please check back later.</p>

<!--
TODO: 
Finish calendar configuration. 
Move settings.php file.
Move calendar directory to html directory.
-->

</body>
</html> 
EOF
