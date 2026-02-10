#!/bin/bash
# ============================================
# QuestDB Setup Script
# Required for: High-performance mark price queries (Margin/Futures)
# ============================================

set -e
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

echo "=========================================="
echo "  QUESTDB SETUP (Time-Series Database)   "
echo "  Required for: Fast price queries       "
echo "=========================================="

# QuestDB version
QUESTDB_VERSION="7.4.0"

# Check if Java is installed (QuestDB requires Java 11+)
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
    echo "Java already installed: $JAVA_VERSION"
else
    echo "Installing OpenJDK 17..."
    sudo apt-get update
    sudo apt-get install -y openjdk-17-jre-headless
fi

# Create QuestDB directory
echo "Creating QuestDB installation directory..."
sudo mkdir -p /opt/questdb
cd /opt/questdb

# Check if QuestDB is already installed
if [ -f "/opt/questdb/questdb-$QUESTDB_VERSION-rt-linux-amd64/bin/questdb.sh" ]; then
    echo "QuestDB $QUESTDB_VERSION already installed."
else
    echo "Downloading QuestDB $QUESTDB_VERSION..."
    wget -q "https://github.com/questdb/questdb/releases/download/$QUESTDB_VERSION/questdb-$QUESTDB_VERSION-rt-linux-amd64.tar.gz"

    echo "Extracting QuestDB..."
    tar -xzf "questdb-$QUESTDB_VERSION-rt-linux-amd64.tar.gz"
    rm "questdb-$QUESTDB_VERSION-rt-linux-amd64.tar.gz"
fi

# Create data directory
sudo mkdir -p /opt/questdb/data

# Set permissions (www-data instead of www)
sudo chown -R www-data:www-data /opt/questdb

# Create QuestDB configuration
echo "Creating QuestDB configuration..."
mkdir -p /opt/questdb/data/conf
cat > /opt/questdb/data/conf/server.conf << 'EOF'
# QuestDB Server Configuration

# HTTP server settings
http.bind.to=0.0.0.0:9000
http.enabled=true

# PostgreSQL wire protocol settings
pg.enabled=true
pg.bind.to=0.0.0.0:8812
pg.user=admin
pg.password=quest

# InfluxDB line protocol settings
line.tcp.enabled=true
line.tcp.bind.to=0.0.0.0:9009

# Performance settings
cairo.sql.copy.root=/opt/questdb/data/import
shared.worker.count=2
cairo.writer.command.queue.capacity=64
EOF

# Create systemd service (www-data instead of www)
echo "Creating systemd service..."
sudo cat > /etc/systemd/system/questdb.service << EOF
[Unit]
Description=QuestDB Time-Series Database
After=network.target

[Service]
Type=forking
User=www-data
Group=www-data
WorkingDirectory=/opt/questdb/questdb-$QUESTDB_VERSION-rt-linux-amd64
ExecStart=/opt/questdb/questdb-$QUESTDB_VERSION-rt-linux-amd64/bin/questdb.sh start -d /opt/questdb/data
ExecStop=/opt/questdb/questdb-$QUESTDB_VERSION-rt-linux-amd64/bin/questdb.sh stop
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable and start QuestDB
echo "Starting QuestDB..."
sudo systemctl enable questdb
sudo systemctl start questdb

# Wait for QuestDB to start
echo "Waiting for QuestDB to initialize..."
sleep 10

# Check if QuestDB is running
if curl -s "http://localhost:9000/exec?query=SELECT%201" > /dev/null 2>&1; then
    echo "QuestDB is running!"
else
    echo "Waiting for QuestDB to fully start..."
    sleep 10
fi

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
curl -s "http://localhost:9000/exec?query=SHOW%20TABLES" | head -20

# Get server status
echo ""
echo "=========================================="
echo "  QuestDB Setup Complete!                "
echo "=========================================="
echo ""
echo "Service Details:"
echo "  - HTTP API: http://localhost:9000"
echo "  - Web Console: http://YOUR_IP:9000"
echo "  - PostgreSQL: localhost:8812"
echo "  - InfluxDB Line: localhost:9009"
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

# Security note
echo "SECURITY NOTE:"
echo "  For production, restrict access to ports 9000 and 8812"
echo "  using firewall rules (only allow from localhost/internal IPs)"
echo ""
