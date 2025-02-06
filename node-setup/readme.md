# Codono Bitcoin Prune Node Setup Script

This script automates the setup of a Bitcoin prune node. It checks for existing configurations, installs necessary software, and sets up the node with resume protection using `screen`.

## Features
- **Resume-Supported**: Can be run multiple times without overwriting existing configurations.
- **RPC Configuration**: Generates and saves RPC credentials in `/opt/btc_rpc.yml`.
- **Screen Session**: Runs the Bitcoin node in a `screen` session for resume protection.
- **Supervisor Setup**: Configures `supervisor` to manage the Bitcoin node service.
- **Wallet Creation**: Creates a default wallet and an additional wallet named `my_wallet`.

## Instructions to Use the Script

### Prerequisites
- **Root Access**: This script requires root privileges to install software and configure system settings.
- **Internet Access**: The script downloads Bitcoin Core and other dependencies.

### Steps

1. **Save the Script**:
   - Download the script to your server. For example, save it as `setup_bitcoin_node.sh`.

2. **Make the Script Executable**:
   ```bash
   chmod +x setup_bitcoin_node.sh
  
Run the Script with Root Privileges:

```bash
sudo ./setup_bitcoin_node.sh
```
### What the Script Does
- **Welcome Message**: Provides an overview of what the script will do.
- **User Confirmation**: Asks for user confirmation before proceeding.
- **Check for Existing RPC Configuration**: Reuses existing RPC information from /opt/btc_rpc.yml if it exists.
- **Install Necessary Software**: Installs screen and Bitcoin Core if they are not already installed.
- **Configure Bitcoin Core**: Sets up bitcoin.conf with random RPC credentials and a specified port.
- **Start Bitcoin Node**: Runs the Bitcoin node in a screen session for resume protection.
- **Supervisor Configuration**: Sets up supervisor to manage the Bitcoin node service.
- **Wallet Creation**: Creates a default wallet and an additional wallet named my_wallet.
- **Connection Test**: Tests the connection to the Bitcoin node.**
### Notes
- **Existing Configurations**: The script checks for existing configurations and reuses them to avoid overwriting.
- **Screen Session**: The Bitcoin node runs in a screen session. You can resume the session with screen -r bitcoin_node.
- **Supervisor**: The script configures supervisor to manage the Bitcoin node service, ensuring it restarts automatically if it crashes.
- **Wallets**: The script creates a default wallet and an additional wallet named my_wallet if they do not already exist.
- **Resume-Supported**: The script is designed to be run multiple times without overwriting existing configurations or reinstalling software.
- **Review Script**: Always review and understand the script before running it, especially when running with root privileges.

### Troubleshooting
- **Screen Session**: If the script stops unexpectedly, you can resume the session with screen -r bitcoin_node.
- **Logs**: Check the supervisor logs for any issues:

```bash
supervisorctl tail -f bitcoin
```

### Connection Issues
Use the curl command provided in the script to test the connection to the Bitcoin node.

### Support
For any issues or further assistance, please contact **https://t.me/@ctoninja**
Thank you for using the Codono Bitcoin Prune Node Setup Script!
