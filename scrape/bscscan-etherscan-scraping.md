# Web Scraping BscScan Token Information Using Web Scraper Chrome Extension

In this tutorial, we will guide you through the process of scraping token information from BscScan using the Web Scraper Chrome extension. This will allow you to extract details such as token names, symbols, contract addresses, and decimals into a CSV file.

## Step 1: Install the Web Scraper Chrome Extension

1. Open Google Chrome and go to the [Web Scraper extension page](https://chromewebstore.google.com/detail/web-scraper/jnhgnonknehpejjnehehllkliplmbmhn?hl=en).
2. Click on the "Add to Chrome" button.
3. Confirm the installation by clicking "Add extension".

## Step 2: Navigate to BscScan Tokens Page

1. Open a new tab in Chrome and go to [BscScan Tokens](https://bscscan.com/tokens).

## Step 3: Activate Developer Tools

1. Right-click anywhere on the BscScan Tokens page.
2. Select "Inspect" to open Developer Tools.
3. Click on the "Web Scraper" tab in the Developer Tools menu.

## Step 4: Create a New Sitemap

1. In the Web Scraper tab, click on "Create new sitemap".
2. Choose "Import sitemap".
3. Paste the following JSON into the Import Sitemap dialog:

```json
{
    "_id": "tokens",
    "startUrl": ["https://bscscan.com/tokens"],
    "selectors": [
        {
            "id": "name",
            "parentSelectors": ["wrapper_for_name_symbol"],
            "type": "SelectorText",
            "selector": "div.hash-tag",
            "multiple": false,
            "regex": ""
        },
        {
            "id": "symbol",
            "parentSelectors": ["wrapper_for_name_symbol"],
            "type": "SelectorText",
            "selector": "span.text-muted",
            "multiple": false,
            "regex": ""
        },
        {
            "id": "wrapper_for_name_symbol",
            "parentSelectors": ["_root"],
            "type": "SelectorElement",
            "selector": "tbody tr",
            "multiple": true
        },
        {
            "id": "link",
            "parentSelectors": ["_root"],
            "type": "SelectorLink",
            "selector": "a.gap-1",
            "multiple": true,
            "linkType": "linkFromHref"
        },
        {
            "id": "decimals",
            "parentSelectors": ["link"],
            "type": "SelectorText",
            "selector": ".text-cap b",
            "multiple": false,
            "regex": ""
        },
        {
            "id": "contract",
            "parentSelectors": ["link"],
            "type": "SelectorText",
            "selector": "a.text-truncate.d-block",
            "multiple": false,
            "regex": ""
        },
        {
            "id": "img",
            "parentSelectors": ["link"],
            "type": "SelectorImage",
            "selector": "img.js-token-avatar",
            "multiple": false
        }
    ]
}
```

4. Click "Import Sitemap".

## Step 5: Scrape the Token Information

1. In the Web Scraper tab, select the newly created "Sitemap Tokens".
2. Click on "Scrape".
3. Wait for the scraping process to complete. This may take a few minutes depending on the number of tokens.

## Step 6: Export the Data

1. Once the scraping is complete, click on the "Export data" button.
2. Choose the format "CSV".
3. The CSV file with the scraped token information will be downloaded to your computer.

## Conclusion

You have successfully scraped token information from BscScan using the Web Scraper Chrome extension and exported it to a CSV file. You can now use this data for further analysis or integration into your projects.
