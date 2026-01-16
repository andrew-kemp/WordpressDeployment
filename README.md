# WordPress DeployKit 🚀

A comprehensive, automated WordPress deployment script for Ubuntu servers. This tool streamlines the process of deploying multiple WordPress sites on a single server with SSL certificates, database setup, and security hardening.

## 📋 Features

- **Automated WordPress Installation**: Downloads and installs the latest WordPress version
- **Multi-Site Support**: Deploy multiple WordPress sites on one server
- **SSL Certificate Options**:
  - Let's Encrypt (automated, production-ready)
  - Custom certificates (bring your own)
  - Self-signed certificates (for testing)
- **Database Management**: Automatic MariaDB database and user creation
- **Security Hardening**: 
  - Security headers (X-Frame-Options, CSP, HSTS, etc.)
  - Automatic HTTPS redirection
  - File edit protection in WordPress
- **Apache Configuration**: Pre-configured virtual hosts with best practices
- **Certificate Auto-Renewal**: Let's Encrypt certificates renew automatically
- **Site Management**: Maintains a registry of all deployed sites

## 🔧 Requirements

- **Operating System**: Ubuntu 20.04+ (other Debian-based distros may work)
- **Privileges**: Root access required
- **Network**: Port 80 and 443 open for web traffic
- **DNS**: Domain must point to server IP before installation (for Let's Encrypt)

## 📦 What Gets Installed

The script automatically installs and configures:

- Apache2 web server
- MariaDB database server
- PHP and required extensions (GD, MySQL, GMP, MBString, XML, cURL)
- Certbot for Let's Encrypt SSL
- Azure CLI (optional, for cloud integrations)
- Various utilities (wget, rsync, unzip, tar, openssl, curl, zip)

## 🚀 Quick Start

### Method 1: Direct Download and Execute

```bash
# Download the script
wget https://raw.githubusercontent.com/andrew-kemp/WordpressDeployment/main/wp-deploy.sh

# Make it executable
chmod +x wp-deploy.sh

# Run with sudo
sudo ./wp-deploy.sh
```

### Method 2: One-Line Install (wget)

```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/andrew-kemp/WordpressDeployment/main/install.sh)"
```

### Method 3: One-Line Install (curl)

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/andrew-kemp/WordpressDeployment/main/install.sh)"
```

## 📖 Usage Guide

### Interactive Setup

The script will guide you through the setup process with interactive prompts:

1. **Hostname**: Enter your domain (e.g., `www.example.com`)
2. **Admin Email**: Used for Let's Encrypt and Apache ServerAdmin
3. **Database Configuration**:
   - Database name (auto-suggested based on hostname)
   - Database username (auto-suggested)
   - Database password (can auto-generate)
4. **SSL Certificate Option**:
   - Option 1: Let's Encrypt (recommended)
   - Option 2: Existing certificate files
   - Option 3: Self-signed certificate (testing only)

### Example Deployment

```bash
$ sudo ./wp-deploy.sh

==> Enter your site hostname (FQDN): www.mysite.com
==> ServerAdmin email: admin@mysite.com
==> MariaDB database name [db_www_mysite_com]: 
==> MariaDB username [user_www_mysite_com]: 
==> MariaDB user password (leave blank to autogenerate): 

SSL options:
  1) Let's Encrypt (recommended, automated renewals)
  2) Use existing certificate files (provide paths)
  3) Generate self-signed certificate (for testing)
==> Choose SSL option (1/2/3) [1]: 

... (deployment proceeds)
```

### Multiple Sites

After completing the first site, you'll be asked:

```
==> Would you like to set up another site? (y/n) [n]:
```

Enter `y` to deploy additional sites on the same server.

## 📁 File Locations

After deployment:

- **Web Root**: `/var/www/YOUR_DOMAIN/`
- **Apache Config**: `/etc/apache2/sites-available/YOUR_DOMAIN.conf`
- **WordPress Config**: `/var/www/YOUR_DOMAIN/wp-config.php`
- **Site Registry**: `/etc/selfhostedwp/sites.list`
- **SSL Certificates**: 
  - Let's Encrypt: `/etc/letsencrypt/live/YOUR_DOMAIN/`
  - Self-signed: `/var/cert/YOUR_DOMAIN.crt` and `.key`
- **Apache Logs**: `/var/log/apache2/YOUR_DOMAIN_*.log`

## 🔐 Security Features

The script implements several security best practices:

1. **HTTPS Enforcement**: Automatic redirection from HTTP to HTTPS
2. **Security Headers**:
   - `X-Content-Type-Options: nosniff`
   - `X-Frame-Options: SAMEORIGIN`
   - `X-XSS-Protection: 1; mode=block`
   - `Referrer-Policy: strict-origin-when-cross-origin`
   - `Content-Security-Policy: upgrade-insecure-requests`
   - `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`
3. **WordPress Hardening**:
   - `DISALLOW_FILE_EDIT` enabled (prevents plugin/theme editing)
   - `FS_METHOD` set to 'direct' for better file handling
4. **File Permissions**: Proper ownership and permissions for web files
5. **Database Security**: Unique credentials per site with restricted privileges

## 🛠️ Post-Installation

### Complete WordPress Setup

1. Open your browser and navigate to `https://YOUR_DOMAIN`
2. Complete the WordPress installation wizard:
   - Site title
   - Admin username and password
   - Email address
