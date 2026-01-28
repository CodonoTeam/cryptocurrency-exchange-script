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
echo "Welcome to Codono Litecoin Prune Node Setup!"
echo "This script will guide you through setting up a Litecoin node with pruning enabled."
echo "It will:"
echo "  - Check for existing RPC configuration and reuse it if available."
echo "  - Install necessary software (screen, Litecoin Core) if not already installed."
echo "  - Configure Litecoin Core with a random RPC port and user credentials."
echo "  - Start the Litecoin node in a screen session for resume protection."
echo "  - Set up supervisor to manage the Litecoin node service."
echo "  - Create a default wallet and test the connection."

# Prompt user to continue
read -p "Do you want to continue with the setup wizard? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup aborted."
    exit 1
fi

# Check if ltc_rpc.yml exists and load existing RPC information
RPC_FILE="/opt/ltc_rpc.yml"
if [ -f "$RPC_FILE" ]; then
    echo "ltc_rpc.yml exists. Loading existing RPC information..."
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

    # Save RPC information to ltc_rpc.yml
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

# Check if Litecoin Core is installed, and install it if not
if ! command -v litecoind &> /dev/null; then
    echo "Litecoin Core is not installed. Installing Litecoin Core..."
    cd /opt/
    wget https://download.litecoin.org/litecoin-0.21.4/linux/litecoin-0.21.4-x86_64-linux-gnu.tar.gz
    tar -xvf litecoin-0.21.4-x86_64-linux-gnu.tar.gz
    sudo install -m 0755 -o root -g root -t /usr/local/bin litecoin-0.21.4/bin/*
else
    echo "Litecoin Core is already installed."
fi

# Create default wallet if it doesn't exist
if ! litecoin-cli listwallets | grep -q "default"; then
    echo "Creating default wallet..."
    litecoin-cli createwallet "default"
else
    echo "Default wallet already exists."
fi

# Create and configure litecoin.conf
echo "Configuring litecoin.conf..."
cd /root/.litecoin/
cat <<EOF > litecoin.conf
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

# Start litecoind in a screen session
echo "Starting litecoind in a screen session..."
screen -S litecoin_node -d -m litecoind -server -rpcbind=0.0.0.0 -rpcport=$RPCPort -rpcallowip=$ACCESS_IP -rpcuser=$RPCUser -rpcpassword=$RPCPass -prune=550 -addresstype=p2sh-segwit

# Install and configure supervisor if not already configured
if [ ! -f /etc/supervisor/conf.d/litecoin.conf ]; then
    echo "Installing and configuring supervisor..."
    sudo apt-get update
    sudo apt-get install supervisor -y

    cd /etc/supervisor/conf.d/
    cat <<EOF > litecoin.conf
[program:litecoin]
command=/usr/local/bin/litecoind -datadir=/root/.litecoin -conf=/root/.litecoin/litecoin.conf
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/litecoin.err.log
stdout_logfile=/var/log/supervisor/litecoin.out.log
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
if ! litecoin-cli listwallets | grep -q "my_wallet"; then
    echo "Creating a wallet..."
    litecoin-cli createwallet "my_wallet"
else
    echo "Wallet 'my_wallet' already exists."
fi

# Check if wallet is connected
echo "Checking wallet connection..."
litecoin-cli getwalletinfo

echo "Litecoin node setup complete! You can resume the screen session with 'screen -r litecoin_node'. Credentials are stored in /opt/ltc_rpc.yml. Save them somewhere safe and delete the file if necessary."
