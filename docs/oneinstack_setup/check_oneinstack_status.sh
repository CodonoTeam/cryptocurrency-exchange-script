#!/bin/bash

echo "=========================================="
echo "  Checking OneinStack Installation Status "
echo "=========================================="

# Load credentials from /opt/credentials.yml
CREDENTIALS_FILE="/opt/credentials.yml"

if [ -f "$CREDENTIALS_FILE" ]; then
    echo "[✔] Loading credentials from $CREDENTIALS_FILE"
    REDIS_PASSWORD=$(grep "REDIS_PASSWORD" "$CREDENTIALS_FILE" | awk '{print $2}')
    MYSQL_ROOT_PASSWORD=$(grep "MYSQL_NEW_ROOT_PASSWORD" "$CREDENTIALS_FILE" | awk '{print $2}')
    DOMAIN=$(grep "DOMAIN" "$CREDENTIALS_FILE" | awk '{print $2}')
else
    echo "[✘] Credentials file not found at $CREDENTIALS_FILE"
    exit 1
fi

# Function to check service status
check_service() {
    systemctl is-active --quiet "$1"
    if [ $? -eq 0 ]; then
        echo "[✔] $1 is running"
    else
        echo "[✘] $1 is NOT running"
    fi
}

# Check services
check_service nginx
check_service httpd
check_service mariadb
check_service redis

echo "------------------------------------------"
echo "Checking Versions:"
echo "------------------------------------------"

# Check versions
echo -n "PHP Version: " && php -v | head -n 1
echo -n "MariaDB Version: " && mysql -V
echo -n "Nginx Version: " && nginx -v 2>&1 | awk -F'[: ]' '{print $3}'
echo -n "Apache Version: " && httpd -v | grep "Server version"
echo -n "Redis Version: " && redis-cli --version

echo "------------------------------------------"
echo "Checking Nginx Configuration:"
echo "------------------------------------------"
nginx -t

echo "------------------------------------------"
echo "Checking Redis Connection:"
echo "------------------------------------------"
if redis-cli -a "$REDIS_PASSWORD" ping | grep -q "PONG"; then
    echo "[✔] Redis is responding with PONG"
else
    echo "[✘] Redis authentication failed"
fi

echo "------------------------------------------"
echo "Checking PHP Modules:"
echo "------------------------------------------"
php -m | grep -E "redis|mysqli|pdo_mysql"

echo "------------------------------------------"
echo "Checking Web Server Response:"
echo "------------------------------------------"
curl -I http://127.0.0.1/ 2>/dev/null | head -n 1

echo "------------------------------------------"
echo "Checking MySQL Connection:"
echo "------------------------------------------"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "[✔] Successfully connected to MySQL"
else
    echo "[✘] MySQL connection failed"
fi

echo "------------------------------------------"
echo "Checking Logs for Errors:"
echo "------------------------------------------"
echo "Nginx Errors:"
tail -n 5 /var/log/nginx/error.log
echo "Apache Errors:"
tail -n 5 /var/log/httpd/error_log
echo "MariaDB Errors:"
tail -n 5 /var/log/mariadb/mariadb.log
echo "Redis Logs:"
tail -n 5 /var/log/redis/redis-server.log

echo "=========================================="
echo "  OneinStack Status Check Completed!"
echo "=========================================="