3. Log in and start building your site

### Recommended Next Steps

1. **Update WordPress**: Keep WordPress, themes, and plugins updated
2. **Install Security Plugins**: Consider Wordfence, iThemes Security, or similar
3. **Configure Backups**: Set up automated backups of files and database
4. **Harden Security**: 
   - Use strong passwords
   - Enable two-factor authentication
   - Limit login attempts
5. **Performance Optimization**:
   - Install caching plugin (W3 Total Cache, WP Rocket, etc.)
   - Optimize images
   - Use a CDN if needed

## 🔄 Certificate Renewal

### Let's Encrypt (Automatic)

Let's Encrypt certificates are automatically renewed via `certbot.timer` systemd service.

Check renewal status:
```bash
sudo certbot renew --dry-run
```

### Manual Certificate Replacement

For custom certificates, update the paths in your Apache config:
```bash
sudo nano /etc/apache2/sites-available/YOUR_DOMAIN.conf
sudo apache2ctl configtest
sudo systemctl reload apache2
```

## 📊 Managing Multiple Sites

All deployed sites are tracked in `/etc/selfhostedwp/sites.list`:

```bash
# View all sites
cat /etc/selfhostedwp/sites.list

# Format: HOSTNAME|DB_NAME|DB_USER|WEBROOT|VHOST_FILE|SSL_OPTION
```

## 🐛 Troubleshooting

### Apache Won't Start

```bash
# Check Apache status
sudo systemctl status apache2

# Test configuration
sudo apache2ctl configtest

# View error logs
sudo tail -f /var/log/apache2/error.log
```

### Let's Encrypt Failed

Common causes:
- DNS not propagated (wait 30+ minutes after DNS changes)
- Port 80/443 blocked by firewall
- Domain doesn't resolve to server IP

Retry manually:
```bash
sudo certbot certonly --webroot -w /var/www/YOUR_DOMAIN -d YOUR_DOMAIN --email admin@YOUR_DOMAIN --agree-tos
```

### Database Connection Issues

Verify database credentials:
```bash
mysql -u YOUR_DB_USER -p YOUR_DB_NAME
```

Check `wp-config.php` has correct credentials:
```bash
sudo cat /var/www/YOUR_DOMAIN/wp-config.php | grep DB_
```

### Permission Errors

Reset WordPress file permissions:
```bash
sudo chown -R www-data:www-data /var/www/YOUR_DOMAIN
sudo find /var/www/YOUR_DOMAIN -type d -exec chmod 755 {} \;
sudo find /var/www/YOUR_DOMAIN -type f -exec chmod 644 {} \;
```

## 📝 Site Registry Format

The `/etc/selfhostedwp/sites.list` file format:

```
HOSTNAME|DB_NAME|DB_USER|WEBROOT|VHOST_FILE|SSL_OPTION
```

Example:
```
www.mysite.com|db_www_mysite_com|user_www_mysite_com|/var/www/www.mysite.com|/etc/apache2/sites-available/www.mysite.com.conf|1
```

## 🔧 Advanced Configuration

### Custom PHP Settings

Edit PHP configuration:
```bash
sudo nano /etc/php/$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')/apache2/php.ini
sudo systemctl restart apache2
```

### Apache Performance Tuning

Edit Apache MPM settings:
```bash
sudo nano /etc/apache2/mods-available/mpm_prefork.conf
sudo systemctl restart apache2
```

### MariaDB Optimization

```bash
sudo mysql_secure_installation
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on a clean Ubuntu installation
5. Submit a pull request

## 📜 License

This project is provided as-is for educational and commercial use.

## ⚠️ Disclaimer

This script modifies system configurations and installs software. Always:
- Test on a non-production server first
- Backup your server before running
- Review the script before execution
- Ensure you have proper backups

## 📞 Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Review the troubleshooting section
- Check Apache and PHP error logs

## 🙏 Credits

Created to simplify WordPress deployment on Ubuntu servers with enterprise-grade security and automation.

---