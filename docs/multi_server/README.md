# Codono Multi-Server Setup Script README

## Overview
This script automates the configuration of a secure, high-availability multi-server environment with MariaDB master-slave replication, Memcached for session storage, and necessary security configurations. It creates a production-ready environment while addressing security, performance, and reliability concerns.

## Features
- Automated MariaDB master-slave replication setup
- Secure credentials management with strong password generation
- Memcached distributed session storage
- Redis configuration for memory caching
- PHP environment setup with required extensions
- Web server configuration with basic authentication
- Support for both single-server and multi-server deployments
- Comprehensive logging of the installation process

## Prerequisites
- Ubuntu/Debian-based operating system
- Root or sudo access
- Network connectivity between servers
- DNS resolution configured properly
- Open ports: 3306 (MariaDB), 11211 (Memcached), 6379 (Redis)

## Usage

### Initial Setup on Master Server
1. Download the script:
   ```bash
   wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/multi_server/multi-server-setup.sh
   chmod +x multi-server-setup.sh
   ```
2. Run the script:
   ```bash
   ./multi-server-setup.sh
   ```
3. Follow the prompts:
   - Enter your domain name
   - Choose "n" for multi-server setup
   - Enter the master server IP
   - Enter the slave server IP

### Setup on Slave Server
1. Copy the credentials.yml file from master to slave:
   ```bash
   scp /opt/credentials.yml user@slave_ip:/opt/
   ```
2. Download and run the script:
   ```bash
   wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/multi_server/multi-server-setup.sh
   chmod +x multi-server-setup.sh
   ./multi-server-setup.sh
   ```

## Architecture
- **Master Server**: Primary database server with write capabilities
- **Slave Server**: Secondary database server for read operations
- **Memcached**: Distributed session storage across both servers
- **Redis**: Local caching with password protection
- **Load Balancer**: Distributes traffic between servers (not included in script)

## Security Considerations
- All credentials are stored in credentials.yml
- Replication user has restricted access
- SSL is required for database replication
- Redis and Memcached are configured with authentication
- .htaccess protects web directories
- Credentials file has restricted permissions

## Maintenance
- Regularly update passwords in credentials.yml
- Monitor database replication status
- Check server health and resource usage
- Update software packages regularly

## Troubleshooting
- Verify network connectivity between servers
- Check MariaDB error logs
- Ensure firewall rules are correctly configured
- Validate credentials in credentials.yml

## Footer Note
This script was developed to simplify multi-server environment setup while maintaining security and performance standards.
