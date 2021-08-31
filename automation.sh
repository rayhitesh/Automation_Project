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