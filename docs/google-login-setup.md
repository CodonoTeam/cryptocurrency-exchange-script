# Integrating Google Sign-In into Your Website

Google Sign-In can streamline the login process for your users by allowing them to sign in with their Google account. Follow these steps to create a Google Client ID and Client Secret for your website.

**Pre-requisites:**
- You must be signed into a Google account to create a Google Client ID and Client Secret.

## Steps to Obtain Google Client ID and Client Secret

1. **Access Google Developers Console**
   - Navigate to the [Google Developers Console](https://console.cloud.google.com/).

2. **Create a New Project**
   - Click on "Select a project" at the top of the screen, then "New Project," and finally click the "Create" button.

3. **Set Up Project Details**
   - Enter your Project name and then click the "Create" button.

4. **Configure OAuth Consent Screen**
   - Select "OAuth consent screen" from the left sidebar, choose your User Type, and click the "Create" button.

5. **Enter Application Information**
   - Provide the following details:
     - Application name
     - Support email
     - Authorized domain (for example, `yoursite.com`)
     - Developer contact information
   - Click the "Save and Continue" button.

6. **Complete OAuth Consent Steps**
   - Fill in all required steps on the OAuth consent screen and then click the "Back to Dashboard" button.

7. **Create Credentials**
   - Go to the "Credentials" section, click "Create Credentials," and choose "OAuth client ID" from the dropdown menu.

8. **Register Application Type**
   - From the "Application type" dropdown, select "Web application" and enter the name for your OAuth 2.0 client.

9. **Set Authorized URIs**
   - Enter your site URL under "Authorized JavaScript origins."
   - For "Authorized redirect URIs," input the URL where users will be redirected after authentication (e.g., `https://yoursite.com/Login/googleRedirect`).
   - Click the "Create" button.

   > **Important:**
   > - Authorized JavaScript Origins: `https://yoursite.com`
   > - Authorized Redirect URL: `https://yoursite.com/Login/googleRedirect`

10. **Retrieve Client ID and Secret**
    - Copy your Client ID and Client Secret from the confirmation screen.

11. **Update Your Configuration**
    - In your `other_config.php` file, set `GOOGLE_LOGIN_ALLOWED` to `1`.
    - Paste your `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` into the respective fields.

## Next Steps

Once you have obtained your Client ID and Client Secret, proceed with the integration into your site's authentication system using the provided values.
