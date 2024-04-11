## Voting Competition Form

### Overview
This form is used to create a voting competition between two coins. The community can vote for their preferred coin. The winner at the end of the voting period gets listed on the exchange.

### Form Fields

- **Coin1 name**: 
  - Type: `Text Input`
  - Description: The symbol for the first coin competing in the voting (e.g., BTC).
  - Placeholder: `Symbol [e.g., BTC, LTC, XRP]`

- **Coin2 name**:
  - Type: `Text Input`
  - Description: The symbol for the second coin competing in the voting (e.g., ETH).
  - Placeholder: `Symbol [e.g., ETH, BCH, ADA]`

- **Virtual Support Votes**:
  - Type: `Integer Input`
  - Description: Initial number of votes in support of Coin1.

- **Virtual Against Votes**:
  - Type: `Integer Input`
  - Description: Initial number of votes against Coin1, potentially in support of Coin2.

- **Coin 1 Image**:
  - Type: `Image Upload`
  - Description: Upload an image representing Coin1.

- **Coin 2 Image**:
  - Type: `Image Upload`
  - Description: Upload an image representing Coin2.

- **Competition currency**:
  - Type: `Dropdown Selection`
  - Options: `[ARBIUSDT, USDT, BTC, etc.]`
  - Description: The currency used for deducting votes.

- **Featured**:
  - Type: `Checkbox`
  - Description: Check if the competition should be featured on the homepage.

- **Start time**:
  - Type: `Datetime Input`
  - Description: The start date and time for the competition.

- **End time**:
  - Type: `Datetime Input`
  - Description: The end date and time for the competition when votes will be counted and the winner decided.

- **Price**:
  - Type: `Integer Input`
  - Description: The price per vote, if applicable.

- **Active**:
  - Type: `Checkbox`
  - Description: Check if the competition is currently active.

### Actions
- **Submit**: Saves the competition configuration.
- **Back**: Returns to the previous page without saving changes.

Ensure to provide detailed instructions for image uploads and other input validations to maintain data integrity.
