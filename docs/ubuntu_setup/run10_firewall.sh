#!/bin/bash
# ============================================
# Codono Exchange - UFW Firewall Setup
# Configures firewall to allow only public ports
# ============================================

set -e

echo "=========================================="
echo "  UFW FIREWALL SETUP                     "
echo "=========================================="

# ============================================
# PORT MAP:
#
# ALLOW (public-facing):
#   22/tcp   SSH         - Remote server access
#   80/tcp   HTTP        - Nginx web + Let's Encrypt
#   443/tcp  HTTPS       - Nginx web (API + Frontend)
#
# DENY (internal only, defense-in-depth):
#   3306     MariaDB     - Database (bound to 127.0.0.1)
#   6379     Redis       - Cache/pub-sub (bound to 127.0.0.1)
#   11211    Memcached   - Session cache (bound to 127.0.0.1)
#   7272     SocketBot   - WebSocket (proxied via Nginx /wsocket)
#   8081     Engine WS   - Trading engine (proxied via Nginx /engine)
#   8082     Dashboard   - Engine dashboard (localhost only)
#   8812     QuestDB PG  - Time-series DB (bound to 127.0.0.1)
#   9000     QuestDB HTTP- Time-series DB (bound to 127.0.0.1)
#   9009     QuestDB ILP - Time-series DB (bound to 127.0.0.1)
# ============================================

# Install UFW if not present
if ! command -v ufw &> /dev/null; then
    echo "Installing UFW..."
    apt-get update && apt-get install -y ufw
fi

# Reset UFW to defaults (idempotent re-runs)
echo "Resetting UFW to defaults..."
ufw --force reset

# Default policy: deny incoming, allow outgoing
echo "Setting default policies..."
ufw default deny incoming
ufw default allow outgoing

# CRITICAL: Allow SSH first to prevent lockout
echo "Allowing SSH (port 22)..."
ufw allow 22/tcp comment 'SSH'

# Allow web traffic
echo "Allowing HTTP (port 80)..."
ufw allow 80/tcp comment 'HTTP - Nginx'

echo "Allowing HTTPS (port 443)..."
ufw allow 443/tcp comment 'HTTPS - Nginx'

# Explicitly deny internal service ports (defense-in-depth)
# These are already blocked by "default deny incoming" but
# explicit rules make the intent clear in "ufw status"
echo "Blocking internal service ports..."
ufw deny 3306/tcp comment 'MariaDB - internal only'
ufw deny 6379/tcp comment 'Redis - internal only'
ufw deny 11211/tcp comment 'Memcached - internal only'
ufw deny 7272/tcp comment 'SocketBot - proxied via Nginx'
ufw deny 8081/tcp comment 'Trading Engine WS - proxied via Nginx'
ufw deny 8082/tcp comment 'Trading Engine Dashboard - internal only'
ufw deny 8812/tcp comment 'QuestDB PostgreSQL - internal only'
ufw deny 9000/tcp comment 'QuestDB HTTP - internal only'
ufw deny 9009/tcp comment 'QuestDB InfluxDB - internal only'

# Enable UFW (non-interactive)
echo ""
echo "Enabling UFW..."
ufw --force enable

# Show status
echo ""
echo "=========================================="
echo "  UFW Firewall Status                    "
echo "=========================================="
ufw status verbose

echo ""
echo "=========================================="
echo "  Firewall Setup Complete!               "
echo "=========================================="
echo ""
echo "Allowed ports:"
echo "  22/tcp   - SSH"
echo "  80/tcp   - HTTP (Nginx)"
echo "  443/tcp  - HTTPS (Nginx)"
echo ""
echo "All other incoming traffic is blocked."
echo ""
echo "Useful commands:"
echo "  ufw status          - Show firewall status"
echo "  ufw allow <port>    - Open a port"
echo "  ufw delete allow <port> - Close a port"
echo "  ufw disable         - Temporarily disable firewall"
echo ""
