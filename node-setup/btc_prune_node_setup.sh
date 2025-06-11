#!/bin/bash

# Function to generate random strings
generate_random_string() {
    local length=$1
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$length"
    echo
}

# Function to generate a random port between 30000 and 39999
generate_random_port() {
    shuf -i 30000-39999 -n 1
}

# Welcome message
echo "Welcome to Codono Bitcoin Prune Node Setup!"
echo "This script will guide you through setting up a Bitcoin node with pruning enabled."

read -p "Do you want to continue with the setup wizard? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup aborted."
    exit 1
fi

# Load or generate RPC credentials
RPC_FILE="/opt/btc_rpc.yml"
if [ -f "$RPC_FILE" ]; then
    echo "Loading existing RPC information..."
    RPCUser=$(grep 'rpcuser:' "$RPC_FILE" | cut -d' ' -f2)
    RPCPass=$(grep 'rpcpassword:' "$RPC_FILE" | cut -d' ' -f2)
    RPCPort=$(grep 'rpcport:' "$RPC_FILE" | cut -d' ' -f2)
    ACCESS_IP=$(grep 'access_ip:' "$RPC_FILE" | cut -d' ' -f2)
else
    echo "Generating new RPC credentials..."
    RPCUser=$(generate_random_string 16)
    RPCPass=$(generate_random_string 32)
    RPCPort=$(generate_random_port)
    read -p "Enter the ACCESS_IP (default 0.0.0.0): " ACCESS_IP
    ACCESS_IP=${ACCESS_IP:-0.0.0.0}

    mkdir -p /opt
    cat <<EOF > "$RPC_FILE"
rpcuser: $RPCUser
rpcpassword: $RPCPass
rpcport: $RPCPort
access_ip: $ACCESS_IP
EOF
fi

# Install dependencies
if ! command -v screen &> /dev/null; then
    echo "Installing screen..."
    sudo apt-get update
    sudo apt-get install screen -y
fi

if ! command -v bitcoind &> /dev/null; then
    echo "Installing Bitcoin Core..."
    cd /opt/
    wget https://bitcoin.org/bin/bitcoin-core-22.0/bitcoin-22.0-x86_64-linux-gnu.tar.gz
    tar -xvf bitcoin-22.0-x86_64-linux-gnu.tar.gz
    sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-22.0/bin/*
fi

# Start temporary bitcoind to create wallet
echo "Starting temporary bitcoind to create 'default' wallet..."
bitcoind -daemon -conf=/dev/null -rpcuser=$RPCUser -rpcpassword=$RPCPass -rpcport=$RPCPort -server=1 -datadir=/root/.bitcoin

# Wait for bitcoind to respond
TRIES=0
echo "Waiting for bitcoind to become ready..."
until bitcoin-cli -rpcuser=$RPCUser -rpcpassword=$RPCPass -rpcport=$RPCPort getblockchaininfo > /dev/null 2>&1 || [ $TRIES -ge 20 ]; do
    sleep 3
    echo "Attempt $((TRIES + 1))..."
    TRIES=$((TRIES+1))
done

if [ $TRIES -ge 20 ]; then
    echo "bitcoind did not start successfully. Check logs."
    exit 1
fi

# Create the default wallet if it doesn't exist
if ! bitcoin-cli -rpcuser=$RPCUser -rpcpassword=$RPCPass -rpcport=$RPCPort listwallets | grep -q "default"; then
    echo "Creating 'default' wallet..."
    bitcoin-cli -rpcuser=$RPCUser -rpcpassword=$RPCPass -rpcport=$RPCPort createwallet "default"
else
    echo "'default' wallet already exists."
fi

# Stop temporary bitcoind to reconfigure with prune mode
echo "Stopping temporary bitcoind..."
bitcoin-cli -rpcuser=$RPCUser -rpcpassword=$RPCPass -rpcport=$RPCPort stop
sleep 10

# Create bitcoin.conf with default wallet auto-loaded
echo "Creating bitcoin.conf..."
mkdir -p /root/.bitcoin
cat <<EOF > /root/.bitcoin/bitcoin.conf
rpcuser=$RPCUser
rpcpassword=$RPCPass
rpcport=$RPCPort
rpctimeout=5
rpcallowip=$ACCESS_IP
rpcbind=0.0.0.0
testnet=0
server=1
prune=550
addresstype=p2sh-segwit
wallet=default
EOF

# Start bitcoind in screen session
echo "Starting bitcoind in screen session with pruning and 'default' wallet..."
screen -S bitcoin_node -d -m bitcoind -conf=/root/.bitcoin/bitcoin.conf

# Setup Supervisor if needed
if [ ! -f /etc/supervisor/conf.d/bitcoin.conf ]; then
    echo "Installing Supervisor..."
    sudo apt-get update
    sudo apt-get install supervisor -y

    cat <<EOF > /etc/supervisor/conf.d/bitcoin.conf
[program:bitcoin]
command=/usr/local/bin/bitcoind -datadir=/root/.bitcoin -conf=/root/.bitcoin/bitcoin.conf
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/bitcoin.err.log
stdout_logfile=/var/log/supervisor/bitcoin.out.log
EOF

    echo "Reloading Supervisor..."
    supervisorctl reload
fi

echo
echo "✅ Bitcoin node setup complete!"
echo "👉 You can reattach to the screen session with: screen -r bitcoin_node"
echo "🔐 Credentials saved at /opt/btc_rpc.yml — keep it safe and delete when done."
