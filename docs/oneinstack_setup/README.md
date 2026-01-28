<<<<<<< HEAD
# Codono Exchange - Automatic Setup Guide

Complete setup guide for deploying Codono Cryptocurrency Exchange on a fresh Ubuntu server.

## Prerequisites

- **OS:** Ubuntu 20.04/22.04 LTS
- **RAM:** Minimum 4GB (8GB recommended for Futures/Margin)
- **Storage:** 50GB+ SSD
- **Network:** Public IP with ports 80, 443 open

## Quick Overview

| Step | Script | Purpose |
|------|--------|---------|
| 1 | Upload backend.zip | Upload files to server |
| 2 | Download scripts | Get all setup scripts |
| 3 | run1_all_in_onestack_setup.sh | Install LEMP stack |
| 4 | run2_domain_and_unzip.sh | Setup domain & extract code |
| 5 | run3_config_part.sh | Configure application |
| 6 | run4_db_create_and_import.sh | Create database |
| 7 | run5_websocket.sh | Start liquidity WebSocket |
| 8 | run6_cron_setup.sh | Setup cron jobs |
| 9 | run7_show_admin_login.sh | Show admin credentials |
| 10 | run8_trading_engine.sh | **[NEW]** Setup Trading Engine |
| 11 | run9_questdb.sh | **[NEW]** Setup QuestDB |

---

## Step 1: Upload Backend

Upload your `backend.zip` to `/opt` folder on the server using:

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
=======
*** Step 1
First Upload your zip backend.zip to /opt folder of server
You can use scp or upload using filezilla
*** Step 2
Run following
```
cd /opt/ &&
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run1_all_in_onestack_setup.sh &&
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run2_domain_and_unzip.sh &&
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run3_config_part.sh &&
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run4_db_create_and_import.sh &&
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run5_websocket.sh &&
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run6_cron_setup.sh &&
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run7_show_admin_login.sh
chmod +x run1_all_in_onestack_setup.sh &&
chmod +x run2_domain_and_unzip.sh &&
chmod +x run3_config_part.sh &&
chmod +x run4_db_create_and_import.sh &&
chmod +x run5_websocket.sh &&
chmod +x run6_cron_setup.sh &&
chmod +x run7_show_admin_login.sh
```

Step 3.
Environment setup, make sure backend.zip was uploaded to /opt folder already.
```
>>>>>>> origin/main
cd /opt/
./run1_all_in_onestack_setup.sh
```

<<<<<<< HEAD
---

## Step 4: Domain & Code Setup

Create domain directory, extract and place code:

```bash
=======
Step 4.
Run to create domain directory , unzip code and place them in correct place.
```
>>>>>>> origin/main
cd /opt/
./run2_domain_and_unzip.sh
```

<<<<<<< HEAD
---

## Step 5: Application Configuration

Configure database credentials and application settings:

```bash
=======

Step 5.
Run to create pure_config update db and other info using credentials.yml.
```
>>>>>>> origin/main
cd /opt/
./run3_config_part.sh
```

<<<<<<< HEAD
---

## Step 6: Database Setup

Create database, import SQL, and set admin credentials:

```bash
=======
Step 6.
Run to create db , import SQL file in it and update admin credentials.
```
>>>>>>> origin/main
cd /opt/
./run4_db_create_and_import.sh
```

<<<<<<< HEAD
---

## Step 7: Liquidity WebSocket

Start WebSocket server for market liquidity:

```bash
=======

Step 7.
Run to start websocket for Liquidity markets
```
>>>>>>> origin/main
cd /opt/
./run5_websocket.sh
```

<<<<<<< HEAD
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

## Step 10: Trading Engine Setup (NEW)

**Required for:** Perpetual Futures, Margin Trading, Real-time Prices

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

## Step 11: QuestDB Setup (NEW)

**Required for:** High-performance mark price queries

```bash
cd /opt/
./run9_questdb.sh
```

