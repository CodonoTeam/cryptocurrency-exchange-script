#!/bin/bash
# ============================================
# QuestDB Setup Script
# Required for: High-performance mark price queries (Margin/Futures)
# ============================================

set -e
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
mkdir -p /etc/needrestart/conf.d 2>/dev/null
printf '\$nrconf{restart} = '"'"'a'"'"';\n\$nrconf{kernelhints} = 0;\n' > /etc/needrestart/conf.d/99-codono.conf 2>/dev/null || true

echo "=========================================="
echo "  QUESTDB SETUP (Time-Series Database)   "
echo "  Required for: Fast price queries       "
echo "=========================================="

# QuestDB version
# NOTE: Using -rt- (runtime) package which bundles its own Java — no external Java needed
QUESTDB_VERSION="7.4.0"
QUESTDB_DIR="questdb-${QUESTDB_VERSION}-rt-linux-amd64"
QUESTDB_BASE="/opt/questdb"
QUESTDB_DATA="${QUESTDB_BASE}/data"

# Stop existing QuestDB service if running (for re-runs)
sudo systemctl stop questdb 2>/dev/null || true

# Create QuestDB directory
echo "Creating QuestDB installation directory..."
sudo mkdir -p "${QUESTDB_BASE}"
cd "${QUESTDB_BASE}"

# Check if QuestDB is already installed
if [ -f "${QUESTDB_BASE}/${QUESTDB_DIR}/bin/questdb.sh" ]; then
    echo "QuestDB $QUESTDB_VERSION already installed."
else
    echo "Downloading QuestDB $QUESTDB_VERSION..."
    wget "https://github.com/questdb/questdb/releases/download/$QUESTDB_VERSION/questdb-$QUESTDB_VERSION-rt-linux-amd64.tar.gz"

    echo "Extracting QuestDB..."
    tar -xzf "questdb-$QUESTDB_VERSION-rt-linux-amd64.tar.gz"
    rm "questdb-$QUESTDB_VERSION-rt-linux-amd64.tar.gz"
fi

# Create all data subdirectories QuestDB needs
echo "Creating data directories..."
sudo mkdir -p "${QUESTDB_DATA}/conf"
sudo mkdir -p "${QUESTDB_DATA}/db"
sudo mkdir -p "${QUESTDB_DATA}/log"
sudo mkdir -p "${QUESTDB_DATA}/import"
sudo mkdir -p "${QUESTDB_DATA}/public"

# Create QuestDB configuration
echo "Creating QuestDB configuration..."
cat > "${QUESTDB_DATA}/conf/server.conf" << 'EOF'
# QuestDB Server Configuration

# HTTP server settings (localhost only — not exposed externally)
http.bind.to=127.0.0.1:9000
http.enabled=true

# PostgreSQL wire protocol settings (localhost only)
pg.enabled=true
pg.bind.to=127.0.0.1:8812
pg.user=admin
pg.password=quest

# InfluxDB line protocol settings (localhost only)
line.tcp.enabled=true
line.tcp.bind.to=127.0.0.1:9009

# Performance settings
cairo.sql.copy.root=/opt/questdb/data/import
shared.worker.count=2
cairo.writer.command.queue.capacity=64
EOF

# Set permissions AFTER all files/directories are created
# This ensures www-data owns everything including conf/server.conf
echo "Setting permissions..."
sudo chown -R www-data:www-data "${QUESTDB_BASE}"

# Create systemd service
echo "Creating systemd service..."
cat > /etc/systemd/system/questdb.service << SERVICEEOF
[Unit]
Description=QuestDB Time-Series Database
After=network.target

[Service]
Type=forking
User=www-data
Group=www-data
WorkingDirectory=${QUESTDB_BASE}/${QUESTDB_DIR}
ExecStart=${QUESTDB_BASE}/${QUESTDB_DIR}/bin/questdb.sh start -d ${QUESTDB_DATA}
ExecStop=${QUESTDB_BASE}/${QUESTDB_DIR}/bin/questdb.sh stop -d ${QUESTDB_DATA}
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICEEOF

# Reload systemd
sudo systemctl daemon-reload

# Enable and start QuestDB
echo "Starting QuestDB..."
sudo systemctl enable questdb
sudo systemctl start questdb

