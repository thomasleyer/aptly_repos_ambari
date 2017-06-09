#!/bin/bash
echo "deb http://repo.aptly.info/ squeeze main" > /etc/apt/sources.list.d/aptly.list
apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460

apt-get -y update
apt-get -y install apt-rdepends
apt-get -y install aptly

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

cat > /etc/init.d/aptly << EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO

dir="/root/"
cmd="/usr/bin/aptly serve"
user="root"

name=`basename $0`
pid_file="/var/run/$name.pid"
stdout_log="/var/log/$name.log"
stderr_log="/var/log/$name.err"

get_pid() {
    cat "$pid_file"
}

is_running() {
    [ -f "$pid_file" ] && ps -p `get_pid` > /dev/null 2>&1
}

case "$1" in
    start)
    if is_running; then
        echo "Already started"
    else
        echo "Starting $name"
        cd "$dir"
        if [ -z "$user" ]; then
            sudo $cmd >> "$stdout_log" 2>> "$stderr_log" &
        else
            sudo -u "$user" $cmd >> "$stdout_log" 2>> "$stderr_log" &
        fi
        echo $! > "$pid_file"
        if ! is_running; then
            echo "Unable to start, see $stdout_log and $stderr_log"
            exit 1
        fi
    fi
    ;;
    stop)
    if is_running; then
        echo -n "Stopping $name.."
        kill `get_pid`
        for i in 1 2 3 4 5 6 7 8 9 10
        # for i in `seq 10`
        do
            if ! is_running; then
                break
            fi

            echo -n "."
            sleep 1
        done
        echo

        if is_running; then
            echo "Not stopped; may still be shutting down or shutdown may have failed"
            exit 1
        else
            echo "Stopped"
            if [ -f "$pid_file" ]; then
                rm "$pid_file"
            fi
        fi
    else
        echo "Not running"
    fi
    ;;
    restart)
    $0 stop
    if is_running; then
        echo "Unable to stop, will not attempt to start"
        exit 1
    fi
    $0 start
    ;;
    status)
    if is_running; then
        echo "Running"
    else
        echo "Stopped"
        exit 1
    fi
    ;;
    *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0
EOF

chmod 755 /etc/init.d/aptly 
chown root:root /etc/init.d/aptly 
update-rc.d aptly defaults
update-rc.d aptly enable



