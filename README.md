# Inception

*This project has been created as part of the 42 curriculum by dgermano.*

## Description

Inception is a system administration project focused on containerization and infrastructure deployment. The goal is to set up a complete web application stack using Docker, where each service runs in its own isolated container with custom-built images from Debian Bookworm.

The infrastructure consists of:
- **NGINX** - Web server with SSL/TLS (TLSv1.2/1.3) termination
- **WordPress** - Content management system with PHP-FPM 8.2
- **MariaDB** - Database server for persistent data storage
- **Bonus services** - Redis cache, FTP server, Adminer, static website, and Portainer

All services are orchestrated using Docker Compose, implementing security best practices (Docker secrets), isolated networking, and persistent storage with volumes.

### Bonus Services:
- **Redis** cache for WordPress performance optimization
- **FTP server** (vsftpd) for WordPress file management
- **Static website** (portfolio/resume) built with HTML/CSS/JS
- **Adminer** for database administration
- **Portainer** for Docker container management and monitoring

> **Note:** For detailed information about bonus services, see [BONUS_DOC.md](BONUS_DOC.md)

## Instructions

### Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+
- Linux OS (Debian/Ubuntu)
- Make utility

### Quick Start

1. **Clone and configure:**
   ```bash
   git clone <repository-url> && cd Inception
   
   # Create secrets
   mkdir -p secrets
   openssl rand -base64 16 > secrets/mysql_password
   openssl rand -base64 16 > secrets/mysql_root_password
   openssl rand -base64 16 > secrets/wordpress_password
   openssl rand -base64 16 > secrets/wordpress_admin_password
   
   # Configure environment (edit as needed)
   nano srcs/.env
   
   # Add domain to hosts file
   echo "127.0.0.1 dgermano.42.fr" | sudo tee -a /etc/hosts
   ```

2. **Build and start:**
   ```bash
   make
   ```

3. **Access services:**
   - WordPress: https://dgermano.42.fr
   - WordPress Admin: https://dgermano.42.fr/wp-admin
   - Adminer: https://dgermano.42.fr/adminer
   - Static Site: http://localhost:8080
   - Portainer: https://localhost:9443
   - FTP: ftp://dgermano.42.fr

### Management Commands
```bash
make up      # Start all services
make down    # Stop all services
make clean   # Stop and remove images
make fclean  # Full cleanup (removes volumes and data)
make re      # Rebuild everything from scratch
```

**For detailed instructions**, see [USER_DOC.md](USER_DOC.md) (end users) and [DEV_DOC.md](DEV_DOC.md) (developers).

## Project Description

### Docker Architecture

This project uses **Docker** to create isolated, portable service environments. Each component runs in a dedicated container built from Debian Bookworm base images, ensuring reproducibility and ease of deployment.

**Key Design Choices:**

