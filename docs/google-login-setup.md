# Integrating Google Sign-In into Your Crypto Exchange

Integrating Google Sign-In can streamline the login process by allowing users to authenticate using their Google account. This guide will help you create a Google Client ID and Client Secret for your crypto exchange platform.

**Pre-requisites:**
- A Google account is required to access the Google Developers Console.

## Steps to Obtain Google Client ID and Client Secret

1. **Access Google Developers Console**
   - Navigate to the [Google Developers Console](https://console.cloud.google.com/).

2. **Create a New Project**
   - Click on "Select a project" at the top of the screen, then choose "New Project." Complete the form and click "Create."

3. **Configure OAuth Consent Screen**
   - Select Api & Services > "OAuth consent screen" from the sidebar. Choose your User Type (usually 'External' for crypto exchanges) and click "Create."

4. **Enter Application Information**
   - Provide the following details:
     - Application name
     - Support email
     - Authorized domain (e.g., `yoursite.com`)
     - Developer contact information
   - Click "Save and Continue."

5. **Complete OAuth Consent Steps**
   - Complete the required steps indicated on the OAuth consent screen, then click "Back to Dashboard."

6. **Create Credentials**
   - Navigate to the "Credentials" tab, click "Create Credentials," and select "OAuth client ID."

7. **Register Application Type**
   - Choose "Web application" as the "Application type." Provide a name for your OAuth 2.0 client.

8. **Set Authorized URIs**
   - Under "Authorized JavaScript origins," add your site URL.
   - For "Authorized redirect URIs," enter the URL where users will be redirected after authentication (e.g., `https://yoursite.com/Login/googleRedirect`).
   - Click "Create."

   > **Important:**
   > - Authorized JavaScript Origins: `https://yoursite.com`
   > - Authorized Redirect URL: `https://yoursite.com/Login/googleRedirect`

9. **Retrieve Client ID and Secret**
    - Copy the Client ID and Client Secret from the confirmation screen.[ Or even save JSON file for future reference]

10. **Update Your Configuration**
    - In your site's configuration file (e.g., `other_config.php`), set `GOOGLE_LOGIN_ALLOWED` to `1`.
    - Add your `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` to the respective fields.

## Next Steps

With the Client ID and Client Secret, you can now integrate Google Sign-In into your site's authentication system. Ensure to follow security best practices when handling and storing these credentials.
