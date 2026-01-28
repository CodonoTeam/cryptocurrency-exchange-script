# Cryptocurrency Exchange Script | Binance Clone | White Label Exchange

[![GitHub stars](https://img.shields.io/github/stars/CodonoTeam/cryptocurrency-exchange-script?style=social)](https://github.com/CodonoTeam/cryptocurrency-exchange-script/stargazers)
[![License](https://img.shields.io/badge/License-Commercial-blue.svg)](https://codono.com/pricing/)
[![Version](https://img.shields.io/badge/Version-7.5.5-green.svg)](changelog.md)
[![PHP](https://img.shields.io/badge/PHP-8.1%2B-purple.svg)](https://php.net)
[![Demo](https://img.shields.io/badge/Demo-Live-orange.svg)](https://demo.codono.com)

<p align="center">
  <img src="assets/crypto-exchange-script-codono-software.webp" alt="Cryptocurrency Exchange Script" width="600">
</p>

**Launch your own cryptocurrency exchange in days, not months.** Codono is a complete, battle-tested exchange solution with 6+ years of development, trusted by exchanges worldwide.

---

## Table of Contents

- [Premium Trading Modules](#-premium-trading-modules)
- [Quick Start](#-quick-start)
- [Screenshots](#-screenshots)
- [Core Features](#-core-features)
- [Admin Panel](#-admin-panel)
- [Supported Blockchains](#-supported-blockchains)
- [Documentation](#-documentation)
- [Why Codono?](#-why-codono)
- [FAQ](#-faq)
- [Support](#-support)

---

## Premium Trading Modules

### Perpetual Futures Trading

Trade crypto with up to **125x leverage**. Enterprise-grade derivatives platform:

- Cross & Isolated margin modes
- Mark price aggregated from 6 exchanges (manipulation resistant)
- Real-time funding rate calculations
- Auto-deleveraging (ADL) system
- Liquidation engine with insurance fund
- WebSocket real-time order updates

<p align="center">
  <img src="assets/spot_trading_software.webp" alt="Perpetual Futures Trading" width="500">
</p>

### Margin Trading (Isolated)

Leveraged spot trading with advanced risk management:

- Up to **20x leverage** per market
- Isolated margin positions
- Auto-liquidation at maintenance margin
- Loan interest calculations
- Real-time P&L tracking
- Position management dashboard

<p align="center">
  <img src="assets/margin_trading.webp" alt="Margin Trading Platform" width="500">
</p>

### Forex Trading

Professional forex trading module:

- **100+ currency pairs** (majors, minors, exotics)
- Up to **100x leverage**
- Real-time quotes from multiple providers
- Configurable spread management
- Multi-currency account support
- TradingView charts integration

### NFT Marketplace

Full-featured NFT trading platform:

- Create, mint, buy, sell NFTs
- Auction system with live bidding
- Multi-chain support (Ethereum, BSC, Polygon)
- Creator royalty management
- Collection & gallery management
- Lazy minting support

---

## Trading Modules Comparison

| Module | Leverage | Settlement | Key Features |
| ------ | -------- | ---------- | ------------ |
| **Spot Trading** | 1x | Instant | Classic & Pro UI, real-time orderbook |
| **Margin Trading** | Up to 20x | T+0 | Isolated positions, auto-liquidation |
| **Perpetual Futures** | Up to 125x | Perpetual | Cross/Isolated margin, funding rates |
| **Forex Trading** | Up to 100x | Real-time | 100+ pairs, spread management |
| **P2P Trading** | 1x | Escrow | Peer-to-peer, multiple payment methods |
| **NFT Marketplace** | - | Blockchain | Multi-chain, auctions, royalties |

---

## Quick Start

Get your exchange running with a single command:

```bash
# One-command setup (Ubuntu 20.04/22.04)
curl -sSL https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/codono_init.sh | bash
```

Or manual setup:

```text
1. Download    ->  Get the Codono Kit from codono.com/download
2. Install     ->  Follow automatic setup guide (docs/oneinstack_setup/)
3. Configure   ->  Set up coins via Admin Panel (manage/coins.md)
4. Add Markets ->  Create trading pairs (manage/market.md)
5. Launch      ->  Your exchange is live!
```

**Average setup time: 30 minutes**

[**Download Free Kit**](https://codono.com/download/) | [**View Live Demo**](https://demo.codono.com) | [**Setup Guide**](docs/oneinstack_setup/README.md)

---

## Screenshots

| Spot Trading | Admin Dashboard | Mobile App |
| :----------: | :-------------: | :--------: |
| <img src="assets/spot_trading_software.webp" width="250"> | <img src="assets/admin_trading.webp" width="250"> | <img src="assets/mobile.png" width="150"> |

| P2P Trading | Launchpad (ICO/IEO) | Margin Trading |
| :---------: | :-----------------: | :------------: |
| <img src="assets/p2p.webp" width="250"> | <img src="assets/launchpad_codono.webp" width="250"> | <img src="assets/margin_trading.webp" width="250"> |

---

## Core Features

| Feature | Description |
| ------- | ----------- |
| **Spot Trading** | Classic & Pro interfaces with real-time orderbook |
| **P2P Trading** | Peer-to-peer with escrow protection |
| **OTC Desk** | Large volume trades off-orderbook |
| **ICO/IEO Launchpad** | Token sale platform with allocation system |
| **Staking** | Flexible & locked staking with rewards |
| **Mining Module** | Cloud mining with reward distribution |
| **NFT Marketplace** | Create, buy, sell, auction NFTs |
| **Mobile App** | iOS & Android native apps (Ionic) |
| **Easy Trade** | Simplified buy/sell for beginners |
| **Voting** | Community token listing votes |
| **Airdrop** | Token distribution campaigns |
| **Faucet** | Free token claims for engagement |
| **Leaderboard** | Trading competitions & rankings |
| **API Integration** | Full REST API for trading bots |

[View All Features](https://codono.com/features/)

---

## Admin Panel

Full control over your exchange from a powerful admin dashboard:

<p align="center">
  <img src="assets/admin_trading.webp" alt="Admin Dashboard" width="600">
</p>

### User Management

- KYC verification & document review
- Account status control (active/suspended/banned)
- Balance adjustments & transaction history
- User activity logs & security monitoring

### Trading Configuration

- [**Add/Edit Coins**](manage/coins.md) - Configure any cryptocurrency
- [**Market Pairs**](manage/market.md) - Set up trading pairs with custom fees
- [**Staking Plans**](manage/staking.md) - Create investment products
- [**Launchpad**](manage/launchpad.md) - Host ICO/IEO token sales
- [**Airdrop**](manage/airdrop.md) - Distribute tokens to users
- [**Mining**](manage/mining.md) - Configure mining rewards
- [**Competition**](manage/competition.md) - Trading competitions

### Revenue Management

- Trading fee configuration per market
- Withdrawal fee settings per coin
- Referral bonus tiers (3 levels)
- Fee collection to designated accounts

### Security Controls

- 2FA enforcement settings
- IP whitelisting
- Login attempt limits
- Withdrawal approval workflow
- Anti-fraud monitoring

[**Full Admin Documentation**](manage/README.md)

---

## Supported Blockchains

### Native Integrations

| Blockchain | Tokens | Notes |
| ---------- | ------ | ----- |
| **Bitcoin** | BTC, BCH, LTC, DOGE, DASH, ZCASH | Full node support |
| **Ethereum & EVM** | ERC20, BEP20, FTM20, AVAX, Polygon | All EVM chains via [chainlist.org](https://chainlist.org) |
| **TRON** | TRX, TRC20, TRC10 | Pro & Ultra editions |
| **Ripple** | XRP | Native integration |
| **Monero** | XMR, Cryptonote coins | Privacy coins |
| **Polkadot** | DOT, Substrate tokens | Ecosystem support |
| **Waves** | WAVES, Waves tokens | Full integration |
| **Nexa** | NEXA, Nexa tokens | Native support |

### Third-Party Integrations

| Provider | Coins Supported | Use Case |
| -------- | --------------- | -------- |
| [**CoinPayments**](https://coinpayments.net) | 2000+ | Multi-coin gateway |
| [**Blockgum**](docs/blockgum-integration.md) | All EVM chains | Cross-chain wallet |
| [**CryptoApis.io**](docs/cryptoapis.io.setup.md) | Multiple | API-based integration |
| **Block.io** | BTC, LTC, DOGE | Simple integration |

### Fiat Gateways

| Gateway | Regions | Features |
| ------- | ------- | -------- |
| **Bank Deposit** | Global | Manual verification |
| **Authorize.net** | US/Canada | Credit card processing |
| **YocoPayments** | South Africa | Local payments |
| **Mobile Money** | Africa | M-Pesa, MTN, etc. |

*Custom fiat gateway integration available upon request*

---

## Documentation

### Setup Guides

- [**Automatic Setup (Recommended)**](docs/oneinstack_setup/README.md)
- [Manual Exchange Setup](docs/exchange-setup.md)
- [How Does Codono Work](docs/how-does-codono-work.md)
- [Multi-Server Setup](docs/multi_server/README.md)

### Blockchain Setup

- [BEP20 Token Setup](docs/bep20-setup.md)
- [TRC20 Token Setup](docs/trc20-setup.md)
- [TRON Setup](docs/tron_setup.md)
- [XRP Setup](docs/xrp-setup-crypto-exchange.md)
- [Ethereum (Geth)](docs/geth-codono-working.md)
- [Polkadot/Substrate](docs/substrate-node-solution.md)
- [All Node Setups](node-setup/)

### Integrations

- [Blockgum Integration](docs/blockgum-integration.md)
- [CryptoApis.io Setup](docs/cryptoapis.io.setup.md)
- [Binance Cross Trading](docs/binance-cross-trading-setup.md)
- [WebSocket & Liquidity](docs/WebSocketConfigLiquidity.md)
- [Google Login Setup](docs/google-login-setup.md)
- [Shuftipro KYC](docs/shuftipro-setup-requirements.md)

### Security

- [Security Best Practices](docs/security-tips.md)
- [Must-Follow Security](docs/must-follow-security.md)
- [Things to Avoid](docs/things-to-avoid.md)

---

## Why Codono?

| Feature | Codono | Competitors |
| ------- | ------ | ----------- |
| **Source Code** | Full access | Encrypted/Obfuscated |
| **Customization** | Unlimited | Limited |
| **Supported Coins** | 2000+ | 10-50 |
| **Mobile App** | Included | Extra cost |
| **P2P Trading** | Included | Extra cost |
| **Futures Trading** | Included | Extra cost |
| **Margin Trading** | Included | Extra cost |
| **NFT Marketplace** | Included | Extra cost |
| **Payment Model** | One-time | Monthly subscription |
| **Updates** | 1 year included | Extra cost |
| **Support** | Telegram + Live Chat | Email only |

### 6+ Years of Development

- Battle-tested in production environments
- Regular security updates
- Continuous feature additions
- Active developer community

---

## FAQ

<details>
<summary><b>What programming languages is Codono built with?</b></summary>

- **Backend:** PHP 8.1+ (ThinkPHP framework)
- **Frontend:** Vue.js 3
- **Mobile App:** Ionic/Angular
- **Trading Engine:** Node.js (TypeScript)
- **Database:** MySQL, Redis, QuestDB (for time-series)

</details>

<details>
<summary><b>Do I need to run blockchain nodes?</b></summary>

No, running your own nodes is optional. You can use third-party services like:

- **Blockgum** - For all EVM chains
- **CoinPayments** - For 2000+ coins
- **CryptoApis.io** - API-based integration

However, running your own nodes gives you more control and lower fees.

</details>

<details>
<summary><b>Is there a live demo I can try?</b></summary>

Yes! Visit [demo.codono.com](https://demo.codono.com) to test all features including:

- Spot trading
- P2P marketplace
- Wallet functions
- Admin panel (request access)

</details>

<details>
<summary><b>What's included in the license?</b></summary>

- Full source code access
- 1 year of updates
- Installation support
- Documentation access
- Telegram community support
- Single domain license (multi-domain available)

</details>

<details>
<summary><b>Can I customize the design?</b></summary>

Yes, completely! You get full source code access, so you can:

- Change colors, logos, branding
- Modify UI components
- Add new features
- Integrate with other systems

</details>

<details>
<summary><b>What about regulatory compliance?</b></summary>

Codono includes:

- KYC/AML integration (Shuftipro, SumSub)
- Transaction monitoring
- Withdrawal limits
- IP-based restrictions
- Audit logs

You're responsible for compliance with local regulations.

</details>

---

## Support

<p align="center">
  <a href="https://t.me/ctoninja">
    <img src="https://img.shields.io/badge/Telegram-Join%20Chat-blue?style=for-the-badge&logo=telegram" alt="Telegram">
  </a>
  <a href="https://codono.com">
    <img src="https://img.shields.io/badge/Website-codono.com-orange?style=for-the-badge&logo=google-chrome" alt="Website">
  </a>
  <a href="https://codono.com/contact">
    <img src="https://img.shields.io/badge/Live%20Chat-Available-green?style=for-the-badge&logo=livechat" alt="Live Chat">
  </a>
</p>

---

## Ready to Launch Your Exchange?

<p align="center">
  <a href="https://codono.com/download/">
    <img src="https://img.shields.io/badge/Download%20Free%20Kit-Get%20Started-success?style=for-the-badge&logo=download" alt="Download">
  </a>
  <a href="https://demo.codono.com">
    <img src="https://img.shields.io/badge/View%20Live%20Demo-Try%20Now-blue?style=for-the-badge&logo=eye" alt="Demo">
  </a>
  <a href="https://codono.com/pricing/">
    <img src="https://img.shields.io/badge/View%20Pricing-Plans-purple?style=for-the-badge&logo=stripe" alt="Pricing">
  </a>
</p>

---

<p align="center">
  <sub>Built with dedication by the Codono Team | <a href="https://codono.com">codono.com</a></sub>
</p>