This installs:
- QuestDB time-series database
- Creates `mark_prices` table
- Starts on ports 9000 (HTTP) and 8812 (PostgreSQL)

**Verify:**
```bash
sudo systemctl status questdb
curl "http://localhost:9000/exec?query=SELECT%201"
```

---

## Service Ports Reference

| Service | Port | Protocol | Description |
|---------|------|----------|-------------|
| Nginx | 80 | HTTP | Web server (redirect to HTTPS) |
| Nginx | 443 | HTTPS | Web server (SSL) |
| MySQL | 3306 | TCP | Database |
| Redis | 6379 | TCP | Cache & pub/sub |
| PHP-FPM | 9000 | Socket | PHP processor |
| WebSocket | 2120 | WS | Liquidity orderbook |
| **Trading Engine** | **8081** | HTTP/WS | Futures/Margin engine |
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

# Internal services (restrict to internal network in production)
# Trading Engine - only needed if external access required
# sudo ufw allow 8081/tcp

# QuestDB - only needed for external monitoring
# sudo ufw allow 9000/tcp

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

# Restart trading engine
pm2 restart trading-engine
```

### QuestDB Connection Issues

```bash
# Check service status
sudo systemctl status questdb

# View logs
sudo journalctl -u questdb -f

# Check if ports are listening
netstat -tlnp | grep -E "9000|8812"

# Restart QuestDB
sudo systemctl restart questdb
```

### WebSocket Connection Failed

```bash
# Check if trading engine is running
curl http://localhost:8081/health

# Check WebSocket endpoint
curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" \
  http://localhost:8081
```

### Database Connection Issues

```bash
# Test MySQL connection
mysql -u root -p -e "SELECT 1"

# Check MySQL status
sudo systemctl status mysql

# Check credentials in config
cat /home/wwwroot/YOUR_DOMAIN/backend/codebase/Application/Common/Conf/pure_config.php | grep DB_
```

### Redis Connection Issues

```bash
# Test Redis
redis-cli ping

# Check Redis status
sudo systemctl status redis
```

---

## Post-Installation Checklist

- [ ] SSL certificate installed (Let's Encrypt)
- [ ] Admin panel accessible
- [ ] 2FA configured for admin
- [ ] Trading Engine running (pm2 status)
- [ ] QuestDB running (systemctl status questdb)
- [ ] Cron jobs verified (crontab -l -u www)
- [ ] Firewall configured
- [ ] Backups configured

---

## Architecture Overview

```
                    ┌─────────────────┐
                    │   Cloudflare    │
                    │   (Optional)    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │     Nginx       │
                    │   :80 / :443    │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
┌────────▼────────┐ ┌────────▼────────┐ ┌────────▼────────┐
│     PHP-FPM     │ │ Trading Engine  │ │   WebSocket     │
│   (Backend)     │ │     :8081       │ │     :2120       │
└────────┬────────┘ └────────┬────────┘ └─────────────────┘
         │                   │
         │          ┌────────┴────────┐
         │          │                 │
┌────────▼────────┐ │ ┌───────────────▼──┐
│      MySQL      │ │ │     QuestDB      │
│     :3306       │ │ │   :9000 / :8812  │
└─────────────────┘ │ └──────────────────┘
                    │
           ┌────────▼────────┐
           │      Redis      │
           │     :6379       │
           └─────────────────┘
```

---

## Support

- **Telegram:** [@ctoninja](https://t.me/ctoninja)
- **Website:** [codono.com](https://codono.com)
- **Live Chat:** [codono.com/contact](https://codono.com/contact)
=======
Step 8.
Run to setup crons with www user in crontab . We suggest double checking crons.
```
cd /opt/
./run6_cron_setup.sh.sh
```

Step 9.
Run to show admin login information , also one qrcode shows , which you can scan with authy like app to generate 6 digit 2fa for admin login

```
cd /opt/
./run7_show_admin_login.sh
```
>>>>>>> origin/main
