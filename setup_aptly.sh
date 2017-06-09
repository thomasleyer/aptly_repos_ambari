#!/bin/bash
echo "deb http://repo.aptly.info/ squeeze main" > /etc/apt/sources.list.d/aptly.list
apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460

apt-get -y update
apt-get -y install apt-rdepends
apt-get -y install aptly
apt-get -y install supervisor

useradd -m -s /bin/bash -G sudo aptly

aptly -distribution="trusty" -architectures=amd64 repo create ubuntu


mkdir ubuntu_download
cd ubuntu_download

for i in postgresql-9.3 libdbi-perl perl-base libc-dev libc libc6-dev libc6 debconf policyrcd-script-zg2 gcc wget curl unzip zip tar python2.7 python2.7-dev openssl postgresql-client-common postgresql-common ssl-cert libpq5 postgresql postgresql-9.1 mysql-server mysql-client python python-dev 
do
apt-get download $i
apt-get download $(apt-rdepends $i| grep -v "^ ")
apt-get download $( apt-rdepends python-dev| egrep -v "debconf|libc-dev" | grep "Depends" | awk -F\: '{ print $2 }' | awk '{ print $1}' | sort -u )
done

aptly repo add ubuntu *deb
aptly snapshot create ubuntu_current from repo ubuntu
aptly -architectures="amd64" -skip-signing=true publish snapshot -architectures="amd64" ubuntu_current

cat > /etc/supervisor/conf.d/aptlyapi.conf << EOF
[program:aptlyapi]
command = aptly serve
directory = /var/lib/aptly
user = aptly
EOF

service supervisor restart
supervisorctl start aptlyapi

