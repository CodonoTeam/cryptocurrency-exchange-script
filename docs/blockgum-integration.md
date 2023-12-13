#Blockgum Multichain EVM wallet
```
Integration with Blockgum Wallet Server App
```
#Setup 
```
Follow instructions on https://github.com/blockgum/blockgum
```
0. Download https://github.com/iancoleman/bip39 release [disconnect from internet optional]
1. Once setup is completed grab xprv and xpub from your seeds with following path m/44'/60'/0'/0
2. make sure coin selected is ETH 
3. Under derivation path select bip32
4. Client : Custom derivation path
5. Path : m/44'/60'/0'/0
6. Paste or Generate mnemonics 
7. Check 0th address is same as showing in metamask [ to confirm everything is fine]
8. Copy [BIP32 Extended Private Key and BIP32 Extended Public Key]
9. Paste above information while blockgum setup
10. Copy server from blockgum setup and save it to https://dash.blockgum.com/
11. Make order on Blockgum Dashboard
12. After order goto Orders > click activate
13. Select Server information from dropdown
14. Copy license or scan it with Blockgum App to update
15. Change CLIENTID in .env file
16. restart blockgum app using systemctl restart blockgum
17. Paste blockgum info to Admin/Options in exchange admin area.
18. Check yoursite.com/Test/blockgum  [under debug on] to see if blockgum is wokring 
