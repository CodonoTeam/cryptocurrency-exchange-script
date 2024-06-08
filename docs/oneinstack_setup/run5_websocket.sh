#!/bin/bash

# Path to credentials and configuration
CREDENTIALS_FILE="/opt/credentials.yml"
NGINX_CONF_PATH="/usr/local/nginx/conf/vhost"
OTHER_CONFIG_PHP="/data/wwwroot/codebase/other_config.php"
SUPERVISOR_CONF="/etc/supervisor/conf.d/socketbot.conf"

# Check and install Supervisor if it's not already installed
if ! command -v supervisorctl &> /dev/null; then
    echo "Supervisor is not installed. Installing..."
    sudo apt-get update && sudo apt-get install -y supervisor
else
    echo "Supervisor is already installed."
fi

# Extract the domain name from credentials.yml
DOMAIN=$(grep 'DOMAIN:' ${CREDENTIALS_FILE} | cut -d ' ' -f 2)
if [ -z "$DOMAIN" ]; then
    echo "Domain not found in ${CREDENTIALS_FILE}. Exiting..."
    exit 1
fi

# Configure Supervisor to keep the socket bot running
echo "Configuring Supervisor for socket bot..."
cat > ${SUPERVISOR_CONF} << EOF
[program:socketbot]
directory=/data/wwwroot/codebase
command=/usr/local/php/bin/php socketbot.php start
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/socketbot.err.log
stdout_logfile=/var/log/supervisor/socketbot.out.log
EOF

# Update other_config.php with the new domain for WebSocket
sed -i "s|const SOCKET_WS_URL =.*|const SOCKET_WS_URL = \"wss://${DOMAIN}/wsocket\";|" ${OTHER_CONFIG_PHP}

# Add/update the Nginx configuration for WebSocket forwarding
NGINX_CONF="${NGINX_CONF_PATH}/${DOMAIN}.conf"
if grep -q "~/wsocket(.*)\$" "${NGINX_CONF}"; then
    echo "WebSocket configuration already exists in ${NGINX_CONF}"
else
    echo "Adding WebSocket configuration to ${NGINX_CONF}"
    sed -i "/server {/a location ~/wsocket(.*)\$ {\n    proxy_set_header X-Real-IP  \$remote_addr;\n    proxy_set_header X-Forwarded-For \$remote_addr;\n    proxy_set_header Host \$host;\n    proxy_pass http://127.0.0.1:7272;\n}" "${NGINX_CONF}"
fi

# Reload Nginx to apply changes
echo "Reloading Nginx..."
nginx -s reload

# Reload Supervisor to apply changes
echo "Reloading Supervisor..."
supervisorctl reload
echo "Starting socketbot..."
supervisorctl start socketbot

# Add sudoers file for www user
NEW_SUDOERS_FILE="/etc/sudoers.d/www_sudoers"
echo "www ALL=(ALL) NOPASSWD: /usr/bin/supervisorctl restart all" > ${NEW_SUDOERS_FILE}
chmod 440 ${NEW_SUDOERS_FILE}
visudo -c -f ${NEW_SUDOERS_FILE}
if [ $? -ne 0 ]; then
  echo "Failed to validate the sudoers file, removing..."
  rm ${NEW_SUDOERS_FILE}
  exit 1
else
  echo "Sudoers file for www user has been updated and validated."
fi

echo "Socket Setup complete. WebSocket and Supervisor are configured."