# Wait for QuestDB to start
echo "Waiting for QuestDB to initialize..."
sleep 10

# Check if QuestDB is running (retry up to 3 times)
RETRIES=3
RUNNING=false
for i in $(seq 1 $RETRIES); do
    if curl -s "http://localhost:9000/exec?query=SELECT%201" > /dev/null 2>&1; then
        echo "QuestDB is running!"
        RUNNING=true
        break
    else
        echo "Waiting for QuestDB to fully start... (attempt $i/$RETRIES)"
        sleep 10
    fi
done

if [ "$RUNNING" = false ]; then
    echo ""
    echo "WARNING: QuestDB may not have started correctly."
    echo "Check logs with: sudo journalctl -u questdb -n 50"
    echo "Check status with: sudo systemctl status questdb"
    echo ""
    # Don't exit — continue to show info, user can debug
fi

if [ "$RUNNING" = true ]; then
    # Create mark_prices table
    echo "Creating mark_prices table..."
    curl -G --data-urlencode "query=CREATE TABLE IF NOT EXISTS mark_prices (
        symbol SYMBOL,
        mark_price DOUBLE,
        index_price DOUBLE,
        source STRING,
        timestamp TIMESTAMP
    ) TIMESTAMP(timestamp) PARTITION BY DAY;" \
    "http://localhost:9000/exec" 2>/dev/null

    # Create forex_ticks table (for forex trading module)
    echo "Creating forex_ticks table..."
    curl -G --data-urlencode "query=CREATE TABLE IF NOT EXISTS forex_ticks (
        symbol SYMBOL,
        bid DOUBLE,
        ask DOUBLE,
        source STRING,
        timestamp TIMESTAMP
    ) TIMESTAMP(timestamp) PARTITION BY DAY;" \
    "http://localhost:9000/exec" 2>/dev/null

    # Verify tables created
    echo ""
    echo "Verifying tables..."
    curl -s "http://localhost:9000/exec?query=SHOW%20TABLES"
else
    echo "Skipping table creation — QuestDB is not running."
    echo "After fixing the issue, create tables manually:"
    echo "  sudo systemctl start questdb && sleep 10"
    echo "  curl -G --data-urlencode \"query=CREATE TABLE IF NOT EXISTS mark_prices (symbol SYMBOL, mark_price DOUBLE, index_price DOUBLE, source STRING, timestamp TIMESTAMP) TIMESTAMP(timestamp) PARTITION BY DAY;\" http://localhost:9000/exec"
    echo "  curl -G --data-urlencode \"query=CREATE TABLE IF NOT EXISTS forex_ticks (symbol SYMBOL, bid DOUBLE, ask DOUBLE, source STRING, timestamp TIMESTAMP) TIMESTAMP(timestamp) PARTITION BY DAY;\" http://localhost:9000/exec"
fi

# Get server status
echo ""
echo "=========================================="
echo "  QuestDB Setup Complete!                "
echo "=========================================="
echo ""
echo "Service Details (all bound to localhost only):"
echo "  - HTTP API: http://127.0.0.1:9000"
echo "  - Web Console: http://127.0.0.1:9000 (SSH tunnel required for remote access)"
echo "  - PostgreSQL: 127.0.0.1:8812"
echo "  - InfluxDB Line: 127.0.0.1:9009"
echo ""
echo "Credentials (PostgreSQL):"
echo "  - User: admin"
echo "  - Password: quest"
echo ""
echo "Tables Created:"
echo "  - mark_prices (for crypto prices)"
echo "  - forex_ticks (for forex prices)"
echo ""
echo "Useful Commands:"
echo "  sudo systemctl status questdb  - Check status"
echo "  sudo systemctl restart questdb - Restart"
echo "  sudo journalctl -u questdb -f  - View logs"
echo ""
echo "Test Query:"
echo "  curl 'http://localhost:9000/exec?query=SELECT%20*%20FROM%20mark_prices%20LIMIT%205'"
echo ""

echo "NOTE: All ports are bound to 127.0.0.1 (not accessible externally)."
echo "To access the web console remotely, use SSH tunnel:"
echo "  ssh -L 9000:127.0.0.1:9000 user@your-server"
echo ""
