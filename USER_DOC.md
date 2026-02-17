# User Documentation

## Overview

This document provides instructions for end users and system administrators to understand, use, and manage the Inception web infrastructure.

## Services Provided

The Inception stack provides the following services:

### Mandatory Services

**1. NGINX** - Web server with SSL/TLS (port 443)
- HTTPS encryption (TLSv1.2/1.3)
- Reverse proxy to WordPress and Adminer
- Self-signed SSL certificate

**2. WordPress** - Content management system (port 9000, internal)
- PHP 8.2 with FPM
- Full admin panel and content creation
- Two users: administrator and contributor

**3. MariaDB** - Database server (port 3306, internal)
- Persistent data storage
- Automatic initialization

### Bonus Services

**4. Redis** - Cache server (port 6379, internal)
- WordPress performance optimization
- Reduces database load by ~90%

**5. FTP Server** - File management (ports 21, 21000-21010)
- vsftpd for WordPress files
- Credentials in `.env`: FTP_USER / FTP_PASSWORD

**6. Adminer** - Database management (via NGINX)
- Access: https://dgermano.42.fr/adminer
- Lightweight phpMyAdmin alternative

**7. Static Website** - Portfolio site (port 8080)
- HTML/CSS/JS only (no PHP)
- Access: http://localhost:8080

**8. Portainer** - Container management (port 9443)
- Visual dashboard for Docker
- Access: https://localhost:9443

> **Detailed bonus documentation:** See [BONUS_DOC.md](BONUS_DOC.md)

## Starting and Stopping the Project
**What happens during startup:**
1. Data directories created: `/home/$USER/data/mariadb` and `/home/$USER/data/wordpress`
2. Docker images built from Dockerfiles
3. Containers start: MariaDB → WordPress (+ Redis cache) → NGINX → Bonus services
4. Services available at configured URLs

**Expected containers (8 total):**
nginx, wordpress, mariadb, redis, ftp, adminer, static-site, portainer

**Startup time:** 30-60 seconds (first time), 10-20 seconds (subsequent)
```bash
cd /path/to/Inception
docker-compose -f srcs/docker-compose.yml up -d --build
```

**What happens during startup:**
1. Data directories are created on the host system (`/home/$USER/data/mariadb` and `/home/$USER/data/wordpress`)
2. Docker images are built from Dockerfiles if they don't exist
3. Containers start in the following order:
   - MariaDB (creates database and users)
   - WordPress (downloads and configures WordPress)
   - NGINX (starts web server)
4. Services become available at https://dgermano.42.fr

**Startup time:** Approximately 30-60 seconds for first-time installation

### Stopping the Infrastructure

**Stop all services (containers remain for restart):**
```bash
make down
```

**Stop and remove containers, networks (keeps volumes):**
```bash
docker-compose -f srcs/docker-compose.yml down
```

