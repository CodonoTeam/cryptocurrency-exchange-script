#!/bin/bash

# ============================================
# Codono Exchange - WebSocket Server Setup
# Configures Supervisor for socketbot + Nginx proxy
# ============================================

set -e
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
mkdir -p /etc/needrestart/conf.d 2>/dev/null
printf '\$nrconf{restart} = '"'"'a'"'"';\n\$nrconf{kernelhints} = 0;\n' > /etc/needrestart/conf.d/99-codono.conf 2>/dev/null || true

# Path to credentials and configuration
CREDENTIALS_FILE="/opt/credentials.yml"
OTHER_CONFIG_PHP="/data/wwwroot/codebase/other_config.php"
SUPERVISOR_CONF="/etc/supervisor/conf.d/socketbot.conf"

# Check and install Supervisor if it's not already installed
if ! command -v supervisorctl &> /dev/null; then
    echo "Supervisor is not installed. Installing..."
    sudo apt-get update && sudo apt-get install -y supervisor
else
    echo "Supervisor is already installed."
fi

# Extract domain names from credentials.yml
DOMAIN=$(grep '^DOMAIN:' ${CREDENTIALS_FILE} | cut -d ' ' -f 2)
FRONTEND_DOMAIN=$(grep 'FRONTEND_DOMAIN:' ${CREDENTIALS_FILE} | cut -d ' ' -f 2)

if [ -z "$DOMAIN" ]; then
    echo "DOMAIN not found in ${CREDENTIALS_FILE}. Exiting..."
    exit 1
fi

if [ -z "$FRONTEND_DOMAIN" ]; then
    echo "FRONTEND_DOMAIN not found. Deriving from DOMAIN..."
    FRONTEND_DOMAIN=$(echo "$DOMAIN" | sed 's/^api\.//')
fi

# Configure Supervisor to keep the socket bot running
echo "Configuring Supervisor for socket bot..."
cat > ${SUPERVISOR_CONF} << EOF
[program:socketbot]
directory=/data/wwwroot/codebase
command=/usr/bin/php7.4 socketbot.php start
user=www-data
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/socketbot.err.log
stdout_logfile=/var/log/supervisor/socketbot.out.log
EOF

# Update other_config.php with the WebSocket URL (uses frontend domain)
sed -i "s|const SOCKET_WS_URL =.*|const SOCKET_WS_URL = \"wss://${FRONTEND_DOMAIN}/wsocket\";|" ${OTHER_CONFIG_PHP}

# Add WebSocket proxy to the FRONTEND domain Nginx config
# (Frontend connects to wss://myexchange.com/wsocket)
NGINX_CONF="/etc/nginx/sites-available/${FRONTEND_DOMAIN}.conf"

if [ ! -f "$NGINX_CONF" ]; then
    echo "Frontend Nginx config not found: $NGINX_CONF"
    echo "Please run run2_domain_and_unzip.sh first."
    exit 1
fi

# Add /wsocket proxy (socketbot on port 7272)
if grep -q "location /wsocket" "${NGINX_CONF}"; then
    echo "WebSocket /wsocket configuration already exists in ${NGINX_CONF}"
else
    echo "Adding /wsocket proxy (port 7272) to ${NGINX_CONF}"
    sed -i '/^}$/i\
    # WebSocket: Liquidity/Orderbook Bot (port 7272)\
    location /wsocket {\
        proxy_pass http://127.0.0.1:7272;\
        proxy_http_version 1.1;\
        proxy_set_header Upgrade $http_upgrade;\
        proxy_set_header Connection "upgrade";\
        proxy_set_header Host $host;\
        proxy_set_header X-Real-IP $remote_addr;\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\
        proxy_read_timeout 86400;\
        proxy_send_timeout 86400;\
    }' "${NGINX_CONF}"
fi

# Add /engine proxy (trading engine on port 8081)
if grep -q "location /engine" "${NGINX_CONF}"; then
    echo "WebSocket /engine configuration already exists in ${NGINX_CONF}"
else
    echo "Adding /engine proxy (port 8081) to ${NGINX_CONF}"
    sed -i '/^}$/i\
    # WebSocket: Trading Engine - Futures/Margin/Forex (port 8081)\
    location /engine {\
        proxy_pass http://127.0.0.1:8081;\
        proxy_http_version 1.1;\
        proxy_set_header Upgrade $http_upgrade;\
        proxy_set_header Connection "upgrade";\
        proxy_set_header Host $host;\
        proxy_set_header X-Real-IP $remote_addr;\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\
        proxy_read_timeout 86400;\
        proxy_send_timeout 86400;\
    }' "${NGINX_CONF}"
fi

# Reload Nginx to apply changes
echo "Reloading Nginx..."
nginx -t && systemctl reload nginx

# Reload Supervisor to apply changes
echo "Reloading Supervisor..."
supervisorctl reload
sleep 2
echo "Starting socketbot..."
supervisorctl start socketbot

# Add sudoers file for www-data user
NEW_SUDOERS_FILE="/etc/sudoers.d/www_sudoers"
echo "www-data ALL=(ALL) NOPASSWD: /usr/bin/supervisorctl restart all" > ${NEW_SUDOERS_FILE}
chmod 440 ${NEW_SUDOERS_FILE}
visudo -c -f ${NEW_SUDOERS_FILE}
if [ $? -ne 0 ]; then
    echo "Failed to validate the sudoers file, removing..."
    rm ${NEW_SUDOERS_FILE}
    exit 1
else
    echo "Sudoers file for www-data user has been updated and validated."
fi

echo "Socket Setup complete. WebSocket and Supervisor are configured."
