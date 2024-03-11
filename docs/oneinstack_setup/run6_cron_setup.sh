#!/bin/bash
# Define the path to the credentials file for codono
CREDENTIALS_FILE="/opt/credentials.yml"

# Check if credentials file exists
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Credentials file does not exist: $CREDENTIALS_FILE"
    exit 1
fi

# Extract the DOMAIN value from the credentials file
DOMAIN=$(awk '/DOMAIN:/ {print $2}' $CREDENTIALS_FILE)

# Check if DOMAIN was found
if [ -z "$DOMAIN" ]; then
    echo "DOMAIN not found in credentials file."
    exit 1
fi

# Define groups of cron jobs
declare -A CRON_JOB_GROUPS
CRON_JOB_GROUPS[1]="0" # BTC Deposit
CRON_JOB_GROUPS[2]="1" # CryptoApis Deposit
CRON_JOB_GROUPS[3]="2" # Substrate Deposit
CRON_JOB_GROUPS[4]="4 5" # Blockgum Deposit and Withdrawal ID
CRON_JOB_GROUPS[5]="6" # Cryptonote
CRON_JOB_GROUPS[6]="11 12" # Cryptonote
# Define the user interface
echo "We will some mandatory crons automatically for Emails, Charts, Tron etc"
echo "Select cron jobs to enable: "
echo "1) BTC Deposit"
echo "2) CryptoApis Deposit"
echo "3) Substrate"
echo "4) Blockgum"
echo "5) Cryptonote"
echo "6) Coinpayments"

read -p "Enter numbers separated by spaces (e.g., 1 2 3): " selection


# Define the original and new paths

INDEX_PATH="/data/wwwroot/${DOMAIN}"
# Define the cron jobs
CRON_JOBS=(
"* * * * * cd ${INDEX_PATH} && php index.php Coin/deposit_btctype/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Coin/deposit_cryptoapis/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Coin/substrate_deposit/securecode/cronkey/ > /dev/null"
"*/5 * * * * cd ${INDEX_PATH} && php index.php Coin/getWithdrawalIdSubstrate/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Coin/blockgum_deposit/securecode/cronkey/ > /dev/null"
"*/5 * * * * cd ${INDEX_PATH} && php index.php Coin/getWithdrawalIdBlockgum/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Coin/wallet_cryptonote_deposit/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Coin/wallet_cryptonote2_deposit/securecode/cronkey/ > /dev/null"
"*/5 * * * * cd ${INDEX_PATH} && php index.php Coin/wallet_blockio_deposit/securecode/cronkey/ > /dev/null"
"*/5 * * * * cd ${INDEX_PATH} && php index.php Coin/wallet_blockio_withdraw/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Coin/esmart_deposit/securecode/cronkey/chain/chainNameHere > /dev/null"
"*/5 * * * * cd ${INDEX_PATH} && php index.php Coin/wallet_coinpay_deposit/securecode/cronkey/ > /dev/null"
"*/5 * * * * cd ${INDEX_PATH} && php index.php Coin/wallet_coinpay_withdraw/securecode/cronkey/ > /dev/null"
)


# Mandatory cron jobs (always added)
MANDATORY_CRON_JOBS=(
"* * * * * cd ${INDEX_PATH} && php index.php Tron/cronDeposits/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Xtrade/cronMe/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Xtrade/otcTrade/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Selfengine/CreateOrderbook/securecode/cronkey/ > /dev/null"
"0 9 * * * cd ${INDEX_PATH} && php index.php Selfengine/cleanUp/securecode/cronkey/ > /dev/null"
"0 9 * * * cd ${INDEX_PATH} && php index.php Queue/checkStaking/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Queue/BinanceUpdate/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Queue/ExchangeBinanceUpdate/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Queue/cmcUpdate/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Queue/cmcUpdateRate/securecode/cronkey/ > /dev/null"
"* * * * * cd ${INDEX_PATH} && php index.php Queue/send_notifications/securecode/cronkey/ > /dev/null"
"*/10 * * * * cd ${INDEX_PATH} && php index.php Queue/genInternalCharts/securecode/cronkey/ > /dev/null"
)

# Parse user selection and prepare cron jobs to add
CRON_JOBS_TO_ADD=("${MANDATORY_CRON_JOBS[@]}") # Initialize with mandatory cron jobs
VALID_SELECTION=0
for i in $selection; do
    if ! [[ "$i" =~ ^[1-6]+$ ]]; then
        echo "Invalid selection: $i. Please enter valid numbers (e.g., 1 2 3 )."
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
crontab -u www -l > mycron.backup

CRON_TMP_FILE=$(mktemp)
echo "Temporary file created at: $CRON_TMP_FILE"

crontab -u www -l > "$CRON_TMP_FILE" || { echo "Failed to get crontab for user www"; exit 1; }
for job in "${CRON_JOBS_TO_ADD[@]}" "${MANDATORY_CRON_JOBS[@]}"; do
    echo "$job" >> "$CRON_TMP_FILE"
done
crontab -u www "$CRON_TMP_FILE"
rm "$CRON_TMP_FILE"

# Reload crontab
crontab -u www -l

echo "Cron jobs have been updated. You can always check crons using this command crontab -e -u www "

# Note: This script completes cron setup for you.