**Stop a specific service:**
```bash
docker stop <container_name>
# Examples:
docker stop nginx
docker stop wordpress
docker stop mariadb
## Accessing Services

### Service URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| **WordPress** | https://dgermano.42.fr | Admin: `secrets/wordpress_admin_password` |
| **WordPress Admin** | https://dgermano.42.fr/wp-admin | User: from `.env` (WP_ADMIN_USER) |
| **Adminer** | https://dgermano.42.fr/adminer | DB credentials from secrets |
| **Static Site** | http://localhost:8080 | No login required |
| **Portainer** | https://localhost:9443 | Create account on first access |
| **FTP** | ftp://dgermano.42.fr:21 | FTP_USER / FTP_PASSWORD from `.env` |

**Note:** Self-signed SSL certificates require browser acceptance ("Advanced" → "Accept Risk").

### WordPress Access Details

**Administrator:**
- Username: Value of `WP_ADMIN_USER` in `.env` (default: `dgermano`)
- Password: Content of `secrets/wordpress_admin_password`

**Contributor:**
- Username: Value of `WP_USER` in `.env` (default: `user`)
- Password: Content of `secrets/credentials.txt`
3. Click "Advanced" and "Accept Risk and Continue" (or similar, depending on browser)
4. The WordPress homepage will appear

### WordPress Administration Panel

- **URL:** https://dgermano.42.fr/wp-admin
- **Alternative:** https://dgermano.42.fr/wp-login.php

**Login credentials (default from .env):**
- **Administrator Username:** `dgermano`
- **Administrator Password:** Located in `secrets/wordpress_admin_password`

**Additional user (contributor role):**
- **Username:** `user`
- **Password:** Located in `secrets/credentials.txt`

### Accessing from Another Machine

To access the website from another computer on the network:

1. Find the server's IP address:
   ```bash
   hostname -I
   ```

2. On the client machine, add the following to `/etc/hosts`:
   ```
   <server_ip> dgermano.42.fr
   ```

3. Access https://dgermano.42.fr from the client browser

## Managing Credentials

### Credential Storage

All sensitive credentials are stored in the `secrets/` directory at the project root:

```
secrets/
├── mysql_password          # MariaDB user password
├── mysql_root_password     # MariaDB root password
├── wordpress_password      # WordPress contributor user password
└── wordpress_admin_password # WordPress admin password
```

**Security notes:**
- These files are mounted as Docker secrets in `/run/secrets/` inside containers
- They are never stored in environment variables
- They should never be committed to version control (add `secrets/` to `.gitignore`)

### Viewing Credentials

**To view a password:**
```bash
cat secrets/mysql_password
```

**To view all credentials (for administrative purposes):**
```bash
echo "=== MariaDB Root Password ===" && cat secrets/db_root_password.txt && \
echo -e "\n=== MariaDB User Password ===" && cat secrets/db_password.txt && \
echo -e "\n=== WordPress Admin Password ===" && cat secrets/wordpress_admin_password && \
echo -e "\n=== WordPress User Password ===" && cat secrets/credentials.txt
```

### Changing Credentials

**Important:** Changing credentials after initial setup requires additional steps.

**To change WordPress admin password:**
1. Log in to WordPress admin panel
2. Go to Users → Your Profile
3. Scroll to "Account Management" → "New Password"
4. Update the password and save
5. Update `secrets/wordpress_admin_password` to match

**To change database passwords:**
```bash
# 1. Stop all services
make down

# 2. Update the secret file
echo "new_password" > secrets/db_password.txt

# 3. Clean the database volume
make fclean

# 4. Restart everything (will reinitialize)
make
```

### Non-sensitive Configuration

Edit `srcs/.env` for non-sensitive settings:
```bash
nano srcs/.env
### Quick Status Check

**Check all containers (expect 8):**
```bash
docker ps
docker ps | wc -l  # Should show 9 (8 containers + header)
```

