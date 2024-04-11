## Airdrop Manager 

### Overview
This form is for managing and creating new airdrop events where users holding a specific currency receive rewards.

### Form Fields

- **AirDrop Title**:
  - Type: `Text Input`
  - Description: The name of the airdrop event.
  - Placeholder: `Any language`

- **Holding currency**:
  - Type: `Dropdown Selection`
  - Description: The currency users must hold to be eligible for the airdrop.
  - Options: `[ARBIUSDT, USDT, BTC, etc.]`

- **Reward currency**:
  - Type: `Dropdown Selection`
  - Description: The currency that will be distributed as a reward.
  - Options: `[DOGE, ADA, ETH, etc.]`

- **Quantity**:
  - Type: `Text Input`
  - Description: The total amount of the reward currency to be distributed.
  - Placeholder: `Total Airdrop of reward currency`

- **Airdrop Introduction**:
  - Type: `Textarea`
  - Description: A brief description or instructions about the airdrop.
  - Placeholder: `100k Doge to be distributed...`

- **Sort**:
  - Type: `Text Input`
  - Description: The order in which the airdrop appears in lists.
  - Placeholder: `Integer`

- **Promo**:
  - Type: `Image Upload`
  - Description: Image representing the airdrop promotion.

- **Featured**:
  - Type: `Dropdown Selection`
  - Description: Indicates if the airdrop is featured prominently.
  - Options: `[No, Yes]`

- **Active**:
  - Type: `Dropdown Selection`
  - Description: Indicates if the airdrop is currently active.
  - Options: `[No, Yes]`

- **add time**:
  - Type: `Datetime Input`
  - Description: The time when the airdrop was added.
  - Placeholder: `Default: Current Time`

- **Edit time**:
  - Type: `Datetime Input`
  - Description: The time when the airdrop was last edited.
  - Placeholder: `Default: Current Time`

### Actions
- **Submit**: Saves the airdrop configuration.
- **Back**: Returns to the previous page without saving changes.

Please note to provide correct values for all the dropdowns and maintain the system totals to avoid discrepancies.
