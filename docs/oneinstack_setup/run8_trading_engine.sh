#!/bin/bash
# ============================================
# Trading Engine Setup Script
# Required for: Perpetual Futures, Margin Trading, Real-time Price Feeds
# ============================================

set -e

echo "=========================================="
echo "  TRADING ENGINE SETUP (Node.js)         "
echo "  Required for: Futures, Margin Trading  "
echo "=========================================="

# Load credentials
if [ ! -f /opt/credentials.yml ]; then
    echo "ERROR: /opt/credentials.yml not found!"
    echo "Please run run3_config_part.sh first."
    exit 1
fi

# Parse credentials
DOMAIN=$(grep 'domain:' /opt/credentials.yml | awk '{print $2}')
DB_NAME=$(grep 'db_name:' /opt/credentials.yml | awk '{print $2}')
DB_USER=$(grep 'db_user:' /opt/credentials.yml | awk '{print $2}')
DB_PASS=$(grep 'db_pass:' /opt/credentials.yml | awk '{print $2}')

if [ -z "$DOMAIN" ]; then
    echo "ERROR: Could not read domain from credentials.yml"
    exit 1
fi

echo "Domain: $DOMAIN"
echo "Database: $DB_NAME"

# Check if Node.js is installed
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "Node.js already installed: $NODE_VERSION"
else
    echo "Installing Node.js 18 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Verify installation
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# Navigate to trading engine directory
TRADING_ENGINE_DIR="/home/wwwroot/$DOMAIN/backend/trading_engine"

if [ ! -d "$TRADING_ENGINE_DIR" ]; then
    echo "ERROR: Trading engine directory not found: $TRADING_ENGINE_DIR"
    echo "Make sure the backend is properly extracted."
    exit 1
fi

cd "$TRADING_ENGINE_DIR"
echo "Working directory: $(pwd)"

# Install dependencies
echo "Installing npm dependencies..."
npm install

# Create .env file
echo "Creating .env configuration..."
cat > .env << EOF
# Trading Engine Configuration
NODE_ENV=production
PORT=8081

# MySQL Database
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=$DB_USER
MYSQL_PASSWORD=$DB_PASS
MYSQL_DATABASE=$DB_NAME

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# QuestDB Configuration (for high-performance price queries)
QUESTDB_HOST=localhost
QUESTDB_HTTP_PORT=9000
QUESTDB_PG_PORT=8812

# Price Feed Settings
PRICE_UPDATE_INTERVAL=2000
PRICE_SOURCES=binance,okx,bybit,kucoin,htx,mexc

# WebSocket Settings
WS_HEARTBEAT_INTERVAL=30000
WS_MAX_CONNECTIONS=10000

# Logging
LOG_LEVEL=info
LOG_FILE=logs/trading-engine.log
EOF

# Create logs directory
mkdir -p logs

# Build TypeScript (if tsconfig exists)
if [ -f "tsconfig.json" ]; then
    echo "Building TypeScript..."
    npm run build
fi

# Install PM2 globally if not exists
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2 process manager..."
    sudo npm install -g pm2
fi

# Create PM2 ecosystem file
echo "Creating PM2 ecosystem configuration..."
cat > ecosystem.config.js << 'EOFPM2'
module.exports = {
  apps: [{
    name: 'trading-engine',
    script: 'dist/index.js',
    instances: 1,
    exec_mode: 'fork',
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
    },
    error_file: 'logs/error.log',
    out_file: 'logs/out.log',
    log_file: 'logs/combined.log',
    time: true,
  }]
};
EOFPM2

# Stop existing instance if running
pm2 stop trading-engine 2>/dev/null || true
pm2 delete trading-engine 2>/dev/null || true

# Start trading engine
echo "Starting Trading Engine..."
pm2 start ecosystem.config.js

# Save PM2 process list
pm2 save

# Setup PM2 startup script
echo "Setting up PM2 startup script..."
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u www --hp /home/www 2>/dev/null || true

# Wait for startup
sleep 3

# Check status
pm2 status

echo ""
echo "=========================================="
echo "  Trading Engine Setup Complete!         "
echo "=========================================="
echo ""
echo "Service Details:"
echo "  - Port: 8081"
echo "  - WebSocket: ws://localhost:8081"
echo "  - Health Check: http://localhost:8081/health"
echo ""
echo "Useful Commands:"
echo "  pm2 status              - Check status"
echo "  pm2 logs trading-engine - View logs"
echo "  pm2 restart trading-engine - Restart"
echo "  pm2 stop trading-engine - Stop"
echo ""
echo "Verify it's running:"
echo "  curl http://localhost:8081/health"
echo ""
