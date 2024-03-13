# TRX and TRC20 Tokens Withdrawal Processing Guide for Codono

This guide outlines the steps required to process withdrawals using TRX and its TRC20 tokens in the Codono cryptocurrency exchange platform. Follow these steps to ensure a smooth withdrawal process.

## Step 1: Coin Configuration Check

- **Configuration Check**: Navigate to **Admin/Config/coin** and ensure that TRX and its TRC20 tokens are configured correctly with the main address set up properly.

## Step 2: Verify Main Address Balance

1. **Note Main Address**: Record or copy the main address for TRX or the TRC20 token you are processing.
2. **Explorer Check**: Use a blockchain explorer like [Tronscan](https://tronscan.org) to verify the main address has sufficient balance for the withdrawal.
3. **Gas Funds**: Confirm the main address has enough TRX to cover gas fees for the transaction.

## Step 3: Balance Top-Up (If Required)

If the main address does not have enough balance, use the following URL to transfer TRX or TRC20 tokens to the main address:

**Move TRX or TRC20 Tokens to Main Address**

```
http://exchange.local/Tron/MoveAsset/securecode/cronkey/

```

- **URL Replacement**: Replace `exchange.local` with your exchange's actual URL.
- **Process Execution**: Follow the instructions provided on the screen to complete the transfer of TRX or TRC20 tokens to the main address.

## Step 4: Reconfirmation

- **Block Explorer Check**: After topping up the main address, use [Tronscan](https://tronscan.org) to recheck the main address balance to confirm the updated balance accurately reflects the transferred amount.

## Step 5: Processing Withdrawals

1. **Crypto Withdrawal Page**: Go to the Crypto withdrawal page in the Codono admin panel.
2. **Initiate Payment**: Click the `pay now` button for the withdrawal request you intend to process.
3. **Transaction ID**: Allow up to few seconds for the transaction ID to appear in the admin panel, which is crucial for tracking and confirmation.

## Notes
- **Caution**: Never click 'Pay now' twice. Always verify on [Tronscan](https://tronscan.org) whether the funds were sent. Allow a cooling-off period of 2 minutes before making a second attempt.
- Ensure the main address for TRX and any TRC20 tokens are correctly set up and funded to avoid withdrawal delays.
- Regularly check gas prices on the TRON network to ensure sufficient TRX is allocated for transaction fees, especially during periods of network congestion.
