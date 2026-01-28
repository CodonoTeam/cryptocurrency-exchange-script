# Blockgum Withdrawal Processing Guide for Codono

This guide outlines the steps required to process withdrawals using Blockgum in the Codono cryptocurrency exchange platform. Follow these steps to ensure a smooth withdrawal process for BNB, ETH, and similar coins.

## Step 1: Configuration Check

- **Cross Check**: First, ensure that Blockgum is configured correctly in the **Admin/options** area of Codono.
- **Coin Configuration**: Navigate to **Admin/Config/coin** and check that coins like BNB and ETH have their main address configured correctly.
- **Connect mobile app**: Check if mobile app can connect with blockgum node or not. If not then Blockgum node may be down or need license update due to expiry.

## Step 2: Verify Main Address Balance

1. **Note Main Address**: Write down or copy the main address for the coin you are interested in.
2. **Explorer Check**: Use the respective blockchain explorer (e.g., [Etherscan](https://etherscan.io) for ETH, [BscScan](https://bscscan.com) for BNB) to verify that the main address has sufficient balance for the withdrawal. 
3. **Gas Funds**: Ensure that the main address also has enough balance to cover the gas fees for the transaction.

## Step 3: Balance Top-Up (If Required)

- If the main address does not have enough balance, navigate to the URL structured as follows to transfer tokens to the main address:

**Move Tokens  like usdt to main address***
```
http://exchange.local/Coin/blockgum_token_to_main/securecode/cronkey/coinname/tokenNameHere

```

- **URL Replacement**: Replace `exchange.local` with your exchange's URL and `tokenNameHere` with the specific token's name you're processing.
- **Process Execution**: Follow the on-screen instructions to complete the token transfer.

**Move Main coins like eth/bnb to main address***
```
http://exchange.local/Coin/blockgum_coin_to_main/securecode/cronkey/coinname/coinNameHere

```

- **URL Replacement**: Replace `exchange.local` with your exchange's URL and `coinNameHere` with the specific coin's name you're processing , like eth , bnb .
- **Process Execution**: Follow the on-screen instructions to complete the token transfer.


## Step 4: Reconfirmation

- **Block Explorer Check**: After completing the top-up process (either through the provided URL or by sending funds externally), recheck the main address on the appropriate block explorer to confirm the updated balance.

## Step 5: Processing Withdrawals

1. **Crypto Withdrawal Page**: Navigate to the Crypto withdrawal page in the Codono admin panel.
2. **Initiate Payment**: Click on the `pay now` button next to the withdrawal request you wish to process.
3. **Transaction ID**: Wait for up to 2 minutes for the transaction ID to appear in the admin panel. This ID is essential for tracking and confirmation purposes.

## Notes
- Never Click Pay now twice , always check etherscan /bscscan if funds were sent, or not . Wait for cooling off period of 2 mins before 2nd attempt.
- Always ensure that the main address for each coin is correctly set up and funded to prevent delays in the withdrawal process.
- Regularly monitor gas prices to allocate sufficient funds for transaction fees, especially during times of network congestion.

