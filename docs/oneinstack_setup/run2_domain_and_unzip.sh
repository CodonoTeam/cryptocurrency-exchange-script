#!/bin/bash

# Immediately exit if any command has a non-zero exit status
set -e

# Verify /opt/credentials.yml exists
if [ ! -f "/opt/credentials.yml" ]; then
    echo "/opt/credentials.yml does not exist."
    exit 1
else
    # Extract the DOMAIN value from /opt/credentials.yml
    domain=$(grep 'DOMAIN:' /opt/credentials.yml | cut -d ' ' -f 2)
    if [ -z "$domain" ]; then
        echo "DOMAIN value not found in /opt/credentials.yml."
        exit 1
    fi
fi


# Verify /data/wwwroot/codono_unpack.zip exists
if [ ! -f "/data/wwwroot/codono_unpack.zip" ]; then
    echo "/data/wwwroot/codono_unpack.zip does not exist."
    exit 1
fi

# Check if unzip is available, if not then install
if ! command -v unzip &> /dev/null; then
    echo "unzip is not installed. Installing..."
    sudo apt-get update && sudo apt-get install unzip -y
fi

# Unzip codono_unpack.zip
echo "Unzipping /data/wwwroot/codono_unpack.zip..."
unzip /data/wwwroot/codono_unpack.zip -d /data/wwwroot/ || { echo "Failed to unzip file."; exit 1; }

# Add the domain to /opt/oneinstack/vhost.sh script [ run in subshell]
echo "Adding domain to vhost.sh..."
command_output=$( 
    /opt/oneinstack/vhost.sh --add <<EOF
1
$domain

n
n
y
y
EOF
) 
command_status=$?

# Print the output for debugging or confirmation
echo "$command_output"

# Check if the previous command was successful
if [ $command_status -ne 0 ]; then
    echo "Failed to add domain to vhosts.sh."
    exit 1
else
    echo "The virtual host for $domain has been configured."
fi
