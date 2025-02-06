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
echo "It will:"
echo "  - Check for existing RPC configuration and reuse it if available."
echo "  - Install necessary software (screen, Bitcoin Core) if not already installed."
echo "  - Configure Bitcoin Core with a random RPC port and user credentials."
echo "  - Start the Bitcoin node in a screen session for resume protection."
echo "  - Set up supervisor to manage the Bitcoin node service."
echo "  - Create a default wallet and test the connection."

# Prompt user to continue
read -p "Do you want to continue with the setup wizard? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup aborted."
    exit 1
fi

# Check if btc_rpc.yml exists and load existing RPC information
RPC_FILE="/opt/btc_rpc.yml"
if [ -f "$RPC_FILE" ]; then
    echo "btc_rpc.yml exists. Loading existing RPC information..."
    RPCUser=$(grep 'rpcuser:' "$RPC_FILE" | cut -d' ' -f2)
    RPCPass=$(grep 'rpcpassword:' "$RPC_FILE" | cut -d' ' -f2)
    RPCPort=$(grep 'rpcport:' "$RPC_FILE" | cut -d' ' -f2)
    ACCESS_IP=$(grep 'access_ip:' "$RPC_FILE" | cut -d' ' -f2)
else
    # Gather Information
    echo "Generating RPC credentials and port..."
    RPCUser=$(generate_random_string 16)
    RPCPass=$(generate_random_string 32)
    RPCPort=$(generate_random_port)

    # Ask user for ACCESS_IP
    read -p "Enter the ACCESS_IP (or press Enter to use 0.0.0.0): " ACCESS_IP
    ACCESS_IP=${ACCESS_IP:-0.0.0.0}

    echo "RPC User: $RPCUser"
    echo "RPC Password: $RPCPass"
    echo "RPC Port: $RPCPort"
    echo "Access IP: $ACCESS_IP"

    # Save RPC information to btc_rpc.yml
    mkdir -p /opt
    cat <<EOF > "$RPC_FILE"
rpcuser: $RPCUser
rpcpassword: $RPCPass
rpcport: $RPCPort
access_ip: $ACCESS_IP
EOF
fi

# Check if screen is installed, and install it if not
if ! command -v screen &> /dev/null; then
    echo "Screen is not installed. Installing screen..."
    sudo apt-get update
    sudo apt-get install screen -y
else
    echo "Screen is already installed."
fi

# Check if Bitcoin Core is installed, and install it if not
if ! command -v bitcoind &> /dev/null; then
    echo "Bitcoin Core is not installed. Installing Bitcoin Core..."
    cd /opt/
    wget https://bitcoin.org/bin/bitcoin-core-22.0/bitcoin-22.0-x86_64-linux-gnu.tar.gz
    tar -xvf bitcoin-22.0-x86_64-linux-gnu.tar.gz
    sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-22.0/bin/*
else
    echo "Bitcoin Core is already installed."
fi

# Create default wallet if it doesn't exist
if ! bitcoin-cli listwallets | grep -q "default"; then
    echo "Creating default wallet..."
    bitcoin-cli createwallet "default"
else
    echo "Default wallet already exists."
fi

# Create and configure bitcoin.conf
echo "Configuring bitcoin.conf..."
cd /root/.bitcoin/
cat <<EOF > bitcoin.conf
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
#daemon=1
EOF

# Start bitcoind in a screen session
echo "Starting bitcoind in a screen session..."
screen -S bitcoin_node -d -m bitcoind -server -rpcbind=0.0.0.0 -rpcport=$RPCPort -rpcallowip=$ACCESS_IP -rpcuser=$RPCUser -rpcpassword=$RPCPass -prune=550 -addresstype=p2sh-segwit

# Install and configure supervisor if not already configured
if [ ! -f /etc/supervisor/conf.d/bitcoin.conf ]; then
    echo "Installing and configuring supervisor..."
    sudo apt-get update
    sudo apt-get install supervisor -y

    cd /etc/supervisor/conf.d/
    cat <<EOF > bitcoin.conf
[program:bitcoin]
command=/usr/local/bin/bitcoind -datadir=/root/.bitcoin -conf=/root/.bitcoin/bitcoin.conf
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/bitcoin.err.log
stdout_logfile=/var/log/supervisor/bitcoin.out.log
EOF

    # Reload supervisor
    echo "Reloading supervisor..."
    supervisorctl reload
else
    echo "Supervisor configuration already exists."
fi

# Testing Connection
echo "Testing connection..."
curl --data-binary '{"jsonrpc":"1.0","id":"curltext","method":"getblockchaininfo","params":[]}' -H 'content-type:text/plain;' http://$RPCUser:$RPCPass@127.0.0.1:$RPCPort/

# Creating a wallet if it doesn't exist
if ! bitcoin-cli listwallets | grep -q "my_wallet"; then
    echo "Creating a wallet..."
    bitcoin-cli createwallet "my_wallet"
else
    echo "Wallet 'my_wallet' already exists."
fi

# Check if wallet is connected
echo "Checking wallet connection..."
bitcoin-cli getwalletinfo

echo "Bitcoin node setup complete! You can resume the screen session with 'screen -r bitcoin_node'. also credentials are stored in /opt/btc_rpc.yml save them some where safe and delete the file."