1. **Microservices Separation** - Each service (NGINX, WordPress, MariaDB) runs independently, allowing for:
   - Isolated failures (one service crash doesn't affect others)
   - Independent scaling and updates
   - Clear separation of concerns

2. **Custom Images** - All Dockerfiles built from scratch (no Docker Hub pre-built images) to:
   - Maintain full control over dependencies
   - Ensure security through minimal installations
   - Meet project requirements for custom builds

3. **Orchestration** - Docker Compose manages service dependencies, networks, and volumes:
   - Automatic startup order (`depends_on`)
   - Centralized configuration
   - Single-command deployment

4. **Network Isolation** - Two bridge networks (`nginx_vol` and `wp_db`) provide:
   - Service discovery via DNS (e.g., `wordpress:9000`)
   - Segmented communication (database isolated from web traffic)
   - Enhanced security through network boundaries

5. **Security Implementation**:
   - Docker secrets for credentials (encrypted, not in env vars)
   - TLS/SSL with self-signed certificates
   - Minimal exposed ports (only 443, 8080, 9443, 21)

**Bonus Services:**
- **Redis** - In-memory caching reduces database load by ~90%
- **FTP** - File management with vsftpd pointing to WordPress volume
- **Static Site** - Pure HTML/CSS/JS portfolio (no PHP)
- **Adminer** - Lightweight database management interface
- **Portainer** - Visual container monitoring and management

### Technical Comparisons

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|-----------------|-------------------|
| **Architecture** | Full OS with hypervisor | Shared kernel, isolated processes |
| **Size** | GBs (complete OS) | MBs (app + dependencies) |
| **Startup** | Minutes | Seconds |
| **Performance** | Overhead from virtualization | Near-native speed |
| **Resource Usage** | High (dedicated RAM/CPU per VM) | Low (shared resources) |
| **Isolation** | Complete OS isolation | Process-level isolation |
| **Portability** | Limited (large VM images) | High (layered, cacheable images) |
| **Best For** | Different OS kernels, legacy apps | Microservices, cloud-native apps |

**Why Docker for this project?** Lightweight, fast deployment, and sufficient isolation for web services without the overhead of full virtualization.

#### Secrets vs Environment Variables

| Aspect | Docker Secrets | Environment Variables |
|--------|---------------|----------------------|
| **Storage** | Encrypted at rest, in-memory in container | Plaintext in container config |
| **Visibility** | Not visible in `docker inspect` | Exposed in `docker inspect` and `env` |
| **Mount Point** | `/run/secrets/` (tmpfs, RAM only) | Container environment |
| **Security** | High - encrypted, access-controlled | Low - easily leaked in logs/errors |
| **Rotation** | Supports rotation without rebuild | Requires container recreation |
| **Best For** | Passwords, API keys, certificates | Non-sensitive config (URLs, names) |

**Why Secrets?** All passwords use Docker secrets to prevent accidental exposure through logs, process listings, or inspection commands.

#### Docker Network vs Host Network

| Aspect | Bridge Network | Host Network |
|--------|---------------|--------------|
| **Isolation** | Containers isolated in virtual network | Direct access to host network stack |
| **Port Mapping** | Explicit mapping required | Automatic access to all ports |
| **DNS** | Built-in service discovery | Must use localhost/IPs |
| **Security** | Better (network boundaries) | Lower (full host access) |
| **Performance** | Slight NAT overhead | Native performance |
| **Use Case** | Production, isolation needed | High-performance, trusted apps |

**Why Bridge Networks?** Enable service discovery by name (e.g., `mariadb:3306`), provide network isolation, and control inter-service communication.

#### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|---------------|-------------|
| **Management** | Docker-managed in `/var/lib/docker/volumes/` | User-specified host paths |
| **Portability** | Platform-independent | Requires specific host paths |
| **Permissions** | Docker handles | Host filesystem permissions |
| **Backup** | `docker volume` commands | Standard filesystem tools |
| **Performance** | Optimized for Docker | Direct filesystem I/O |
| **Best For** | Production, portability | Development, direct access |

**This project uses both:**
- **Bind mounts** for MariaDB/WordPress (`/home/$USER/data/`) - direct access for backups
- **Named volumes** for Redis/Portainer/Adminer - Docker-managed, no host path dependency

## Resources

### Core Documentation
- [Docker Official Documentation](https://docs.docker.com/) - Container fundamentals and best practices
- [Docker Compose Reference](https://docs.docker.com/compose/) - Service orchestration
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) - Image optimization

### Service-Specific
- [NGINX Documentation](https://nginx.org/en/docs/) - Web server configuration
- [WordPress CLI (WP-CLI)](https://wp-cli.org/) - WordPress automation
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/) - Database administration
- [Redis Documentation](https://redis.io/docs/) - Caching strategies

### Security
- [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/) - Credential management
- [OpenSSL Documentation](https://www.openssl.org/docs/) - SSL/TLS certificates
- [Mozilla SSL Configuration](https://ssl-config.mozilla.org/) - TLS best practices

### AI Usage Disclosure

AI tools (ChatGPT, Claude) were used in this project for the following purposes:

1. **Documentation and Research** (~5% of time saved)
   - Understanding Docker networking concepts and best practices
   - Comparing storage strategies (volumes vs bind mounts)
   - Researching security implementations (secrets, TLS protocols)
   - Structuring technical comparison tables

2. **Documentation Writing** (~12% of time saved)
   - Structuring README, USER_DOC, and DEV_DOC files
   - Formatting markdown tables and code blocks
   - Generating comprehensive testing commands
   - Creating defense preparation materials

**Important Notes:**
- All code was written, tested, and validated manually by the developer
- AI served as a reference tool, similar to Stack Overflow or documentation
- Final implementation decisions and architecture choices were made independently
- All configurations were customized to project-specific requirements
- No copy-paste without understanding - every line was analyzed and adapted

**Estimated AI Contribution:** ~25% of total project time (primarily documentation and research), with 100% of implementation and technical decisions by the developer.

## Additional Documentation

- **[USER_DOC.md](USER_DOC.md)** - Complete user guide for managing services
- **[DEV_DOC.md](DEV_DOC.md)** - Developer documentation for setup and troubleshooting
- **[BONUS_DOC.md](BONUS_DOC.md)** - Detailed bonus services documentation
- **[TESTING.md](TESTING.md)** - Testing and verification commands
- **[DEFENSE.md](DEFENSE.md)** - Defense preparation guide

---

**Project:** Inception | **Student:** dgermano | **School:** 42 | **Status:** Complete ✅
