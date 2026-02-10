#!/bin/bash

# ============================================
# Codono Exchange - Ubuntu Service Status Check
# Checks all services installed via apt
# ============================================

echo "=========================================="
echo "  Checking Ubuntu LEMP Installation Status"
echo "=========================================="

# Load credentials from /opt/credentials.yml
CREDENTIALS_FILE="/opt/credentials.yml"

if [ -f "$CREDENTIALS_FILE" ]; then
    echo "[OK] Loading credentials from $CREDENTIALS_FILE"
    REDIS_PASSWORD=$(grep "REDIS_PASSWORD" "$CREDENTIALS_FILE" | awk '{print $2}')
    MYSQL_ROOT_PASSWORD=$(grep "MYSQL_NEW_ROOT_PASSWORD" "$CREDENTIALS_FILE" | awk '{print $2}')
    DOMAIN=$(grep "^DOMAIN" "$CREDENTIALS_FILE" | awk '{print $2}')
    FRONTEND_DOMAIN=$(grep "FRONTEND_DOMAIN" "$CREDENTIALS_FILE" | awk '{print $2}')
else
    echo "[FAIL] Credentials file not found at $CREDENTIALS_FILE"
    exit 1
fi

# Function to check service status
check_service() {
    if systemctl is-active --quiet "$1" 2>/dev/null; then
        echo "[OK] $1 is running"
    else
        echo "[FAIL] $1 is NOT running"
    fi
}

echo ""
echo "------------------------------------------"
echo "Core Services:"
echo "------------------------------------------"
check_service nginx
check_service php7.4-fpm
check_service mariadb
check_service redis-server
check_service memcached

echo ""
echo "------------------------------------------"
echo "Application Services:"
echo "------------------------------------------"

# Check Supervisor and socketbot
if command -v supervisorctl &> /dev/null; then
    SOCKETBOT_STATUS=$(supervisorctl status socketbot 2>/dev/null | awk '{print $2}')
    if [ "$SOCKETBOT_STATUS" = "RUNNING" ]; then
        echo "[OK] socketbot (Supervisor) is RUNNING"
    else
        echo "[FAIL] socketbot (Supervisor) status: ${SOCKETBOT_STATUS:-not configured}"
    fi
else
    echo "[--] Supervisor not installed"
fi

# Check trading engine (systemd service)
check_service trading-engine

# Check QuestDB
if systemctl is-active --quiet questdb 2>/dev/null; then
    echo "[OK] QuestDB is running"
else
    echo "[--] QuestDB not installed or not running"
fi

echo ""
echo "------------------------------------------"
echo "Software Versions:"
echo "------------------------------------------"
echo -n "PHP Version: " && php7.4 -v 2>/dev/null | head -n 1 || echo "Not found"
echo -n "MariaDB Version: " && mariadb --version 2>/dev/null || echo "Not found"
echo -n "Nginx Version: " && nginx -v 2>&1 || echo "Not found"
echo -n "Redis Version: " && redis-cli --version 2>/dev/null || echo "Not found"

echo ""
echo "------------------------------------------"
echo "Nginx Configuration:"
echo "------------------------------------------"
nginx -t 2>&1

echo ""
echo "------------------------------------------"
echo "PHP-FPM Socket:"
echo "------------------------------------------"
if [ -S /run/php/php7.4-fpm.sock ]; then
    echo "[OK] PHP-FPM socket exists at /run/php/php7.4-fpm.sock"
else
    echo "[FAIL] PHP-FPM socket not found"
fi

echo ""
echo "------------------------------------------"
echo "Redis Connection:"
echo "------------------------------------------"
if redis-cli -a "$REDIS_PASSWORD" --no-auth-warning ping 2>/dev/null | grep -q "PONG"; then
    echo "[OK] Redis is responding with PONG"
else
    echo "[FAIL] Redis authentication failed"
fi

echo ""
echo "------------------------------------------"
echo "PHP Modules:"
echo "------------------------------------------"
php7.4 -m 2>/dev/null | grep -E "redis|mysqli|pdo_mysql|gmp|swoole|opcache|fileinfo" || echo "Could not list PHP modules"

echo ""
echo "------------------------------------------"
echo "Web Server Response:"
echo "------------------------------------------"
curl -sI http://127.0.0.1/ 2>/dev/null | head -n 3 || echo "Could not connect"

echo ""
echo "------------------------------------------"
echo "MySQL Connection:"
echo "------------------------------------------"
mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "[OK] Successfully connected to MariaDB"
else
    echo "[FAIL] MariaDB connection failed"
fi

echo ""
echo "------------------------------------------"
echo "Recent Log Errors:"
echo "------------------------------------------"

# Function to check logs with fallback
check_log() {
    if [ -f "$1" ]; then
        echo "$2:"
        tail -n 5 "$1"
        echo ""
    else
        echo "[--] Log file $1 not found."
    fi
}

# Standard Ubuntu log file locations
check_log "/var/log/nginx/error.log" "Nginx Errors"
check_log "/var/log/mysql/error.log" "MariaDB Errors"
check_log "/var/log/redis/redis-server.log" "Redis Logs"
check_log "/var/log/php7.4-fpm.log" "PHP-FPM Logs"

# Domain-specific logs
if [ -n "$DOMAIN" ]; then
    check_log "/var/log/nginx/${DOMAIN}_error.log" "API Domain Nginx Errors"
fi
if [ -n "$FRONTEND_DOMAIN" ]; then
    check_log "/var/log/nginx/${FRONTEND_DOMAIN}_error.log" "Frontend Domain Nginx Errors"
fi

echo "=========================================="
echo "  Ubuntu Status Check Completed!         "
echo "=========================================="
