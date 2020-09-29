#!/bin/sh
set -ex

# Set directory and file permissions 
directories="/etc/syslog-ng/ /var/run/syslog-ng/ /var/log/syslog-ng/"
fpm="0644"
dpm="0755"

for directory in $directories; do
    find "$directory" -type d -exec chmod $dpm {} \;
    find "$directory" -type f -exec chmod $fpm {} \;
done

# Start syslog-ng
syslog-ng -F -f /etc/syslog-ng/syslog-ng.conf