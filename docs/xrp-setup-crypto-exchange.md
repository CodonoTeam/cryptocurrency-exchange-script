---

## Setting Up XRP with Codono

XRP integration with Codono doesn't require any additional Coin node.

### Setup Instructions

1. **Generating XRP Account**

   Generate an XRP account where all user deposits will be automatically deposited using their `dest_tag`. You can generate the main account externally or by visiting [bithomp.com/paperwallet](https://bithomp.com/paperwallet/). Copy the secret and address and save them in a secure location.

   > **Note**: There are various offline and safe methods to generate Ripple addresses and keys. We recommend using them.

2. **Configure Coin in Admin Area**

   Navigate to `Admin -> Coin` and either find XRP or add a new one if it doesn't exist.

   - Symbol: `xrp`
   - Parent Symbol: `xrp` (or empty)
   - Frontend Title: Ripple [XRP Network]
   - Coin Type: XRP Chain
   - Token of: none
   - Wallet Server IP: Keep Empty
   - Wallet Server Port: Keep Empty
   - Server Username: Keep Empty
   - Wallet Server Password: Secret generated from above step
   - Main Account: Address value from above step
   - Block Explorer: [xrpcharts.ripple.com/#/transactions/](https://xrpcharts.ripple.com/#/transactions/)
   - Decimal: 6

3. **Deposit Cron**

   Set up a cron job to run every minute for deposit detection.

   ```
   Yoursite/Coin/xrpdeposit/securecode/cronkey
   ```

---