**Test main services:**
```bash
# WordPress
curl -k https://dgermano.42.fr

# Redis cache
docker exec redis redis-cli ping  # Should return: PONG
### Detailed Service Checks

**NGINX:**
```bash
docker logs nginx
docker exec nginx nginx -t
```

**WordPress & Redis:**
```bash
docker logs wordpress
docker exec wordpress wp --allow-root --path=/var/www/html core version
docker exec wordpress wp --allow-root --path=/var/www/html redis status
```

**MariaDB:**
```bash
docker logs mariadb
docker exec mariadb mysql -u root -p$(cat secrets/db_root_password.txt) -e "SHOW DATABASES;"
```

**Bonus Services:**
```bash
docker logs redis
docker logs ftp
docker logs adminer
docker logs static-site
docker logs portainer
```

> **Comprehensive testing:** See [TESTING.md](TESTING.md) for detailed verification commands.ected output:
```
CONTAINER ID   IMAGE       STATUS          PORTS                  NAMES
xxxxxxxxxxxx   nginx       Up 2 minutes    0.0.0.0:443->443/tcp   nginx
xxxxxxxxxxxx   wordpress   Up 2 minutes    9000/tcp               wordpress
xxxxxxxxxxxx   mariadb     Up 2 minutes    3306/tcp               mariadb
```

### Detailed Service Checks

**Check NGINX:**
```bash
docker ps | grep nginx
docker logs nginx
curl -k https://dgermano.42.fr
```

**Check WordPress/PHP-FPM:**
```bash
docker ps | grep wordpress
docker logs wordpress
```

**Check MariaDB:**
```bash
docker ps | grep mariadb
docker logs mariadb
docker exec mariadb mysqladmin -u root -p$(cat secrets/db_root_password.txt) ping
```

### Viewing Service Logs

**View live logs for a service:**
```bash
docker logs -f <container_name>
```

**View last 50 lines of logs:**
```bash
docker logs --tail 50 <container_name>
```

**View logs for all services:**
```bash
docker-compose -f srcs/docker-compose.yml logs
```

### Testing Connectivity

**Test NGINX SSL certificate:**
```bash
openssl s_client -connect dgermano.42.fr:443 -servername dgermano.42.fr
```

**Test MariaDB connection from WordPress container:**
```bash
docker exec wordpress mysql -h mariadb -u wpuser -p$(cat secrets/db_password.txt) -e "SHOW DATABASES;"
```

**Test WordPress installation:**
```bash
docker exec wordpress wp --allow-root --path=/var/www/html core version
```

### Common Issues and Solutions

**Issue:** Website not accessible
```bash
# Check if NGINX is running
docker ps | grep nginx
# Check NGINX logs
docker logs nginx
# Check if port 443 is listening
sudo ss -tlnp | grep 443
```

**Issue:** WordPress shows database connection error
```bash
# Check if MariaDB is running
docker ps | grep mariadb
# Check if WordPress can reach MariaDB
docker exec wordpress ping -c 3 mariadb
# Check database credentials in WordPress container
docker exec wordpress cat /var/www/html/wp-config.php | grep DB_
```

**Issue:** Changes not appearing on website
```bash
# Clear browser cache or try incognito/private mode
# Restart NGINX
docker restart nginx
```

### Resource Usage Monitoring

**Check container resource usage:**
```bash
docker stats
```

**Check disk usage by volumes:**
```bash
docker system df -v
```

**Check data directory sizes:**
```bash
du -sh /home/$USER/data/mariadb
du -sh /home/$USER/data/wordpress
```

## Backup and Maintenance

### Backing Up Data

**Backup WordPress files:**
```bash
sudo tar -czf wordpress_backup_$(date +%Y%m%d).tar.gz /home/$USER/data/wordpress
```

**Backup MariaDB database:**
```bash
docker exec mariadb mysqldump -u root -p$(cat secrets/db_root_password.txt) wordpress > wordpress_db_backup_$(date +%Y%m%d).sql
```

**Backup both data directories:**
```bash
sudo tar -czf inception_full_backup_$(date +%Y%m%d).tar.gz /home/$USER/data
```

### Restoring from Backup

**Restore WordPress files:**
```bash
make down
sudo rm -rf /home/$USER/data/wordpress/*
sudo tar -xzf wordpress_backup_YYYYMMDD.tar.gz -C /
make up
```

**Restore MariaDB database:**
```bash
cat wordpress_db_backup_YYYYMMDD.sql | docker exec -i mariadb mysql -u root -p$(cat secrets/db_root_password.txt) wordpress
```

## Troubleshooting

### Container Won't Start
```bash
# View error logs
docker logs <container_name>

# Check for port conflicts
sudo ss -tlnp | grep 443

# Verify file permissions
ls -la /home/$USER/data/
```

### Permission Errors
```bash
# Fix data directory permissions
sudo chown -R $USER:$USER /home/$USER/data

# Inside containers, check ownership
docker exec mariadb ls -la /var/lib/mysql
docker exec wordpress ls -la /var/www/html
```

### "No such file or directory" Errors
```bash
# Ensure data directories exist
sudo mkdir -p /home/$USER/data/mariadb
sudo mkdir -p /home/$USER/data/wordpress
```

For additional help, consult the main README.md or DEV_DOC.md files.
