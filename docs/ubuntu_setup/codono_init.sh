#!/bin/bash
# ============================================
# CODONO EXCHANGE - ONE-COMMAND SETUP (Ubuntu)
# ============================================
# Uses standard Ubuntu apt packages instead of OneInStack
# Supports: Ubuntu 22.04, 24.04
#
# Run with: curl -sSL https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/codono_init.sh | bash
# Or: wget -qO- https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup/codono_init.sh | bash
# ============================================

set -e
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
LICENSE_VERIFY_URL="https://account.codono.com/verify-license.php"
SCRIPTS_BASE_URL="https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/ubuntu_setup"
CREDENTIALS_FILE="/opt/credentials.yml"

# ============================================
# HELPER FUNCTIONS
# ============================================

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║     ██████╗ ██████╗ ██████╗  ██████╗ ███╗   ██╗ ██████╗     ║"
    echo "║    ██╔════╝██╔═══██╗██╔══██╗██╔═══██╗████╗  ██║██╔═══██╗    ║"
    echo "║    ██║     ██║   ██║██║  ██║██║   ██║██╔██╗ ██║██║   ██║    ║"
    echo "║    ██║     ██║   ██║██║  ██║██║   ██║██║╚██╗██║██║   ██║    ║"
    echo "║    ╚██████╗╚██████╔╝██████╔╝╚██████╔╝██║ ╚████║╚██████╔╝    ║"
    echo "║     ╚═════╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝    ║"
    echo "║                                                              ║"
    echo "║          CRYPTOCURRENCY EXCHANGE - AUTO INSTALLER            ║"
    echo "║                 Ubuntu Native (No OneInStack)                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "\n${GREEN}[STEP $1]${NC} $2"
    echo "════════════════════════════════════════════════════════════════"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Generate random string
generate_random() {
    local length=${1:-16}
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length"
}

# Generate random password with prefix
generate_password() {
    local prefix=$1
    echo "${prefix}_$(generate_random 12)"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root"
        echo "Please run: sudo bash codono_init.sh"
        exit 1
    fi
}

# Check OS
check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VERSION=$VERSION_ID
    else
        print_error "Cannot detect OS. This script supports Ubuntu 22.04/24.04."
        exit 1
    fi

    if [[ "$OS" != *"Ubuntu"* ]]; then
        print_error "This script only supports Ubuntu. Detected: $OS"
        exit 1
    fi

    if [[ "$VERSION" != "22.04" && "$VERSION" != "24.04" ]]; then
        print_warning "Recommended Ubuntu versions: 22.04, 24.04. Detected: $VERSION"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# ============================================
# LICENSE VERIFICATION
# ============================================

