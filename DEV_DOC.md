# Developer Documentation

## Overview

Technical documentation for developers to understand, modify, and extend the Inception infrastructure.

## Quick Setup

### Prerequisites
- Linux (Debian/Ubuntu)
- Docker Engine 20.10+
- Docker Compose 2.0+
- Make, Git

**Install Docker:**
```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER
```

### Project Structure

```
Inception/
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── wordpress_admin_password
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── bonus/
        │   ├── adminer/
        │   ├── ftp/
        │   ├── portainer/
        │   ├── redis/
        │   └── static-site/
        ├── mariadb/
        ├── nginx/
        ├── tools/
        └── wordpress/
```

### Initial Setup

**1. Configure secrets:**
```bash
mkdir -p secrets
openssl rand -base64 16 > secrets/db_root_password.txt
openssl rand -base64 16 > secrets/db_password.txt
openssl rand -base64 16 > secrets/credentials.txt
openssl rand -base64 16 > secrets/wordpress_admin_password
chmod 600 secrets/*
```

**2. Configure .env:**
```bash
nano srcs/.env
# Update: DOMAIN_NAME, emails, FTP credentials
```

**3. Setup:**
```bash
echo "127.0.0.1 dgermano.42.fr" | sudo tee -a /etc/hosts
echo -e "secrets/\nsrcs/.env\n*.log" > .gitignore
```

**4. Build and run:**
```bash
make
```

## Build & Deploy

### Makefile Commands
```bash
make           # Build and start all services
make down      # Stop services
make clean     # Remove images
make fclean    # Full cleanup (volumes + data)
make re        # Rebuild from scratch
```

### Docker Compose
```bash
docker compose -f srcs/docker-compose.yml build [service]
docker compose -f srcs/docker-compose.yml up -d [service]
docker compose -f srcs/docker-compose.yml logs -f [service]
```

## Container Management

### Essential Commands
```bash
# Inspect
docker ps                                    # List containers
docker logs [-f] <container>                 # View logs
docker exec -it <container> /bin/bash       # Shell access
docker inspect <container>                   # Details
docker stats                                 # Resource usage

# Control
docker start/stop/restart <container>
docker rm [-f] <container>

# Execute commands
docker exec <container> <command>
docker exec mariadb mysql -u root -p$(cat secrets/mysql_root_password) -e "SHOW DATABASES;"
docker exec wordpress wp --allow-root --path=/var/www/html core version
docker exec nginx nginx -t
```

## Volume & Network Management

### Volumes
```bash
docker volume ls                             # List volumes
docker volume inspect <volume>               # Details
docker system df -v                          # Disk usage

# Data locations
ls -la /home/$USER/data/mariadb              # MariaDB data
ls -la /home/$USER/data/wordpress            # WordPress files

# Backup/Restore
docker run --rm -v mariadb_data:/source -v $(pwd):/backup alpine tar -czf /backup/db.tar.gz -C /source .
docker run --rm -v mariadb_data:/target -v $(pwd):/backup alpine sh -c "cd /target && tar -xzf /backup/db.tar.gz"
```

### Networks
```bash
docker network ls                            # List networks
docker network inspect nginx_vol             # Details
docker exec wordpress ping -c 2 mariadb      # Test connectivity
docker exec wordpress nslookup mariadb       # DNS resolution
```

## Development Workflow

**1. Modify configuration:**
```bash
nano srcs/nginx/conf/nginx.conf
```

**2. Rebuild service:**
```bash
docker compose -f srcs/docker-compose.yml build nginx
docker compose -f srcs/docker-compose.yml up -d --force-recreate nginx
```

**3. Check logs:**
```bash
docker logs -f nginx
```

**Test configurations:**
```bash
docker exec nginx nginx -t                   # NGINX syntax
docker exec wordpress php-fpm8.2 -t          # PHP-FPM
docker exec wordpress mysql -h mariadb -u wpuser -p$(cat secrets/db_password.txt) -e "SELECT 1;"
```

## Data Persistence

**MariaDB:** `/var/lib/mysql` → `/home/$USER/data/mariadb`
**WordPress:** `/var/www/html` → `/home/$USER/data/wordpress`
**Secrets:** `/run/secrets/` (in-memory, from `secrets/` directory)

**Lifecycle:**
1. First run: Directories created, services initialized
2. Restart: Existing data detected and reused
3. `make fclean`: All data removed, next run is fresh install

## Service Details

### MariaDB
**Files:** `srcs/requirements/mariadb/Dockerfile`, `conf/50-server.cnf`, `tools/script.sh`
```bash
docker exec mariadb mysql -u root -p$(cat secrets/db_root_password.txt) -e "SHOW DATABASES;"
docker exec mariadb mysqldump -u root -p$(cat secrets/db_root_password.txt) wordpress > backup.sql
```

### WordPress
**Files:** `srcs/requirements/wordpress/Dockerfile`, `conf/www.conf`, `tools/script.sh`
```bash
docker exec wordpress wp --allow-root --path=/var/www/html core version
docker exec wordpress wp --allow-root --path=/var/www/html user list
docker exec wordpress wp --allow-root --path=/var/www/html redis status
```

### NGINX
**Files:** `srcs/requirements/nginx/Dockerfile`, `conf/nginx.conf`
```bash
docker exec nginx nginx -t
docker exec nginx nginx -s reload
openssl s_client -connect dgermano.42.fr:443 -servername dgermano.42.fr
```

### Bonus Services
```bash
# Redis
docker exec redis redis-cli ping
docker exec redis redis-cli info stats

# FTP
ftp -p localhost 21

# Adminer: https://dgermano.42.fr/adminer
# Static: http://localhost:8080
# Portainer: https://localhost:9443
```

> **Detailed bonus info:** [BONUS_DOC.md](BONUS_DOC.md)

## Resources

- [Docker Docs](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [NGINX Docs](https://nginx.org/en/docs/)
- [MariaDB KB](https://mariadb.com/kb/)
- [WP-CLI](https://developer.wordpress.org/cli/)
- [Redis Docs](https://redis.io/docs/)

**Project Documentation:**
- [README.md](README.md) - Overview and comparisons
- [USER_DOC.md](USER_DOC.md) - User guide
- [BONUS_DOC.md](BONUS_DOC.md) - Bonus services
- [TESTING.md](TESTING.md) - Testing commands
- [DEFENSE.md](DEFENSE.md) - Defense prep
