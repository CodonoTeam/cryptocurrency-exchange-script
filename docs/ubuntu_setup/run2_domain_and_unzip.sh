#!/bin/bash

# ============================================
# Codono Exchange - Domain Setup & Code Extraction
# Creates two Nginx vhosts: API + Frontend
# ============================================

set -e

# Verify /opt/credentials.yml exists
if [ ! -f "/opt/credentials.yml" ]; then
    echo "/opt/credentials.yml does not exist. Run run1_ubuntu_lemp_setup.sh first."
    exit 1
fi

# Extract domain values
DOMAIN=$(grep '^DOMAIN:' /opt/credentials.yml | cut -d ' ' -f 2)
FRONTEND_DOMAIN=$(grep 'FRONTEND_DOMAIN:' /opt/credentials.yml | cut -d ' ' -f 2)

if [ -z "$DOMAIN" ]; then
    echo "DOMAIN value not found in /opt/credentials.yml."
    exit 1
fi

if [ -z "$FRONTEND_DOMAIN" ]; then
    echo "FRONTEND_DOMAIN not found. Deriving from DOMAIN..."
    FRONTEND_DOMAIN=$(echo "$DOMAIN" | sed 's/^api\.//')
fi

echo "API Domain: $DOMAIN"
echo "Frontend Domain: $FRONTEND_DOMAIN"

# Verify /opt/backend.zip exists
if [ ! -f "/opt/backend.zip" ]; then
    echo "/opt/backend.zip does not exist."
    exit 1
fi

# Check if unzip is available
if ! command -v unzip &> /dev/null; then
    echo "unzip is not installed. Installing..."
    sudo apt-get update && sudo apt-get install unzip -y
fi

# Unzip backend.zip
echo "Unzipping /opt/backend.zip..."
unzip -o /opt/backend.zip -d /data/wwwroot/ || { echo "Failed to unzip file."; exit 1; }

# Create domain directories
echo "Creating domain directories..."
mkdir -p "/data/wwwroot/${DOMAIN}"
mkdir -p "/data/wwwroot/${FRONTEND_DOMAIN}"

# Set ownership
chown -R www-data:www-data "/data/wwwroot/${DOMAIN}"
chown -R www-data:www-data "/data/wwwroot/${FRONTEND_DOMAIN}"

# Create API domain Nginx vhost
echo "Creating Nginx vhost for API domain: ${DOMAIN}..."
cat > "/etc/nginx/sites-available/${DOMAIN}.conf" << 'NGINXEOF'
server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;
    root /data/wwwroot/DOMAIN_PLACEHOLDER;
    index index.php index.html;

    # Logging
    access_log /var/log/nginx/DOMAIN_PLACEHOLDER_access.log;
    error_log /var/log/nginx/DOMAIN_PLACEHOLDER_error.log;

    # Gzip compression
    gzip on;
    gzip_types text/html text/css text/plain text/xml application/json
               application/javascript application/xml application/rss+xml
               image/svg+xml font/truetype font/opentype;

    # URL rewriting (replaces .htaccess RewriteRule)
    location / {
        try_files $uri $uri/ /index.php?s=$uri&$args;
    }

    # PHP processing via FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Admin area - basic auth protection
    location /Admin {
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
        try_files $uri $uri/ /index.php?s=$uri&$args;
    }

    # Block access to sensitive directories
    location ~ ^/(Runtime|Application|codebase)/ {
        deny all;
    }

    # Default coin image fallback
    location /Upload/coin/ {
        try_files $uri /Upload/coin/default.jpg;
    }

    # Static assets caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Deny dotfiles (except .well-known for certbot)
    location ~ /\.(?!well-known) {
        deny all;
    }
}
NGINXEOF

# Replace placeholders with actual domain
sed -i "s/DOMAIN_PLACEHOLDER/${DOMAIN}/g" "/etc/nginx/sites-available/${DOMAIN}.conf"

# Create Frontend domain Nginx vhost
echo "Creating Nginx vhost for Frontend domain: ${FRONTEND_DOMAIN}..."
cat > "/etc/nginx/sites-available/${FRONTEND_DOMAIN}.conf" << 'NGINXEOF'
server {
    listen 80;
    server_name FRONTEND_PLACEHOLDER;
    root /data/wwwroot/FRONTEND_PLACEHOLDER;
    index index.html;

    # Logging
    access_log /var/log/nginx/FRONTEND_PLACEHOLDER_access.log;
    error_log /var/log/nginx/FRONTEND_PLACEHOLDER_error.log;

    # Gzip compression
    gzip on;
    gzip_types text/html text/css text/plain text/xml application/json
               application/javascript application/xml image/svg+xml;

    # SPA fallback for Vue/React frontend
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Static assets caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Deny dotfiles (except .well-known for certbot)
    location ~ /\.(?!well-known) {
        deny all;
    }
}
NGINXEOF

# Replace placeholders with actual domain
sed -i "s/FRONTEND_PLACEHOLDER/${FRONTEND_DOMAIN}/g" "/etc/nginx/sites-available/${FRONTEND_DOMAIN}.conf"

# Enable both sites
echo "Enabling Nginx sites..."
ln -sf "/etc/nginx/sites-available/${DOMAIN}.conf" "/etc/nginx/sites-enabled/"
ln -sf "/etc/nginx/sites-available/${FRONTEND_DOMAIN}.conf" "/etc/nginx/sites-enabled/"

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
echo "Testing Nginx configuration..."
nginx -t && systemctl reload nginx

echo ""
echo "Domain setup complete!"
echo "  API vhost: /etc/nginx/sites-available/${DOMAIN}.conf"
echo "  Frontend vhost: /etc/nginx/sites-available/${FRONTEND_DOMAIN}.conf"
echo ""
echo "You can now run run3_config_part.sh"
