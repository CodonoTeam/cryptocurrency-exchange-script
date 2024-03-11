# Security Measures for Codono Exchange

To ensure the highest level of security for the Codono Exchange platform, it is crucial to follow these guidelines rigorously. Below, we detail important security practices that must be implemented and regularly monitored.

## 1. Two-Factor Authentication (2FA) for Admin Accounts

- **Action:** Always keep Two-Factor Authentication (2FA) enabled for Admin accounts.
- **Rationale:** 2FA adds an extra layer of security by requiring a second form of verification beyond just a password. This significantly reduces the risk of unauthorized access, even if a password is compromised.

## 2. Regularly Change ADMIN_KEY

- **Action:** Regularly update the `ADMIN_KEY` in the `pure_config.php` file.
- **Rationale:** Changing the `ADMIN_KEY` periodically helps in preventing unauthorized access. In the event of a key leakage, frequent updates limit the time window an attacker has to exploit the exposed key.

## 3. Secure the Cron Key

- **Action:** Do not share the Cron Key (`CRON_KEY`) with anyone.
- **Rationale:** The Cron Key is used to authenticate scheduled tasks running in the background. Exposure of this key could allow an attacker to trigger or manipulate scheduled tasks, leading to potential security breaches.

## 4. Change the Default SSH Port

- **Action:** Modify the default SSH port (22) to a custom port within the range of 10000 to 64000.
- **Instructions:** You can change the SSH port in the SSH configuration file (`/etc/ssh/sshd_config`) by altering the `Port` directive.
- **Rationale:** Changing the default SSH port reduces the risk of automated attacks and scans targeting port 22, the default SSH port, making it harder for attackers to identify open SSH services.

## 5. Regular Database Backups

- **Action:** Utilize the backup options available in `/opt/oneinstack` for regular database backups. Options for off-site backups like Dropbox or other cloud storage services should be considered.
- **Rationale:** Regular backups are crucial for disaster recovery and ensuring data integrity. Off-site backups provide an additional safety net against data loss due to hardware failure, cyber attacks, or other catastrophic events.

## 6. Conceal Exchange IP with Cloudflare Proxy

- **Action:** Always conceal your exchange's IP address behind Cloudflare's proxy services.
- **Rationale:** Using Cloudflare to hide the real IP address of your exchange server can protect against DDoS attacks. Cloudflare's proxy service acts as a buffer, absorbing and filtering malicious traffic before it can reach your server.

By adhering to these security practices, you can significantly enhance the protection of your Codono Exchange platform against a wide array of cyber threats. Regular audits and updates to your security measures are recommended to adapt to evolving security challenges.
