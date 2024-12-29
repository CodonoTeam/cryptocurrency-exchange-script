# Blockgum Multichain EVM Wallet

## Integration with Blockgum Wallet Server App

### Setup

1. Follow the instructions on [Blockgum GitHub Repository](https://github.com/blockgum/blockgum).
2. Download [Ian Coleman's BIP39 Tool](https://github.com/iancoleman/bip39) (disconnect from the internet, optional).
3. Once setup is completed, grab the `xprv` and `xpub` from your seed using the following path:  
   ```
   m/44'/60'/0'/0
   ```
   - Ensure the selected coin is **ETH**.
   - Under **Derivation Path**, select **BIP32**.
   - Set the **Client** to: Custom derivation path.
   - Enter the path:  
     ```
     m/44'/60'/0'/0
     ```
4. Paste or generate mnemonics.
5. Verify that the 0th address matches the one shown in MetaMask (to confirm everything is set up correctly).
6. Copy the **BIP32 Extended Private Key** and **BIP32 Extended Public Key**.
7. Paste the above information during the Blockgum setup process.

### Linking to Blockgum Dashboard

1. Copy the server information from the Blockgum setup and save it to [Blockgum Dashboard](https://dash.blockgum.com/).
2. Make an order on the Blockgum Dashboard.
3. After placing the order:
   - Go to **Orders** and click **Activate**.
   - Select the server information from the dropdown.
4. Copy the license or scan it with the Blockgum App to update.

### Final Steps

1. Change the `CLIENTID` in the `.env` file.
2. Restart the Blockgum app using:
   ```bash
   systemctl restart blockgum
   ```
3. Paste the Blockgum information into the **Admin/Options** section in the exchange admin area.
4. Check the URL:
   ```
   yoursite.com/Test/blockgum
   ```
   Ensure debug mode is enabled to verify if Blockgum is working correctly.
