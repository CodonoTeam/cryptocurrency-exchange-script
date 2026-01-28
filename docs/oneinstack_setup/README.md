# Codono Exchange - Complete Setup Guide

Complete setup guide for deploying Codono Cryptocurrency Exchange on a fresh Ubuntu server.

**Example Domain Configuration:**

- **Main Domain:** `exchange.com` (Frontend)
- **API Domain:** `api.exchange.com` (Backend PHP)
- **WebSocket Bot:** `wss://exchange.com/wsocket` (Liquidity/Orderbook)
- **Trading Engine:** `wss://exchange.com/engine` (Futures/Margin/Forex)

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Overview](#quick-overview)
3. [Setup Scripts (Steps 1-11)](#step-1-upload-backend)
4. [Configuration Files Reference](#configuration-files-reference)
5. [Trading Engine Configuration](#trading-engine-env-configuration)
6. [Backend PHP Configuration](#backend-php-configuration)
7. [Socket Configuration & Nginx Proxy](#socket-configuration--nginx-proxy)
8. [Frontend & Mobile App Configuration](#frontend--mobile-app-configuration)
9. [Credentials.yml Reference](#credentialsyml-reference)
10. [Service Ports Reference](#service-ports-reference)
11. [Firewall Configuration](#firewall-configuration)
12. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- **OS:** Ubuntu 20.04/22.04 LTS
- **RAM:** Minimum 4GB (8GB recommended for Futures/Margin)
- **Storage:** 50GB+ SSD
- **Network:** Public IP with ports 80, 443 open
- **Domains:** 2 domains pointed to your server IP:
  - `exchange.com` → Your Server IP
  - `api.exchange.com` → Your Server IP

---

## Quick Overview

| Step | Script | Purpose |
| ---- | ------ | ------- |
| 1 | Upload backend.zip | Upload files to server |
| 2 | Download scripts | Get all setup scripts |
| 3 | run1_all_in_onestack_setup.sh | Install LEMP stack |
| 4 | run2_domain_and_unzip.sh | Setup domain & extract code |
| 5 | run3_config_part.sh | Configure application |
| 6 | run4_db_create_and_import.sh | Create database |
| 7 | run5_websocket.sh | Start liquidity WebSocket |
| 8 | run6_cron_setup.sh | Setup cron jobs |
| 9 | run7_show_admin_login.sh | Show admin credentials |
| 10 | run8_trading_engine.sh | Setup Trading Engine (Node.js) |
| 11 | run9_questdb.sh | Setup QuestDB (Time-series DB) |

---

## Step 1: Upload Backend

Upload your `backend.zip` to `/opt` folder on the server:

```bash
# Using SCP
scp backend.zip root@YOUR_SERVER_IP:/opt/

# Or use FileZilla/WinSCP
```

---

## Step 2: Download Setup Scripts

```bash
cd /opt/ && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run1_all_in_onestack_setup.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run2_domain_and_unzip.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run3_config_part.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run4_db_create_and_import.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run5_websocket.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run6_cron_setup.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run7_show_admin_login.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run8_trading_engine.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run9_questdb.sh && \
chmod +x run*.sh
```

---

## Step 3: Environment Setup (LEMP Stack)

Install Nginx, PHP, MySQL, Redis:

```bash
cd /opt/
./run1_all_in_onestack_setup.sh
```

This script:

- Installs OneInStack (Nginx, MySQL, PHP 8.1, Redis)
- Generates `/opt/credentials.yml` with random secure passwords
- Configures Redis with password authentication

---

## Step 4: Domain & Code Setup

Create domain directory, extract and place code:

```bash
cd /opt/
./run2_domain_and_unzip.sh
```

When prompted, enter your API domain: `api.exchange.com`

---

## Step 5: Application Configuration

Configure database credentials and application settings:

```bash
cd /opt/
./run3_config_part.sh
```

---

## Step 6: Database Setup

Create database, import SQL, and set admin credentials:

```bash
cd /opt/
./run4_db_create_and_import.sh
```

---

## Step 7: Liquidity WebSocket

Start WebSocket server for market liquidity (port 7272):

```bash
cd /opt/
./run5_websocket.sh
```

---

## Step 8: Cron Jobs

Setup automated tasks (price updates, notifications, etc.):

```bash
cd /opt/
./run6_cron_setup.sh
```

> **Note:** Double-check cron entries with `crontab -l -u www`

---

## Step 9: Admin Credentials

Display admin login information and 2FA QR code:

```bash
cd /opt/
./run7_show_admin_login.sh
```

Scan the QR code with Google Authenticator or Authy for 2FA.

---

## Step 10: Trading Engine Setup

**Required for:** Perpetual Futures, Margin Trading, Forex, Real-time Prices

```bash
cd /opt/
./run8_trading_engine.sh
```

This installs:

- Node.js 18 LTS
- PM2 process manager
- Trading Engine on port 8081

**Verify:**

```bash
pm2 status
curl http://localhost:8081/health
```

---

## Step 11: QuestDB Setup

**Required for:** High-performance mark price queries (Futures/Margin/Forex)

```bash
cd /opt/
./run9_questdb.sh
```

This installs:

- QuestDB time-series database
- Creates `mark_prices` and `forex_ticks` tables
- Starts on ports 9000 (HTTP) and 8812 (PostgreSQL)

**Verify:**

```bash
sudo systemctl status questdb
curl "http://localhost:9000/exec?query=SELECT%201"
```

---

## Configuration Files Reference

After running the setup scripts, you'll need to manually verify and customize several configuration files.

---

## Credentials.yml Reference

The setup scripts create `/opt/credentials.yml` which stores all generated credentials:

```yaml
# /opt/credentials.yml - Auto-generated during setup
# DO NOT share this file - contains all your secrets!

# HTTP Basic Auth (for protecting admin areas)
htaccess_username: HU_randomstring
htaccess_password: HP_randomstring

# Redis Configuration
redis_password: your_secure_redis_password

# MySQL Database
mysql_root_password: MP_randomstring
db_name: DBN_randomstring
db_user: root
db_pass: MP_randomstring

# Application Security Keys
admin_key: AK_randomstring      # Backend API authentication
cron_key: CK_randomstring       # Cron job access key

# Admin Panel Credentials
admin_user: AU_randomstring
admin_pass: AP_randomstring
two_fa_secret: BASE32SECRET     # 2FA secret for admin login

# Domain Configuration
domain: api.exchange.com        # Your API domain
frontend_domain: exchange.com   # Your frontend domain

# WebSocket URLs (for frontend/mobile compilation)
ws_url: wss://exchange.com/wsocket          # Liquidity WebSocket
engine_ws_url: wss://exchange.com/engine    # Trading Engine WebSocket

# API URLs
api_url: https://api.exchange.com
frontend_url: https://exchange.com
```

---

## Trading Engine .env Configuration

Location: `/home/wwwroot/api.exchange.com/backend/trading_engine/.env`

```bash
# ============================================
# TRADING ENGINE CONFIGURATION
# Required for: Futures, Margin, Forex Trading
# ============================================

# Environment
NODE_ENV=production

# ============================================
# REDIS CONFIGURATION
# ============================================
# Must match your Redis server settings
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password_from_credentials_yml
REDIS_DB=0
REDIS_FOREX_DB=1    # Separate DB for forex (prevents cache clearing issues)

# ============================================
# MYSQL CONFIGURATION
# ============================================
# Must match pure_config.php settings
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your_mysql_password_from_credentials_yml
MYSQL_DATABASE=DBN_randomstring

# ============================================
# WEBSOCKET SERVER
# ============================================
WS_PORT=8081

# ============================================
# MATCHING ENGINE SETTINGS
# ============================================
MATCHING_INTERVAL_MS=10           # Order matching frequency (ms)
PRICE_UPDATE_INTERVAL_MS=1000     # Price broadcast frequency (ms)
LIQUIDATION_CHECK_INTERVAL_MS=5000 # Liquidation check interval (ms)

# ============================================
# FOREX CONFIGURATION
# ============================================
FOREX_POLL_INTERVAL_MS=2000       # Price polling interval
FOREX_TICK_STORE=questdb          # Storage: 'questdb' or 'mysql'
FOREX_TICK_STORE_ENABLED=true
FOREX_TICK_FLUSH_INTERVAL_MS=1000
FOREX_TICK_BUFFER_SIZE=100

# ============================================
# QUESTDB CONFIGURATION
# ============================================
# For high-performance time-series queries
QUESTDB_HOST=127.0.0.1
QUESTDB_PORT=9000

# ============================================
# FOREX PRICE PROVIDERS
# Enable/disable based on your subscriptions
# ============================================
FOREX_PROVIDER_TRADINGVIEW_ENABLED=false
FOREX_PROVIDER_FREEFOREXAPI_ENABLED=false
FOREX_PROVIDER_EXCHANGERATEHOST_ENABLED=false
FOREX_PROVIDER_MQL5_ENABLED=true        # Free MetaTrader demo
FOREX_PROVIDER_OANDA_ENABLED=false
FOREX_PROVIDER_TWELVEDATA_ENABLED=false
FOREX_PROVIDER_FCSAPI_ENABLED=false
FOREX_PROVIDER_FINNHUB_ENABLED=false
FOREX_PROVIDER_ALPHAVANTAGE_ENABLED=false
FOREX_PROVIDER_POLYGON_ENABLED=false

# MQL5 Demo Account (Free - for testing)
MQL5_LOGIN=171243501
MQL5_PASSWORD=o6opghy
MQL5_SERVER=MetaQuotes-Demo

# Paid Provider API Keys (if using)
OANDA_API_TOKEN=
OANDA_ACCOUNT_ID=
TWELVEDATA_API_KEY=
FCSAPI_API_KEY=
FINNHUB_API_KEY=
ALPHAVANTAGE_API_KEY=
POLYGON_API_KEY=

# ============================================
# PROXY CONFIGURATION (Optional)
# ============================================
PROXY_ENABLED=false
PROXY_URL=
PROXY_TYPE=http
PROXY_ROTATION=false
PROXY_LIST=
```

---

## Backend PHP Configuration

### pure_config.php

Location: `/home/wwwroot/api.exchange.com/backend/codebase/pure_config.php`

```php
<?php
// ============================================
// CORE SYSTEM CONFIGURATION
// ============================================

// System Identity
const SHORT_NAME = 'Exchange';           // Your exchange name
const HOST_IP = '123.456.789.0';         // Your server IP
const SITE_URL = 'https://api.exchange.com';     // Backend URL
const FRONTEND_URL = 'https://exchange.com';     // Frontend URL

// ============================================
// DATABASE CONFIGURATION
// ============================================
const DB_TYPE = 'mysql';
const DB_HOST = '127.0.0.1';
const DB_NAME = 'DBN_randomstring';       // From credentials.yml
const DB_USER = 'root';
const DB_PWD = 'MP_randomstring';         // From credentials.yml
const DB_PORT = 3306;                     // 3306 for production

// ============================================
// REDIS CONFIGURATION
// ============================================
const REDIS_ENABLED = 1;                  // Enable Redis caching
const REDIS_HOST = '127.0.0.1';
const REDIS_PORT = 6379;
const REDIS_PASSWORD = 'your_redis_password';  // From credentials.yml
const REDIS_DB = 0;
const REDIS_FOREX_DB = 1;                 // Separate DB for forex

// ============================================
// SECURITY KEYS (from credentials.yml)
// ============================================
const ADMIN_KEY = 'AK_randomstring';      // API authentication
const CRON_KEY = 'CK_randomstring';       // Cron job access
const CODONOLIC = 'YOUR_LICENSE_NUMBER';  // License key
const ETH_USER_PASS = 'secure_eth_password'; // WARNING: Change only ONCE!

// ============================================
// DEBUG SETTINGS (Production values)
// ============================================
const APP_DEMO = 0;                       // 0 = Live mode
const M_DEBUG = 0;                        // 0 = No debug in production
const ADMIN_DEBUG = 0;
const DEBUG_WINDOW = 0;
const MOBILE_CODE = 0;                    // 0 = Require real SMS codes

// ============================================
// TRADING MODULE ENABLEMENT
// ============================================
const TRADING_ALLOWED = 1;                // Spot trading
const FUTURES_ALLOWED = 1;                // Perpetual futures
const MARGIN_ALLOWED = 1;                 // Margin trading
const FX_ALLOWED = 1;                     // Forex trading
const P2P_ALLOWED = 1;                    // P2P trading
const C2C_ALLOWED = 1;                    // C2C trading
const OTC_ALLOWED = 1;                    // OTC trading
const ICO_ALLOWED = 1;                    // ICO launchpad
const SHOP_ALLOWED = 0;                   // Shop module
const POOL_ALLOWED = 0;                   // Mining pool
const INVEST_ALLOWED = 0;                 // Investment products
const VOTING_ALLOWED = 0;                 // Governance voting

// ============================================
// WEBSOCKET CONFIGURATION
// ============================================
const SOCKET_WS_ENABLE = 1;
const SOCKET_WS_URL = "ws://localhost:7272";  // Internal socket URL

// ============================================
// BINANCE API (for liquidity/price feeds)
// ============================================
const BINANCE_TESTNET = 0;                // 0 = Mainnet, 1 = Testnet
const BINANCE_API_KEY_1 = '';
const BINANCE_API_SECRET_1 = '';

// ============================================
// EMAIL CONFIGURATION
// ============================================
const DEFAULT_MAILER = 'smtpmail';        // smtpmail, sendgrid, mailgun, etc.
const GLOBAL_EMAIL_SENDER = 'noreply@exchange.com';

// SMTP Settings
const SMTP_HOST = 'smtp.mailgun.org';
const SMTP_PORT = 587;
const SMTP_USER = 'postmaster@mg.exchange.com';
const SMTP_PASS = 'your_smtp_password';

// ============================================
// KYC CONFIGURATION
// ============================================
const KYC_OPTIONAL = 0;                   // 0 = Required for features
const ENFORCE_KYC = 1;                    // 1 = Enforce for trading/withdrawals
const DEFAULT_KYC = 1;                    // 1=internal, 2=sumsub, 3=shuftipro, 4=amlbot

// ============================================
// RATE LIMITING
// ============================================
const RATE_LIMIT_ENABLED = 1;
const RATE_LIMIT_CONFIG = [
    'trade_order' => ['limit' => 30, 'window' => 60],
    'trade_cancel' => ['limit' => 60, 'window' => 60],
    'api_request' => ['limit' => 120, 'window' => 60],
    'withdrawal' => ['limit' => 5, 'window' => 300],
    'login_attempt' => ['limit' => 5, 'window' => 300],
];

// ============================================
// THEME CONFIGURATION
// ============================================
const THEME_NAME = 'multiverse';          // or 'epsilon'
```

### other_config.php

Location: `/home/wwwroot/api.exchange.com/backend/codebase/other_config.php`

```php
<?php
// ============================================
// ADDITIONAL CONFIGURATION OPTIONS
// ============================================

// System Currency
const SYSTEMCURRENCY = 'USDT';            // Default base currency
const DEFAULT_FIAT = 'usd';               // Default fiat currency

// Feature Toggles (mirrors pure_config.php)
const FIAT_ALLOWED = 1;                   // Fiat on/off ramp

// ============================================
// GOOGLE OAUTH (Optional)
// ============================================
const GOOGLE_LOGIN_ALLOWED = 0;
const GOOGLE_CLIENT_ID = '';
const GOOGLE_CLIENT_SECRET = '';

// ============================================
// RECAPTCHA (Optional)
// ============================================
const RECAPTCHA = 0;                      // 0 = Disabled
const RECAPTCHA_KEY = '';
const RECAPTCHA_SECRET = '';

// ============================================
// SUBSCRIPTION PLANS
// ============================================
const ENABLE_SUBS = 0;                    // 0 = Disabled
const SUBSCRIPTION_PLANS = [];

// ============================================
// CHAT SETTINGS
// ============================================
const CHAT_LIMIT_LINES = 100;             // Max chat messages displayed
```

---

## Socket Configuration & Nginx Proxy

For production, WebSockets should be proxied through Nginx for SSL termination.

### Nginx Configuration for api.exchange.com

Location: `/usr/local/nginx/conf/vhost/api.exchange.com.conf`

```nginx
# Backend API Server Configuration
server {
    listen 80;
    server_name api.exchange.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.exchange.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/api.exchange.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.exchange.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;

    # Document Root
    root /home/wwwroot/api.exchange.com/backend/codebase;
    index index.php index.html;

    # PHP Processing
    location ~ \.php$ {
        fastcgi_pass unix:/dev/shm/php-cgi.sock;
        fastcgi_index index.php;
        include fastcgi.conf;
    }

    # API Endpoints
    location /Http {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location /Hapi {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location /Admin {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Static Files
    location /Upload {
        alias /home/wwwroot/api.exchange.com/backend/codebase/Upload;
    }
}
```

### Nginx Configuration for exchange.com (Frontend + WebSockets)

Location: `/usr/local/nginx/conf/vhost/exchange.com.conf`

```nginx
# Frontend Server with WebSocket Proxies
server {
    listen 80;
    server_name exchange.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name exchange.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/exchange.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/exchange.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;

    # Frontend Static Files
    root /home/wwwroot/exchange.com/frontend/dist;
    index index.html;

    # Vue Router - SPA fallback
    location / {
        try_files $uri $uri/ /index.html;
    }

    # ============================================
    # WEBSOCKET: Liquidity/Orderbook Bot
    # URL: wss://exchange.com/wsocket
    # Backend: Workerman PHP (port 7272)
    # ============================================
    location /wsocket {
        proxy_pass http://127.0.0.1:7272;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }

    # ============================================
    # WEBSOCKET: Trading Engine (Futures/Margin/Forex)
    # URL: wss://exchange.com/engine
    # Backend: Node.js Trading Engine (port 8081)
    # ============================================
    location /engine {
        proxy_pass http://127.0.0.1:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }

    # Health check endpoint for Trading Engine
    location /engine/health {
        proxy_pass http://127.0.0.1:8081/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
```

After updating Nginx configuration:

```bash
# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

---

## Frontend & Mobile App Configuration

After setup, update these files with your domain configuration before building.

### Frontend Config (Vue.js)

Location: `frontend/src/services/Config.ts`

```typescript
// Production configuration for exchange.com
const configs: Record<Environment, ConfigType> = {
  production: {
    brandName: "YourExchange",
    baseUrl: "https://api.exchange.com",
    apiUrl: "https://api.exchange.com/Http",
    wsUrl: "wss://exchange.com/wsocket",           // Liquidity WebSocket
    forexWsUrl: "wss://exchange.com/engine",       // Trading Engine WebSocket
    marginWsUrl: "wss://exchange.com/engine",      // Same as forexWsUrl
    imgUrl: "https://api.exchange.com/Upload",
    supportEmail: "support@exchange.com",
    appUrl: "https://exchange.com/app.apk",
    frontendURL: "https://exchange.com",
    logo_image: "/assets/images/logo.png",
    themeSwitch: false,
    themes: ["optimus", "xchange", "excoin", "orange", "mexc"],
    banxaAvailable: false,
    useMockData: false,
    enableForex: true,
    enableCrypto: true,
    enableP2P: true,
  },
};
```

Build the frontend:

```bash
cd frontend
npm install
npm run build
# Deploy dist/ folder to /home/wwwroot/exchange.com/frontend/dist/
```

### Mobile App Environment

Location: `mobile_app/src/environments/environment.prod.ts`

```typescript
export const environment = {
  production: true,
  enableMining: 0,
  enableFutures: 1,
  enableForex: 1,
  exchangeUrl: 'https://api.exchange.com/',
  exchangeUrlAPI: 'https://api.exchange.com/Hapi',
  exchangeUrlAPIHttp: 'https://api.exchange.com/Http',
  wsUrl: 'wss://exchange.com/wsocket',             // Liquidity WebSocket
  forexWsUrl: 'wss://exchange.com/engine',         // Trading Engine WebSocket
  marginWsUrl: 'wss://exchange.com/engine',        // Same as forexWsUrl
  enableLogging: false,
  baseCurrencies: ['USDT', 'BTC', 'ETH', 'USDC']
};
```

Build the mobile app:

```bash
cd mobile_app
npm install
ionic build --prod
ionic capacitor sync
```

---

## Service Ports Reference

| Service | Port | Protocol | Description |
| ------- | ---- | -------- | ----------- |
| Nginx HTTP | 80 | HTTP | Web server (redirect to HTTPS) |
| Nginx HTTPS | 443 | HTTPS | Web server (SSL) |
| MySQL | 3306 | TCP | Database |
| Redis | 6379 | TCP | Cache & pub/sub |
| PHP-FPM | 9000 | Socket | PHP processor |
| WebSocket Bot | 7272 | WS | Liquidity orderbook (Workerman) |
| **Trading Engine** | **8081** | HTTP/WS | Futures/Margin/Forex engine |
| **QuestDB HTTP** | **9000** | HTTP | Time-series queries |
| **QuestDB PG** | **8812** | PostgreSQL | Database protocol |
| QuestDB ILP | 9009 | TCP | InfluxDB line protocol |

---

## Firewall Configuration

```bash
# Basic ports (required)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp

# Internal services - DO NOT expose to internet
# These are only accessed via Nginx proxy
# - 3306 (MySQL)
# - 6379 (Redis)
# - 7272 (WebSocket Bot)
# - 8081 (Trading Engine)
# - 9000 (QuestDB)

# Enable firewall
sudo ufw enable
```

---

## Troubleshooting

### Trading Engine Not Starting

```bash
# Check PM2 logs
pm2 logs trading-engine --lines 50

# Check if port is in use
netstat -tlnp | grep 8081

# Check .env file
cat /home/wwwroot/api.exchange.com/backend/trading_engine/.env

# Restart trading engine
pm2 restart trading-engine
```

### WebSocket Connection Failed

```bash
# Test internal WebSocket bot
curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" \
  http://localhost:7272

# Test internal Trading Engine
curl http://localhost:8081/health

# Check Nginx proxy logs
tail -f /usr/local/nginx/logs/error.log
```

### Redis Connection Issues

```bash
# Test Redis with password
redis-cli -a your_redis_password ping

# Check Redis config
cat /usr/local/redis/etc/redis.conf | grep requirepass

# Verify PHP can connect
php -r "
\$redis = new Redis();
\$redis->connect('127.0.0.1', 6379);
\$redis->auth('your_redis_password');
echo \$redis->ping();
"
```

### Database Connection Issues

```bash
# Test MySQL connection
mysql -u root -p -e "SELECT 1"

# Check credentials in config
grep -E "DB_|MYSQL_" /home/wwwroot/api.exchange.com/backend/codebase/pure_config.php
grep -E "DB_|MYSQL_" /home/wwwroot/api.exchange.com/backend/trading_engine/.env
```

### QuestDB Connection Issues

```bash
# Check service status
sudo systemctl status questdb

# View logs
sudo journalctl -u questdb -f

# Test query
curl "http://localhost:9000/exec?query=SELECT%201"
```

---

## Post-Installation Checklist

- [ ] SSL certificates installed (Let's Encrypt)
- [ ] Admin panel accessible at `https://api.exchange.com/Admin`
- [ ] 2FA configured for admin account
- [ ] Trading Engine running (`pm2 status`)
- [ ] QuestDB running (`systemctl status questdb`)
- [ ] WebSocket connections working (test in browser console)
- [ ] Cron jobs verified (`crontab -l -u www`)
- [ ] Firewall configured (`ufw status`)
- [ ] Backups configured
- [ ] Frontend deployed to `https://exchange.com`
- [ ] Mobile app built with production environment
- [ ] All passwords in credentials.yml securely stored

---

## Architecture Overview

```text
                         Internet
                            │
                    ┌───────▼───────┐
                    │  Cloudflare   │
                    │  (Optional)   │
                    └───────┬───────┘
                            │
            ┌───────────────┼───────────────┐
            │               │               │
    ┌───────▼───────┐      │       ┌───────▼───────┐
    │   Nginx :443  │      │       │  Nginx :443   │
    │ api.exchange  │      │       │  exchange.com │
    │    .com       │      │       │  (Frontend)   │
    └───────┬───────┘      │       └───────┬───────┘
            │              │               │
    ┌───────▼───────┐      │       ┌───────┴───────────────┐
    │    PHP-FPM    │      │       │                       │
    │   (Backend)   │      │       │                       │
    └───────┬───────┘      │   ┌───▼────────┐    ┌────────▼────────┐
            │              │   │  /wsocket  │    │    /engine      │
            │              │   │ (Proxy)    │    │    (Proxy)      │
            │              │   └───┬────────┘    └────────┬────────┘
            │              │       │                      │
    ┌───────▼───────┐      │   ┌───▼────────┐    ┌────────▼────────┐
    │    MySQL      │      │   │ Workerman  │    │ Trading Engine  │
    │    :3306      │◄─────┼───│   :7272    │    │     :8081       │
    └───────────────┘      │   │ (PHP WS)   │    │   (Node.js)     │
                           │   └────────────┘    └────────┬────────┘
    ┌───────────────┐      │                              │
    │    Redis      │◄─────┼──────────────────────────────┤
    │    :6379      │      │                              │
    └───────────────┘      │                     ┌────────▼────────┐
                           │                     │    QuestDB      │
                           │                     │  :9000 / :8812  │
                           │                     └─────────────────┘
```

---

## Support

- **Telegram:** [@ctoninja](https://t.me/ctoninja)
- **Website:** [codono.com](https://codono.com)
- **Live Chat:** [codono.com/contact](https://codono.com/contact)
