#!/bin/bash
# Define the path to the credentials file for codono
CREDENTIALS_FILE="/opt/credentials.yml"

# Check if credentials file exists
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Credentials file does not exist: $CREDENTIALS_FILE"
    exit 1
fi

# Extract the DOMAIN value from the credentials file
DOMAIN=$(awk '/DOMAIN:/ {print $2}' "$CREDENTIALS_FILE")
PHP_PATH='/usr/local/php/bin/php';
CRON_KEY=$(grep 'CRON_KEY:' /opt/credentials.yml | cut -d ' ' -f 2)

# Check if DOMAIN was found
if [ -z "$DOMAIN" ]; then
    echo "DOMAIN not found in the credentials file."
    exit 1
fi

# Define groups of cron jobs
declare -A CRON_JOB_GROUPS
CRON_JOB_GROUPS[1]="0" # BTC Deposit
CRON_JOB_GROUPS[2]="1" # CryptoApis Deposit
CRON_JOB_GROUPS[3]="2" # Substrate Deposit
CRON_JOB_GROUPS[4]="3 4" # Blockgum Deposit and Withdrawal ID
CRON_JOB_GROUPS[5]="5 6" # Cryptonote
CRON_JOB_GROUPS[6]="11 12" # Coinpayments

# Define the user interface
echo "We will add some mandatory crons automatically for Emails, Charts, Tron, etc."
echo "Select cron jobs to enable: "
echo "1) BTC Deposit"
echo "2) CryptoApis Deposit"
echo "3) Substrate"
echo "4) Blockgum"
echo "5) Cryptonote"
echo "6) Coinpayments"

read -p "Enter numbers separated by spaces (e.g., 1 2 3): " selection

# Define the original path
INDEX_PATH="/data/wwwroot/${DOMAIN}"

# Define the cron jobs
CRON_JOBS=(
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/deposit_btctype/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/deposit_cryptoapis/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/substrate_deposit/securecode/${CRON_KEY}/ > /dev/null"
"*/5 * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/getWithdrawalIdSubstrate/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/blockgum_deposit/securecode/${CRON_KEY}/ > /dev/null"
"*/5 * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/getWithdrawalIdBlockgum/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/wallet_cryptonote_deposit/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/wallet_cryptonote2_deposit/securecode/${CRON_KEY}/ > /dev/null"
"*/5 * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/wallet_blockio_deposit/securecode/${CRON_KEY}/ > /dev/null"
"*/5 * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/wallet_blockio_withdraw/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/esmart_deposit/securecode/${CRON_KEY}/chain/chainNameHere > /dev/null"
"*/5 * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/wallet_coinpay_deposit/securecode/${CRON_KEY}/ > /dev/null"
"*/5 * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Coin/wallet_coinpay_withdraw/securecode/${CRON_KEY}/ > /dev/null"
)

# Mandatory cron jobs (always added)
MANDATORY_CRON_JOBS=(
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Tron/cronDeposits/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Xtrade/cronMe/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Xtrade/otcTrade/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Selfengine/CreateOrderbook/securecode/${CRON_KEY}/ > /dev/null"
"0 9 * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Selfengine/cleanUp/securecode/${CRON_KEY}/ > /dev/null"
"0 9 * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Queue/checkStaking/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Queue/BinanceUpdate/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Queue/ExchangeBinanceUpdate/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Queue/cmcUpdate/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Queue/cmcUpdateRate/securecode/${CRON_KEY}/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Queue/send_notifications/securecode/${CRON_KEY}/ > /dev/null"
"*/10 * * * * cd ${INDEX_PATH} && ${PHP_PATH} index.php Queue/genInternalCharts/securecode/${CRON_KEY}/ > /dev/null"
)

# Start with mandatory cron jobs
CRON_JOBS_TO_ADD=("${MANDATORY_CRON_JOBS[@]}") 

VALID_SELECTION=0
for i in $selection; do
    if ! [[ "$i" =~ ^[1-6]+$ ]]; then
        echo "Invalid selection: $i. Please enter valid numbers (e.g., 1 2 3)."
        exit 1
    fi

    # Get the corresponding group of cron jobs for the selection
    if [[ -n ${CRON_JOB_GROUPS[$i]} ]]; then
        for index in ${CRON_JOB_GROUPS[$i]}; do
            CRON_JOBS_TO_ADD+=("${CRON_JOBS[$index]}")
            VALID_SELECTION=1
        done
    else
        echo "Selection $i is out of range."
        exit 1
    fi
done

if [ "$VALID_SELECTION" -eq 0 ]; then
    echo "No valid selections made."
    exit 1
fi

# Backup current crontab
crontab -u www -l > mycron.backup 2>/dev/null

CRON_TMP_FILE=$(mktemp)
echo "Temporary file created at: $CRON_TMP_FILE"

# Populate the temp file with existing crons excluding old installations
crontab -u www -l 2>/dev/null | grep -v "${INDEX_PATH}" > "$CRON_TMP_FILE"

# Add new cron jobs to the temporary file
for job in "${CRON_JOBS_TO_ADD[@]}"; do
    echo "$job" >> "$CRON_TMP_FILE"
done

# Install the new cron jobs
crontab -u www "$CRON_TMP_FILE"
rm "$CRON_TMP_FILE"

# Reload the cron service to apply changes
if command -v systemctl &> /dev/null; then
    echo "Reloading cron service using systemctl..."
    systemctl reload cron
elif command -v service &> /dev/null; then
    echo "Reloading cron service using service command..."
    service cron reload
else
    echo "Cron service will automatically detect the changes. No manual reload required."
fi

echo "Cron jobs have been updated and reloaded. You can always check crons using the command: crontab -l -u www"
