#!/bin/bash
set -e
# Define variables
SERVICE_MONITOR_DIR="/opt"
SERVICE_MONITOR_SCRIPT="${SERVICE_MONITOR_DIR}/sentinela/collector.sh"
SERVICE_FILE="/etc/systemd/system/sentinela.service"
FLASK_APP_DIR=$(pwd)
echo "$FLASK_APP_DIR"

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Copy the collect_services.sh script
cp -r $FLASK_APP_DIR "$SERVICE_MONITOR_DIR"
chmod +x "$SERVICE_MONITOR_DIR/sentinela"
cd $SERVICE_MONITOR_DIR/sentinela

# Create a virtual environment
# Support other python versions
apt install python3.10-venv -y
python3 -m venv venv
source venv/bin/activate
echo "Working directory is $PWD"
# Install required Python packages
pip install -r requirements.txt

# Create the systemd service file
cat <<EOL > $SERVICE_FILE
[Unit]
Description=Service Monitor
After=network.target

[Service]
User=$USER
WorkingDirectory=$FLASK_APP_DIR
ExecStartPre=$SERVICE_MONITOR_SCRIPT
ExecStart=/opt/sentinela/venv/bin/python /opt/sentinela/app.py
ExecReload=/bin/kill -s HUP $MAINPID
RestartSec=2
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable sentinela.service
systemctl start sentinela.service

echo "Sentinela Monitoring Service Setup Completed Successfully!"
echo "Server is running on http://localhost:8000"