verify_license() {
    print_step "1" "License Verification"

    # Get license key from user
    echo -e "\n${CYAN}Enter your Codono license key:${NC}"
    read -p "License Key: " LICENSE_KEY

    if [ -z "$LICENSE_KEY" ]; then
        print_error "License key cannot be empty"
        exit 1
    fi

    # Get API domain from user
    echo -e "\n${CYAN}Enter your API domain (e.g., api.exchange.com):${NC}"
    read -p "API Domain: " API_DOMAIN

    if [ -z "$API_DOMAIN" ]; then
        print_error "API domain cannot be empty"
        exit 1
    fi

    # Validate domain format
    if [[ ! "$API_DOMAIN" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        print_error "Invalid domain format: $API_DOMAIN"
        exit 1
    fi

    print_info "Verifying license with Codono servers..."

    # Make API request to verify license
    RESPONSE=$(curl -s -X POST "$LICENSE_VERIFY_URL" \
        -H "Content-Type: application/json" \
        -d "{\"license_key\": \"$LICENSE_KEY\", \"domain\": \"$API_DOMAIN\"}" \
        --connect-timeout 30 \
        --max-time 60)

    if [ -z "$RESPONSE" ]; then
        print_error "Failed to connect to license server. Please check your internet connection."
        exit 1
    fi

    # Parse response
    STATUS=$(echo "$RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    CODE=$(echo "$RESPONSE" | grep -o '"code":[0-9]*' | cut -d':' -f2)
    MSG=$(echo "$RESPONSE" | grep -o '"msg":"[^"]*"' | cut -d'"' -f4)
    DOWNLOAD_URL=$(echo "$RESPONSE" | grep -o '"download_url":"[^"]*"' | cut -d'"' -f4)

    if [ "$STATUS" != "success" ] || [ "$CODE" != "200" ]; then
        print_error "License verification failed!"
        echo -e "${RED}Server response: $MSG${NC}"
        echo ""
        echo "Please check:"
        echo "  1. Your license key is correct"
        echo "  2. The domain matches your license"
        echo "  3. Your license has not expired"
        echo ""
        echo "Contact support: https://t.me/ctoninja"
        exit 1
    fi

    print_success "License verified successfully!"
    print_info "Message: $MSG"

    # Store download URL for later use
    BACKEND_DOWNLOAD_URL="$DOWNLOAD_URL"
}

# ============================================
# GATHER USER INFORMATION
# ============================================

gather_information() {
    print_step "2" "Gathering Configuration Information"

    echo -e "\n${CYAN}We need some information to configure your exchange.${NC}\n"

    # Frontend domain (derived from API domain or entered separately)
    FRONTEND_DOMAIN=$(echo "$API_DOMAIN" | sed 's/^api\.//')
    echo -e "${YELLOW}Frontend domain (derived): ${FRONTEND_DOMAIN}${NC}"
    echo -e "${YELLOW}Press Enter to accept, or type a different domain:${NC}"
    read -p "Frontend Domain [$FRONTEND_DOMAIN]: " CUSTOM_FRONTEND
    if [ -n "$CUSTOM_FRONTEND" ]; then
        FRONTEND_DOMAIN="$CUSTOM_FRONTEND"
    fi

    # Exchange name
    echo -e "\n${YELLOW}Enter your exchange name (e.g., MyExchange):${NC}"
    read -p "Exchange Name: " EXCHANGE_NAME

    if [ -z "$EXCHANGE_NAME" ]; then
        EXCHANGE_NAME="Codono"
    fi

    # Support email
    echo -e "\n${YELLOW}Enter support email address:${NC}"
    read -p "Support Email: " SUPPORT_EMAIL

    if [ -z "$SUPPORT_EMAIL" ]; then
        SUPPORT_EMAIL="support@$FRONTEND_DOMAIN"
    fi

    # Enable modules
    echo -e "\n${YELLOW}Enable Futures Trading? (y/n) [default: y]:${NC}"
    read -p "" -n 1 ENABLE_FUTURES
    echo
    ENABLE_FUTURES=${ENABLE_FUTURES:-y}

    echo -e "${YELLOW}Enable Margin Trading? (y/n) [default: y]:${NC}"
    read -p "" -n 1 ENABLE_MARGIN
    echo
    ENABLE_MARGIN=${ENABLE_MARGIN:-y}

    echo -e "${YELLOW}Enable Forex Trading? (y/n) [default: y]:${NC}"
    read -p "" -n 1 ENABLE_FOREX
    echo
    ENABLE_FOREX=${ENABLE_FOREX:-y}

    echo -e "${YELLOW}Enable P2P Trading? (y/n) [default: y]:${NC}"
    read -p "" -n 1 ENABLE_P2P
    echo
    ENABLE_P2P=${ENABLE_P2P:-y}

    # Server IP
    SERVER_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || hostname -I | awk '{print $1}')

    echo -e "\n${CYAN}Configuration Summary:${NC}"
    echo "════════════════════════════════════════════════════════════════"
    echo "  License Key:      ${LICENSE_KEY:0:8}...${LICENSE_KEY: -4}"
    echo "  API Domain:       $API_DOMAIN"
    echo "  Frontend Domain:  $FRONTEND_DOMAIN"
    echo "  Exchange Name:    $EXCHANGE_NAME"
    echo "  Support Email:    $SUPPORT_EMAIL"
    echo "  Server IP:        $SERVER_IP"
    echo "  Futures Trading:  $([[ $ENABLE_FUTURES =~ ^[Yy]$ ]] && echo 'Enabled' || echo 'Disabled')"
    echo "  Margin Trading:   $([[ $ENABLE_MARGIN =~ ^[Yy]$ ]] && echo 'Enabled' || echo 'Disabled')"
    echo "  Forex Trading:    $([[ $ENABLE_FOREX =~ ^[Yy]$ ]] && echo 'Enabled' || echo 'Disabled')"
    echo "  P2P Trading:      $([[ $ENABLE_P2P =~ ^[Yy]$ ]] && echo 'Enabled' || echo 'Disabled')"
    echo "════════════════════════════════════════════════════════════════"

    echo -e "\n${YELLOW}Is this configuration correct? (y/n):${NC}"
    read -p "" -n 1 CONFIRM
    echo

    if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
        print_info "Please run the script again with correct information."
        exit 0
    fi
}

# ============================================
# GENERATE CREDENTIALS
# ============================================

generate_credentials() {
    print_step "3" "Generating Secure Credentials"

    # Generate all random credentials
    HTACCESS_USERNAME=$(generate_password "HU")
    HTACCESS_PASSWORD=$(generate_password "HP")
    REDIS_PASSWORD=$(generate_random 24)
    MYSQL_ROOT_PASSWORD=$(generate_password "MP")
    DB_NAME="DBN_$(generate_random 8)"
    ADMIN_KEY=$(generate_password "AK")
    CRON_KEY=$(generate_password "CK")
    ADMIN_USER=$(generate_password "AU")
    ADMIN_PASS=$(generate_password "AP")
    TWO_FA_SECRET=$(generate_random 16 | base32)
    ETH_USER_PASS=$(generate_random 32)

    # Create credentials.yml with UPPERCASE keys (matching run1-run9 format)
    print_info "Creating credentials file at $CREDENTIALS_FILE"

    cat > "$CREDENTIALS_FILE" << EOF
# ============================================
# CODONO EXCHANGE CREDENTIALS
# Generated: $(date)
# Setup: Ubuntu Native (apt packages)
# ============================================
# WARNING: Keep this file secure! Do not share!
# ============================================

# Domain Configuration
DOMAIN: $API_DOMAIN
FRONTEND_DOMAIN: $FRONTEND_DOMAIN
SERVER_IP: $SERVER_IP

# Exchange Settings
EXCHANGE_NAME: $EXCHANGE_NAME
SUPPORT_EMAIL: $SUPPORT_EMAIL

# HTTP Basic Auth (Admin Protection via Nginx)
HTACCESS_USERNAME: $HTACCESS_USERNAME
HTACCESS_PASSWORD: $HTACCESS_PASSWORD

# Redis Configuration
REDIS_HOST: 127.0.0.1
REDIS_PORT: 6379
REDIS_PASSWORD: $REDIS_PASSWORD
REDIS_DB: 0
REDIS_FOREX_DB: 1

# MySQL Database
MYSQL_HOST: 127.0.0.1
MYSQL_PORT: 3306
MYSQL_NEW_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD
DB_NAME: $DB_NAME

# Application Security Keys
ADMIN_KEY: $ADMIN_KEY
CRON_KEY: $CRON_KEY
ETH_USER_PASS: $ETH_USER_PASS

# Admin Panel Credentials
ADMIN_USER: $ADMIN_USER
ADMIN_PASS: $ADMIN_PASS
TWO_FA_SECRET_KEY: $TWO_FA_SECRET

# Module Configuration
ENABLE_FUTURES: $([[ $ENABLE_FUTURES =~ ^[Yy]$ ]] && echo '1' || echo '0')
ENABLE_MARGIN: $([[ $ENABLE_MARGIN =~ ^[Yy]$ ]] && echo '1' || echo '0')
ENABLE_FOREX: $([[ $ENABLE_FOREX =~ ^[Yy]$ ]] && echo '1' || echo '0')
ENABLE_P2P: $([[ $ENABLE_P2P =~ ^[Yy]$ ]] && echo '1' || echo '0')

# WebSocket URLs (for frontend/mobile app)
WS_URL: wss://$FRONTEND_DOMAIN/wsocket
ENGINE_WS_URL: wss://$FRONTEND_DOMAIN/engine

# API URLs
API_URL: https://$API_DOMAIN
API_HTTP_URL: https://$API_DOMAIN/Http
API_HAPI_URL: https://$API_DOMAIN/Hapi
FRONTEND_URL: https://$FRONTEND_DOMAIN
IMG_URL: https://$API_DOMAIN/Upload

# QuestDB Configuration
QUESTDB_HOST: 127.0.0.1
QUESTDB_HTTP_PORT: 9000
QUESTDB_PG_PORT: 8812
QUESTDB_PG_USER: admin
QUESTDB_PG_PASSWORD: quest

# Trading Engine Configuration
TRADING_ENGINE_PORT: 8081
WEBSOCKET_BOT_PORT: 7272
EOF

    chmod 600 "$CREDENTIALS_FILE"
    print_success "Credentials file created: $CREDENTIALS_FILE"
}

# ============================================
# DOWNLOAD BACKEND
# ============================================

download_backend() {
    print_step "4" "Downloading Backend Package"

    cd /opt

    if [ -f "backend.zip" ]; then
        print_warning "backend.zip already exists. Backing up..."
        mv backend.zip "backend.zip.bak.$(date +%Y%m%d%H%M%S)"
    fi

    print_info "Downloading from: $BACKEND_DOWNLOAD_URL"

    if ! wget -q --show-progress "$BACKEND_DOWNLOAD_URL" -O backend.zip; then
        print_error "Failed to download backend.zip"
        exit 1
    fi

    # Verify download
    if [ ! -f "backend.zip" ] || [ ! -s "backend.zip" ]; then
        print_error "Download failed or file is empty"
        exit 1
    fi

    print_success "Backend package downloaded successfully"
}

# ============================================
# DOWNLOAD SETUP SCRIPTS
# ============================================

download_scripts() {
    print_step "5" "Downloading Setup Scripts"

    cd /opt

    SCRIPTS=(
        "run1_ubuntu_lemp_setup.sh"
        "run2_domain_and_unzip.sh"
        "run3_config_part.sh"
        "run4_db_create_and_import.sh"
        "run5_websocket.sh"
        "run6_cron_setup.sh"
        "run7_show_admin_login.sh"
        "run8_trading_engine.sh"
        "run9_questdb.sh"
        "check_ubuntu_status.sh"
    )

    for script in "${SCRIPTS[@]}"; do
        print_info "Downloading $script..."
        if ! wget -q "$SCRIPTS_BASE_URL/$script" -O "$script"; then
            print_warning "Failed to download $script (may not exist yet)"
        else
            chmod +x "$script"
        fi
    done

    print_success "Setup scripts downloaded"
}

# ============================================
# RUN SETUP STEPS
# ============================================

run_setup() {
    print_step "6" "Running Automated Setup"

    cd /opt

    # Step 1: Install LEMP Stack
    echo -e "\n${CYAN}[6.1] Installing LEMP Stack (Nginx, PHP 7.4, MariaDB, Redis)...${NC}"
    if [ -f "run1_ubuntu_lemp_setup.sh" ]; then
        # Skip screen session in run1 — codono_init runs inline
        export CODONO_NO_SCREEN=1
        ./run1_ubuntu_lemp_setup.sh
    else
        print_error "run1_ubuntu_lemp_setup.sh not found"
        exit 1
    fi

    # Step 2: Domain and Unzip
    echo -e "\n${CYAN}[6.2] Setting up domains and extracting code...${NC}"
    if [ -f "run2_domain_and_unzip.sh" ]; then
        ./run2_domain_and_unzip.sh
    fi

    # Step 3: Configuration
    echo -e "\n${CYAN}[6.3] Configuring application...${NC}"
    if [ -f "run3_config_part.sh" ]; then
        ./run3_config_part.sh
    fi

    # Step 4: Database
    echo -e "\n${CYAN}[6.4] Creating database and importing data...${NC}"
    if [ -f "run4_db_create_and_import.sh" ]; then
        ./run4_db_create_and_import.sh
    fi

    # Step 5: WebSocket
    echo -e "\n${CYAN}[6.5] Setting up WebSocket server...${NC}"
    if [ -f "run5_websocket.sh" ]; then
        ./run5_websocket.sh
    fi

    # Step 6: Cron Jobs
    echo -e "\n${CYAN}[6.6] Setting up cron jobs...${NC}"
    if [ -f "run6_cron_setup.sh" ]; then
        ./run6_cron_setup.sh
    fi

    # Step 7: Trading Engine (if futures/margin/forex enabled)
    if [[ $ENABLE_FUTURES =~ ^[Yy]$ ]] || [[ $ENABLE_MARGIN =~ ^[Yy]$ ]] || [[ $ENABLE_FOREX =~ ^[Yy]$ ]]; then
        echo -e "\n${CYAN}[6.7] Setting up Trading Engine...${NC}"
        if [ -f "run8_trading_engine.sh" ]; then
            ./run8_trading_engine.sh
        fi

        echo -e "\n${CYAN}[6.8] Setting up QuestDB...${NC}"
        if [ -f "run9_questdb.sh" ]; then
            ./run9_questdb.sh
        fi
    fi

    print_success "Automated setup completed!"
}

# ============================================
# CONFIGURE NGINX FOR WEBSOCKETS
# ============================================

configure_nginx_websockets() {
    print_step "7" "Configuring Nginx WebSocket Proxies"

    NGINX_CONF="/etc/nginx/sites-available/$FRONTEND_DOMAIN.conf"

    if [ ! -f "$NGINX_CONF" ]; then
        print_warning "Frontend Nginx config not found. Creating basic configuration..."

        cat > "$NGINX_CONF" << EOF
# Frontend Server with WebSocket Proxies
# Generated by codono_init.sh

server {
    listen 80;
    server_name $FRONTEND_DOMAIN;
    root /data/wwwroot/$FRONTEND_DOMAIN;
    index index.html;

    # SPA fallback for Vue/React frontend
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # WebSocket: Liquidity/Orderbook Bot
    location /wsocket {
        proxy_pass http://127.0.0.1:7272;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }

    # WebSocket: Trading Engine (Futures/Margin/Forex)
    location /engine {
        proxy_pass http://127.0.0.1:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }

    # Health check endpoint
    location /engine/health {
        proxy_pass http://127.0.0.1:8081/health;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
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
EOF

        ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
    else
        # Add WebSocket locations to existing config if not already present
        print_info "Adding WebSocket proxy configurations to existing Nginx config..."

        if ! grep -q "location /wsocket" "$NGINX_CONF"; then
            sed -i '/^}$/i\
    # WebSocket: Liquidity/Orderbook Bot\
    location /wsocket {\
        proxy_pass http://127.0.0.1:7272;\
        proxy_http_version 1.1;\
        proxy_set_header Upgrade $http_upgrade;\
        proxy_set_header Connection "upgrade";\
        proxy_set_header Host $host;\
        proxy_set_header X-Real-IP $remote_addr;\
        proxy_read_timeout 86400;\
    }\
\
    # WebSocket: Trading Engine\
    location /engine {\
        proxy_pass http://127.0.0.1:8081;\
        proxy_http_version 1.1;\
        proxy_set_header Upgrade $http_upgrade;\
        proxy_set_header Connection "upgrade";\
        proxy_set_header Host $host;\
        proxy_set_header X-Real-IP $remote_addr;\
        proxy_read_timeout 86400;\
    }' "$NGINX_CONF"
        fi
    fi

    # Test and reload Nginx
    if nginx -t 2>/dev/null; then
        systemctl reload nginx
        print_success "Nginx WebSocket configuration applied"
    else
        print_warning "Nginx configuration test failed. Please check manually."
    fi
}

# ============================================
# UPDATE TRADING ENGINE .ENV
# ============================================

update_trading_engine_env() {
    print_step "8" "Configuring Trading Engine"

    TRADING_ENGINE_INSTALL="/opt/trading-engine"

    if [ -d "$TRADING_ENGINE_INSTALL" ]; then
        cat > "$TRADING_ENGINE_INSTALL/.env" << EOF
# ============================================
# TRADING ENGINE CONFIGURATION
# Generated by codono_init.sh
# Edit and restart: systemctl restart trading-engine
# ============================================

NODE_ENV=production
LOG_LEVEL=info
STARTUP_RETRY_DELAY_MS=10000

# Redis Configuration
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=$REDIS_PASSWORD
REDIS_DB=0
REDIS_FOREX_DB=1

# MySQL Configuration
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_DATABASE=$DB_NAME
MYSQL_CONNECTION_LIMIT=10

# QuestDB Configuration
QUESTDB_ENABLED=true
QUESTDB_HOST=127.0.0.1
QUESTDB_PORT=9000

# WebSocket Server
WS_PORT=8081

# Matching Engine Settings
MATCHING_INTERVAL_MS=10
PRICE_UPDATE_INTERVAL_MS=1000
PRICE_REQUEST_TIMEOUT_MS=5000
DEPTH_UPDATE_INTERVAL_MS=500
LIQUIDATION_CHECK_INTERVAL_MS=5000
ADL_RANKING_INTERVAL_MS=5000

# Forex Configuration
FOREX_POLL_INTERVAL_MS=2000
FOREX_TICK_STORE=questdb
FOREX_TICK_STORE_ENABLED=true
FOREX_TICK_FLUSH_INTERVAL_MS=1000
FOREX_TICK_BUFFER_SIZE=100
FOREX_TICK_RETENTION_DAYS=30

# Forex Price Providers (edit as needed)
FOREX_PROVIDER_TRADINGVIEW_ENABLED=true
FOREX_PROVIDER_FREEFOREXAPI_ENABLED=false
FOREX_PROVIDER_MQL5_ENABLED=false

# Dashboard
DASHBOARD_PORT=8082
DASHBOARD_AUTH_ENABLED=false
EOF

        chown www-data:www-data "$TRADING_ENGINE_INSTALL/.env"
        print_success "Trading Engine .env configured at $TRADING_ENGINE_INSTALL/.env"

        # Restart trading engine if systemd service exists
        if systemctl is-active --quiet trading-engine 2>/dev/null; then
            systemctl restart trading-engine 2>/dev/null || true
        fi
    else
        print_warning "Trading engine not installed at $TRADING_ENGINE_INSTALL (run run8 first)"
    fi
}

# ============================================
# SETUP SSL WITH CERTBOT
# ============================================

setup_ssl() {
    print_step "9" "Setting up SSL Certificates"

    # Install certbot
    if ! command -v certbot &> /dev/null; then
        print_info "Installing certbot..."
        apt-get install -y certbot python3-certbot-nginx
    fi

    print_info "Requesting SSL certificates for $API_DOMAIN and $FRONTEND_DOMAIN..."
    print_warning "Make sure DNS is already pointing to this server ($SERVER_IP)"

    echo -e "\n${YELLOW}Attempt SSL certificate setup now? (y/n) [default: n]:${NC}"
    read -p "" -n 1 SETUP_SSL
    echo
    SETUP_SSL=${SETUP_SSL:-n}

    if [[ $SETUP_SSL =~ ^[Yy]$ ]]; then
        certbot --nginx -d "$API_DOMAIN" -d "$FRONTEND_DOMAIN" \
            --non-interactive --agree-tos --email "$SUPPORT_EMAIL" || \
            print_warning "SSL setup failed. You can retry later with: certbot --nginx -d $API_DOMAIN -d $FRONTEND_DOMAIN"
    else
        print_info "Skipping SSL setup. Run this later:"
        echo "  certbot --nginx -d $API_DOMAIN -d $FRONTEND_DOMAIN"
    fi
}

# ============================================
# SHOW FINAL SUMMARY
# ============================================

show_summary() {
    print_step "10" "Installation Complete!"

    echo -e "\n${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           CODONO EXCHANGE INSTALLATION COMPLETE              ║"
    echo "║                  (Ubuntu Native Setup)                       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "${CYAN}Access URLs:${NC}"
    echo "  Admin Panel:    https://$API_DOMAIN/Admin"
    echo "  API Endpoint:   https://$API_DOMAIN/Http"
    echo "  Frontend:       https://$FRONTEND_DOMAIN"
    echo ""

    echo -e "${CYAN}Admin Login:${NC}"
    echo "  Username:       $ADMIN_USER"
    echo "  Password:       $ADMIN_PASS"
    echo "  2FA Secret:     $TWO_FA_SECRET"
    echo ""

    echo -e "${CYAN}Database:${NC}"
    echo "  Host:           127.0.0.1:3306"
    echo "  Database:       $DB_NAME"
    echo "  User:           root"
    echo "  Password:       $MYSQL_ROOT_PASSWORD"
    echo ""

    echo -e "${CYAN}Redis:${NC}"
    echo "  Host:           127.0.0.1:6379"
    echo "  Password:       $REDIS_PASSWORD"
    echo ""

    echo -e "${CYAN}WebSocket URLs (for frontend/mobile):${NC}"
    echo "  Orderbook WS:   wss://$FRONTEND_DOMAIN/wsocket"
    echo "  Trading Engine:  wss://$FRONTEND_DOMAIN/engine"
    echo ""

    echo -e "${CYAN}API URLs (for frontend/mobile):${NC}"
    echo "  Base URL:       https://$API_DOMAIN"
    echo "  HTTP API:       https://$API_DOMAIN/Http"
    echo "  HAPI:           https://$API_DOMAIN/Hapi"
    echo "  Images:         https://$API_DOMAIN/Upload"
    echo ""

    echo -e "${CYAN}Directory Structure:${NC}"
    echo "  API Backend:     /data/wwwroot/$API_DOMAIN/"
    echo "  Backend Code:    /data/wwwroot/codebase/"
    echo "  Frontend:        /data/wwwroot/$FRONTEND_DOMAIN/"
    echo ""

    echo -e "${YELLOW}IMPORTANT:${NC}"
    echo "  1. All credentials saved in: $CREDENTIALS_FILE"
    echo "  2. Set up SSL: certbot --nginx -d $API_DOMAIN -d $FRONTEND_DOMAIN"
    echo "  3. Configure DNS: Point both domains to $SERVER_IP"
    echo "  4. Use credentials.yml values when building frontend/mobile app"
    echo ""

    echo -e "${CYAN}Service Management:${NC}"
    echo "  Check all:       ./check_ubuntu_status.sh"
    echo "  Nginx:           systemctl status nginx"
    echo "  PHP-FPM:         systemctl status php7.4-fpm"
    echo "  MariaDB:         systemctl status mariadb"
    echo "  Redis:           systemctl status redis-server"
    echo "  Trading Engine:  systemctl status trading-engine"
    echo "  QuestDB:         systemctl status questdb"
    echo "  Socketbot:       supervisorctl status socketbot"
    echo ""

    echo -e "${GREEN}Thank you for choosing Codono!${NC}"
    echo "Support: https://t.me/ctoninja | https://codono.com"
    echo ""

    # Show 2FA QR code if qrencode is available
    if command -v qrencode &> /dev/null; then
        echo -e "${CYAN}Scan this QR code with Google Authenticator for 2FA:${NC}"
        qrencode -t ANSIUTF8 "otpauth://totp/$EXCHANGE_NAME:$ADMIN_USER?secret=$TWO_FA_SECRET&issuer=$EXCHANGE_NAME"
    else
        echo -e "${YELLOW}Install qrencode to display 2FA QR code: apt install qrencode${NC}"
    fi
}

# ============================================
# MAIN EXECUTION
# ============================================

main() {
    print_banner

    # Pre-flight checks
    check_root
    check_os

    # Setup steps
    verify_license
    gather_information
    generate_credentials
    download_backend
    download_scripts
    run_setup
    configure_nginx_websockets
    update_trading_engine_env
    setup_ssl

    # Final summary
    show_summary
}

# Run main function
main "$@"
