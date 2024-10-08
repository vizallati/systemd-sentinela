#!/bin/bash
set -e
# Define variables
SERVICE_MONITOR_DIR="/opt/sentinela"
SERVICE_MONITOR_SCRIPT="${SERVICE_MONITOR_DIR}/collector.sh"
SERVICE_FILE="/etc/systemd/system/sentinela.service"
CLONED_PROJECT_DIR=$(pwd)
echo "Current working directory is: $CLONED_PROJECT_DIR"

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

setup_environment() {
  mkdir $SERVICE_MONITOR_DIR
  cp $CLONED_PROJECT_DIR/* "$SERVICE_MONITOR_DIR"
  cd $SERVICE_MONITOR_DIR
  chmod +x collector.sh app.py uninstall.sh
  python3 -m pip install -r requirements.txt
}

create_systemd_service_file () {
  cat <<EOL > $SERVICE_FILE
[Unit]
Description=Service Monitor
After=network.target

[Service]
User=$USER
WorkingDirectory=/opt/sentinela
ExecStartPre=$SERVICE_MONITOR_SCRIPT
ExecStart=/usr/bin/python3 /opt/sentinela/app.py
ExecReload=/bin/kill -s HUP $MAINPID
RestartSec=2
Restart=always

[Install]
WantedBy=multi-user.target
EOL
echo "Sentinela Monitoring Service Setup Completed Successfully!"

}

start_service () {
  echo "Starting Service..."
  systemctl daemon-reload
  systemctl enable sentinela.service
  systemctl start sentinela.service
  echo "Server is running on http://localhost:8000"
}


setup_environment
create_systemd_service_file
start_service

