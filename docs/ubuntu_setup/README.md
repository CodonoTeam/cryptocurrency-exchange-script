# Codono Exchange - Ubuntu Server Setup

Setup scripts for deploying Codono Exchange on Ubuntu 22.04 / 24.04 using standard `apt` packages.

## Prerequisites

- **OS:** Ubuntu 22.04 LTS or 24.04 LTS (64-bit)
- **RAM:** Minimum 2 GB (4 GB recommended)
- **Access:** Root or sudo privileges
- **Files:** `backend.zip` from your Codono account

## Getting Started

### Step 0a: Upload Backend

Upload your `backend.zip` to the `/opt/` folder on your server:

```bash
# Using SCP from your local machine
scp backend.zip root@YOUR_SERVER_IP:/opt/

# Or use FileZilla / WinSCP to upload to /opt/
```

### Step 0b: Download Setup Scripts

```bash
cd /opt/ && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/run1_ubuntu_lemp_setup.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/run2_domain_and_unzip.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/run3_config_part.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/run4_db_create_and_import.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/run5_websocket.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/run6_cron_setup.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/run7_show_admin_login.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/run8_trading_engine.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/run9_questdb.sh && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/check_ubuntu_status.sh && \
chmod +x *.sh
```

## Quick Start (Automated)

For a fully automated setup, use the master orchestrator:

```bash
cd /opt/ && \
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/codono_init.sh && \
chmod +x codono_init.sh && \
sudo bash codono_init.sh
```

This will guide you through domain setup, license verification, credential generation, and run all scripts in sequence.

## Manual Setup (Step by Step)

Run each script in order from `/opt/`. All scripts must be executed as root.

### Step 1: Install LEMP Stack

```bash
sudo bash run1_ubuntu_lemp_setup.sh
```

Installs and configures:
- **Nginx** (web server)
- **PHP 7.4** (via Ondrej PPA) with extensions: mysql, redis, curl, xml, mbstring, zip, gd, bcmath, gmp, intl, opcache, soap, swoole, memcached
- **MariaDB** (database server)
- **Redis** (cache & pub/sub)
- **Memcached** (session caching)

Generates credentials at `/opt/credentials.yml`.

### Step 2: Domain Setup & Code Extraction

```bash
sudo bash run2_domain_and_unzip.sh
```

- Extracts `/opt/backend.zip` to `/data/wwwroot/`
- Creates **two Nginx vhosts**:
  - `api.yourdomain.com` — Backend API (PHP-FPM)
  - `yourdomain.com` — Frontend (SPA, static files)
- Enables sites and reloads Nginx

### Step 3: Application Configuration

```bash
sudo bash run3_config_part.sh
```

- Moves `codebase/` to `/data/wwwroot/codebase/`
- Moves `webserver/*` to the API domain directory
- Updates `pure_config.php` with database, Redis, and site URL settings

### Step 4: Database Import

```bash
sudo bash run4_db_create_and_import.sh
```

- Creates the MySQL database
- Imports SQL schema and seed data
- Sets admin credentials and 2FA secret

### Step 5: WebSocket Setup

```bash
sudo bash run5_websocket.sh
```

- Installs Supervisor for the PHP socket bot (port 7272)
- Adds Nginx reverse proxy for `/wsocket` (port 7272) and `/engine` (port 8081)
- Configures WebSocket URL in `other_config.php`

### Step 6: Cron Jobs

```bash
sudo bash run6_cron_setup.sh
```

- Installs mandatory cron jobs (Tron deposits, chart generation, price updates, email queue, etc.)
- Optionally enables crons for: BTC, CryptoApis, Substrate, Blockgum, Cryptonote, Coinpayments

### Step 7: Show Admin Login

```bash
sudo bash run7_show_admin_login.sh
```

Displays admin panel URL, login credentials, and 2FA QR code.

### Step 8: Trading Engine (Optional)

```bash
sudo bash run8_trading_engine.sh
```

Required for **Futures**, **Margin Trading**, and **Forex** modules.

- Downloads the compiled trading engine binary to `/opt/trading-engine/`
- Creates comprehensive `.env` configuration with credentials
- Installs systemd service (`trading-engine.service`)
- Enables auto-start on boot

### Step 9: QuestDB (Optional)

