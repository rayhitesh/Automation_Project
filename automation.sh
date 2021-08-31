#!/bin/bash

#perform an update of the package details
sudo apt update -y;

#check apache2 installed or not
dpkg -s apache2 &> /dev/null

if [ $? -eq 0 ]
then
        echo "apache2 is installed"
else
        echo "apache2 not installed"
        echo "Installing apache2 server on this machine....."
        #install apache2
        sudo apt install -y apache2
fi

#checl apache2 service in runninng/enabled
service apache2 status &> /dev/null
if [ $? -eq 0 ];
then
        echo "apache2 service running......"
else
        echo "apache2 service in not running....."
        echo "starting the apache2 ....."
        #start apache2 service
        sudo /etc/init.d/apache2 start
fi

#create archive (.tar) file of the webserver logs
d=$(date '+%d%m%Y-%H%M%S')
tar cvf /tmp/hitesh-httpd-log-$d.tar  /var/log/apache2/*.log

s3_bucket=upgrad-hitesh

aws s3 cp /tmp/hitesh-httpd-log-$d.tar s3://$s3_bucket/hitesh-httpd-log-$d.tar

log_type=$( ls -lah /tmp/hitesh-httpd-log-$d.tar|awk '{ print $9 }'|cut -c 13-21 )
date_created=$( ls -lah /tmp/hitesh-httpd-log-$d.tar|awk '{ print $9 }'|cut -c 23-37 )
file_type=$( ls -lah /tmp/hitesh-httpd-log-$d.tar|awk '{ print $9 }'|cut -c 39- )
file_size=$( ls -lah /tmp/hitesh-httpd-log-$d.tar|awk '{ print $5 }' )

ls /var/www/html/inventory.html &>/dev/null
if [ $? -eq 0 ];
then
        echo "inventory.html file already exist......"
        echo "updating inventory.html with new archive file info....."
        sed -i -e '\@</body>@i\<tr><td>'$log_type'</td><td>'$date_created'</td><td>'$file_type'</td><td>'$file_size'</td></tr>' /var/www/html/inventory.html
else
        echo "inventory.html does not exist....."
        echo "creating inventory.html file....."
        {
        echo '<!DOCTYPE html>'
        echo '<html>'
        echo '<style>'
        echo 'table, th, td {border:1px black;}'
        echo '</style>'
        echo '<body>'
        echo '<table style="width:100%">'
        echo '<tr>'
        echo '<th>Log Type</th>'
        echo '<th>Date Created</th>'
        echo '<th>Type</th>'
        echo '<th>Size</th>'
        echo '</tr>'
        echo '</body>'
        echo '</html>'
        }>>/var/www/html/inventory.html
        sed -i -e '\@</body>@i\<tr><td>'$log_type'</td><td>'$date_created'</td><td>'$file_type'</td><td>'$file_size'</td></tr>' /var/www/html/inventory.html
fi

ls /etc/cron.d/automation &>/dev/null
if [ $? -eq 0 ];
then
        echo "corn job is scheduled........."
else
        echo "cron job not schedule ............."
        echo "setting up cron job .........."

        echo "00 00 * * * root /root/Automation_Project/automation.sh" >> /etc/cron.d/automation
        echo "cron job is scheduled for daily starting from tomorrow ........"
fi