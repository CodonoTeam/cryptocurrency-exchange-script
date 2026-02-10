#!/bin/bash

# ============================================
# Codono Exchange - Show Admin Login Info
# Displays admin URL, credentials, and 2FA QR code
# ============================================

# Define the path to the credentials file
CREDENTIALS_FILE="/opt/credentials.yml"

# Check if qrencode is installed and install it if it's not
if ! command -v qrencode &> /dev/null; then
    echo "'qrencode' is not installed. Attempting to install..."
    sudo apt-get update && sudo apt-get install -y qrencode
    if [ $? -ne 0 ]; then
        echo "Failed to install 'qrencode'. Please install it manually."
        exit 1
    fi
fi

# Read values from the credentials file
TWO_FA_SECRET_KEY=$(awk '/TWO_FA_SECRET_KEY:/ {print $2}' "$CREDENTIALS_FILE")
DOMAIN=$(awk '/^DOMAIN:/ {print $2}' "$CREDENTIALS_FILE")
ADMIN_KEY=$(awk '/ADMIN_KEY:/ {print $2}' "$CREDENTIALS_FILE")
ADMIN_USER=$(awk '/ADMIN_USER:/ {print $2}' "$CREDENTIALS_FILE")
ADMIN_PASS=$(awk '/ADMIN_PASS:/ {print $2}' "$CREDENTIALS_FILE")

# Check if necessary values were found
if [ -z "$TWO_FA_SECRET_KEY" ] || [ -z "$DOMAIN" ] || [ -z "$ADMIN_KEY" ] || [ -z "$ADMIN_USER" ] || [ -z "$ADMIN_PASS" ]; then
    echo "Required information is missing from credentials file."
    exit 1
fi

# Generate QR code for 2FA secret
echo "Generating QR code for the 2FA secret key..."
qrencode -t UTF8 "otpauth://totp/${DOMAIN}:Admin?secret=${TWO_FA_SECRET_KEY}&issuer=${DOMAIN}"

# Print Admin login URL and credentials
echo "Admin Login URL: https://${DOMAIN}/Admin/Login/index/securecode/${ADMIN_KEY}"
echo "Admin User: $ADMIN_USER"
echo "Admin Password: $ADMIN_PASS"

# Instruction for scanning the QR code
echo "Scan the above QR code using Authy or another 2FA app to add ${DOMAIN} Admin 2FA."