```bash
sudo bash run9_questdb.sh
```

Required for high-performance **mark price queries** and **forex tick storage**.

- Installs Java 17 and QuestDB 7.4.0
- Creates `mark_prices` and `forex_ticks` tables
- Installs systemd service (`questdb.service`)

## Health Check

Run the status check script to verify all services:

```bash
sudo bash check_ubuntu_status.sh
```

Checks: Nginx, PHP-FPM, MariaDB, Redis, Memcached, Supervisor/socketbot, Trading Engine, QuestDB, PHP modules, Redis auth, MySQL connection, and recent log errors.

## Architecture

```
yourdomain.com (Frontend)          api.yourdomain.com (Backend API)
        |                                    |
    Nginx vhost                         Nginx vhost
    /index.html (SPA)                  /index.php (PHP-FPM)
    /wsocket  -> 127.0.0.1:7272       /Admin (basic auth)
    /engine   -> 127.0.0.1:8081       /Upload/coin/ (fallback)
```

### Directory Layout

```
/data/wwwroot/
    api.yourdomain.com/     # Backend PHP code (webserver/)
    yourdomain.com/         # Frontend dist (deployed separately)
    codebase/               # Shared backend code
    backend/                # Extracted backend.zip (SQL files, etc.)

/opt/
    credentials.yml         # All generated credentials
    trading-engine/         # Trading engine binary + .env + logs
    questdb/                # QuestDB installation + data
```

## Service Management

| Service | Start | Stop | Status | Logs |
|---------|-------|------|--------|------|
| Nginx | `systemctl start nginx` | `systemctl stop nginx` | `systemctl status nginx` | `/var/log/nginx/` |
| PHP-FPM | `systemctl start php7.4-fpm` | `systemctl stop php7.4-fpm` | `systemctl status php7.4-fpm` | `/var/log/php7.4-fpm.log` |
| MariaDB | `systemctl start mariadb` | `systemctl stop mariadb` | `systemctl status mariadb` | `/var/log/mysql/error.log` |
| Redis | `systemctl start redis-server` | `systemctl stop redis-server` | `systemctl status redis-server` | `/var/log/redis/redis-server.log` |
| Socketbot | `supervisorctl start socketbot` | `supervisorctl stop socketbot` | `supervisorctl status socketbot` | `/var/log/supervisor/` |
| Trading Engine | `systemctl start trading-engine` | `systemctl stop trading-engine` | `systemctl status trading-engine` | `journalctl -u trading-engine -f` |
| QuestDB | `systemctl start questdb` | `systemctl stop questdb` | `systemctl status questdb` | `journalctl -u questdb -f` |

## Credentials

All credentials are stored in `/opt/credentials.yml`:

```yaml
HTACCESS_USERNAME: ...    # Nginx basic auth (admin panel)
HTACCESS_PASSWORD: ...
REDIS_PASSWORD: ...
MYSQL_NEW_ROOT_PASSWORD: ...
DB_NAME: ...
ADMIN_KEY: ...            # Admin panel secret key
CRON_KEY: ...             # Cron job authentication
ADMIN_USER: ...           # Admin login username
ADMIN_PASS: ...           # Admin login password
TWO_FA_SECRET_KEY: ...    # Google Authenticator 2FA
DOMAIN: api.example.com
FRONTEND_DOMAIN: example.com
```

## SSL Setup

After all scripts complete, set up SSL with Certbot:

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com -d api.yourdomain.com
```

## Troubleshooting

**Services not starting:**
```bash
sudo bash check_ubuntu_status.sh    # Quick overview
journalctl -u <service-name> -n 50  # Detailed logs
```

**PHP extensions missing:**
```bash
php7.4 -m | grep <extension>
sudo apt install php7.4-<extension>
sudo systemctl restart php7.4-fpm
```

**Trading engine won't start:**
```bash
journalctl -u trading-engine -n 50 --no-pager
cat /opt/trading-engine/.env         # Check config
sudo -u www-data /opt/trading-engine/trading-engine-linux  # Test manually
```

**Nginx config errors:**
```bash
nginx -t                             # Test config syntax
cat /etc/nginx/sites-enabled/*.conf  # Review vhosts
```

## Support

- Telegram: https://t.me/ctoninja
- Website: https://codono.com
