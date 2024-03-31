# Codono + Geth Integration Guide

## Manual Token and Ethereum Transfer

### User Accounts

Users are provided with distinct addresses so that once balance is transferred to these addresses, it is identified by an automatic cron job named `esmart_deposit`. Each user's wallet balance must be transferred to the main account to be utilized by the exchange. The main account is an Ethereum address created during the Geth setup; its public address and password (used to encrypt the private key) are stored in the backend coin configuration.

**Important:** Each user's private key is encrypted with a password specified in `pure_config.php` under the name `ETH_USER_PASS`. Changing this password inappropriately can result in losing access to all user private keys. It is advisable only to change this password during the initial setup of Ethereum and ERC20 tokens with the exchange. To change the password safely, first, transfer all user funds to the main account, then proceed with the password update.

### Token Moving Cron (User to Main)

To transfer token funds to the main account, run the following URL in your browser carefully:

```
http://YourSiteURL/Coin/esmart_token_to_main/coinname/TOKENNAMEHERE/securecode/cronkey
```

- Replace `YourSiteURL` with your website's URL.
- `cronkey` should be defined in `pure_config.php`.
- Replace `TOKENNAMEHERE` with the actual token name, e.g., USDT.

#### Example URL

```
https://myexchange.com/Coin/esmart_token_to_main/coinname/usdt/securecode/g587g5478
```

### Ethereum Moving Cron (User to Main)

To move Ethereum funds to the main account, use the following URL format:

```
http://YourSiteURL/Coin/esmart_to_main/coin/{coin}/securecode/cronkey
```

Replace `YourSiteURL` and `cronkey` as before. 

#### Example URLs

```
https://myexchange.com/Coin/esmart_to_main/coin/bnb/securecode/g587g5478
https://myexchange.com/Coin/esmart_to_main/coin/eth/securecode/g587g5478
```

**Note:** Always transfer tokens before Ethereum because tokens require Ethereum as gas. If insufficient gas is available, the main account will provide gas to the user accounts, which could be costly.

### Codono Missing Transactions for Eth/ERC20

To trace missing deposits for Ethereum/ERC20:

1. **Find the transaction ID (txid)** from sources like Etherscan.
2. **Identify the current block** being read by the exchange by running the `walleteth` cron manually.
3. Go to `Frontend -> Finance -> Trace Missing`, enter the txid, select the correct chain, and execute the tracing to deposit any missing funds.

**Final Note:** While the above cron jobs facilitate fund transfers, for long-term efficiency, consider using `blockgum`, as they are faster and less expensive.
