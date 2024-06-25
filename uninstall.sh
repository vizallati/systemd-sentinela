#!/bin/bash
service_name='sentinela.service'
# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

systemctl stop $service_name
systemctl disable $service_name
rm /etc/systemd/system/$service_name
rm -rf /opt/sentinela

echo "$service_name was successfully removed from system"