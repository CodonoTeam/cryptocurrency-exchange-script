## How to Get Google Client ID and Client Secret?

Adding Google sign-in to your site can save time for your customers, allowing them to log in through Google in just one click. Before you can integrate Google sign-in into your website, you need to create a Google Client ID and Client Secret.

In this tutorial, we'll show you how to get Google Client ID and Client Secret in 10 simple and easy-to-follow steps.

**Note:** To generate Google Client ID and Client Secret, you must be signed into a Google account.

1. Go to the Google Developers Console. [https://console.cloud.google.com/]

2. Click on "Select a project" ➝ "New Project" ➝ click the "Create" button.

3. Enter your Project name ➝ click the "Create" button.

4. Click on "OAuth consent screen" in the left-side menu ➝ choose the User Type ➝ click the "Create" button.

5. Add the Application name ➝ Support email ➝ Authorized domain ➝ Developer content information ➝ click the "Save and Continue" button.

6. Complete all 4 steps in the OAuth consent screen ➝ click the "Back to Dashboard" button.

7. Go to "Credentials" ➝ click "Create Credentials" ➝ select "OAuth client ID" from the dropdown list.

8. Open the dropdown list "Application type" ➝ select "Web application" ➝ enter the name of your OAuth 2.0 client.

9. Enter your site URL in "Authorized JavaScript origins" ➝ in "Authorized redirect URIs," enter the page URL where you want your users redirected back after they have authenticated with Google ➝ click the "Create" button.

   **Important**
   - Authorized JavaScript Origins -> `https://yoursite.com`
   - Authorized Redirect URL -> `https://yoursite.com/Login/googleRedirect`

10. Copy your Client ID and Client Secret.

11. Open your `other_config.php` file, set `GOOGLE_LOGIN_ALLOWED` to `1`, and paste your `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`.
