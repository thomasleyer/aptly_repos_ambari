#!/bin/bash
apt-get install python2.7
ulimit -n 10000
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ''
cat /root/.ssh/id_rsa.pub >> /root /.ssh/authorized_keys 
ssh-keyscan -H localhost >> ~/.ssh/known_hosts
echo umask 0027 >> /etc/profile
wget -nv http://public-repo-1.hortonworks.com/ambari/ubuntu14/2.x/updates/2.4.2.0/ambari.list -O /etc/apt/sources.list.d/ambari.list
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
apt-get -y update
apt-get -y install ntp
service ntp start
apt-get -y install sysfsutils
echo "kernel/mm/transparent_hugepage/enabled = never" >> /etc/sysfs.conf
apt-get -y install ambari-server 
echo "deb http://public-repo-1.hortonworks.com/HDP/ubuntu14/2.x/updates/2.5.3.0 HDP main" > /etc/apt/sources.list.d/HDP.list
echo "deb http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.21/repos/ubuntu14 HDP-UTILS main" > /etc/apt/sources.list.d/HDP-UTILS.list
ambari-server setup -s
ambari-server start
