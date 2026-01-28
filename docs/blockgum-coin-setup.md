# Blockgum Multichain EVM Wallet Configuration

## Wallet Configuration for BNB Coin

### General Details
- **Symbol**: bnb
- **Title**: Binance Coin
- **CoinType**: Blockgum EVM Wallet
- **Token of**: None
- **Contract Address**: [Leave Blank]
- **Main Account**: MAINACCOUNTADDRESS
- **Block Explorer**: [https://bscscan.com/tx/](https://bscscan.com/tx/)
- **Decimals**: 8
- **Automatic Withdrawal**: 0.0001 (Amount auto-approved for withdrawal without admin consent)

---

### Adding BEP20 Tokens

1. Go to the contract address on [bscscan.com](https://bscscan.com/token/0xe9e7cea3dedca5984780bafc599bd69add087d56) to get token details (e.g., **BUSD**).
   
#### Token Details Example (for BUSD)
- **Symbol**: busd
- **Title**: Binance-Peg BUSD Token
- **CoinType**: Blockgum EVM Wallet
- **Token of**: BNB
- **Contract address**: 0xe9e7cea3dedca5984780bafc599bd69add087d56 (Get from bscscan.com)
- **Main Account**: MAINACCOUNTADDRESS
- **Block Explorer**: [https://bscscan.com/tx/](https://bscscan.com/tx/)
- **Decimals**: 18 (Get from bscscan.com)
- **Automatic Withdrawal**: 0.0001 (Amount auto-approved for withdrawal without admin consent)

---

## Cron Jobs

### Required Cron Jobs
1. **Blockgum Deposit Detection**  
   - **Command**:  
     ```bash
     * * * * * cd /data/wwwroot/codebase/yourdomain.com && php index.php Coin/blockgum_deposit/securecode/cronkey/
     ```
   - **URL**:  
     [http://exchange.local/Coin/blockgum_deposit/securecode/cronkey/](http://exchange.local/Coin/blockgum_deposit/securecode/cronkey/)
   - **Frequency**: Every minute

2. **Blockgum Withdrawal Hash Retrieval**  
   - **Command**:  
     ```bash
     */5 * * * * cd /data/wwwroot/codebase/yourdomain.com && php index.php Coin/getWithdrawalIdBlockgum/securecode/cronkey/
     ```
   - **URL**:  
     [http://exchange.local/Coin/getWithdrawalIdBlockgum/securecode/cronkey/](http://exchange.local/Coin/getWithdrawalIdBlockgum/securecode/cronkey/)
   - **Frequency**: Every 5 minutes

---

### On-Demand Tools

1. **Move Tokens to Main**  
   - URL:  
     [http://exchange.local/Coin/blockgum_token_to_main/securecode/cronkey/coinname/tokenNameHere](http://exchange.local/Coin/blockgum_token_to_main/securecode/cronkey/coinname/tokenNameHere)

2. **Move Coins to Main**  
   - URL:  
     [http://exchange.local/Coin/blockgum_coin_to_main/securecode/cronkey/coinname/coinNameHere](http://exchange.local/Coin/blockgum_coin_to_main/securecode/cronkey/coinname/coinNameHere)

3. **Token Watch (For New EVM Tokens)**  
   - URL:  
     [http://exchange.local/Coin/blockgum_watch/securecode/cronkey/](http://exchange.local/Coin/blockgum_watch/securecode/cronkey/)

---

This document details the full setup and operational guidelines for Blockgum Multichain EVM Wallet integration in **Codono**. Ensure all configurations and cron jobs are set up correctly for optimal operation.
