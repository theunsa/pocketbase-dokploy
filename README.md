# PocketBase Docker for Dokploy

Docker setup for deploying [PocketBase](https://pocketbase.io) to [Dokploy](https://dokploy.com) with persistent storage.

## Features

- 🐳 Docker Compose configuration optimized for Dokploy
- 💾 Persistent volumes for data, migrations, and public files
- 🔄 Fresh hooks deployment with each build
- 🔒 Traefik-ready (no port mapping needed)
- 📦 Configurable PocketBase version

## Prerequisites

- Dokploy instance running on your VPS
- SSH access to your VPS

## Setup

### 1. Prepare Host Directories

SSH into your VPS and create the required directories:

```bash
mkdir -p /opt/pocketbase/{data,migrations,public}
```

### 2. Deploy to Dokploy

1. In Dokploy UI, create a new **Docker Compose** application
2. Point it to this repository
3. Dokploy will automatically detect the `docker-compose.yml`
4. Deploy the application

### 3. Configure Domain

In Dokploy UI (v0.7.0+):
- Go to your application settings
- Add your domain under the Domains section
- Set **Container Port** to `8090`
- Dokploy/Traefik will handle SSL automatically

## Project Structure

```
.
├── Dockerfile              # PocketBase container definition
├── docker-compose.yml      # Dokploy-compatible compose file
└── .dockerignore          # Build optimization
```

## Persistent Storage

- `/opt/pocketbase/data` → Database and application data
- `/opt/pocketbase/migrations` → Database migrations
- `/opt/pocketbase/public` → Static files and uploads
- `pb_hooks` → Deployed fresh from repository (not persisted)

## Configuration

### Change PocketBase Version

Edit `docker-compose.yml`:

```yaml
args:
  PB_VERSION: 0.30.0  # Change version here
```

### Add Custom Hooks

1. Create `pb_hooks` directory in your repository
2. Add your hooks (Go or JavaScript)
3. Uncomment the COPY line in `Dockerfile`:

```dockerfile
COPY ./pb_hooks /pb/pb_hooks
```

## Environment Variables

### Superuser Account (Required)

Set these environment variables in Dokploy UI to automatically create a superuser on first deployment:

- `SUPERUSER_EMAIL` - Email for the admin account
- `SUPERUSER_PASSWORD` - Password for the admin account

In Dokploy UI:
1. Go to your application → **Environment** tab
2. Add the variables:
   ```
   SUPERUSER_EMAIL=admin@example.com
   SUPERUSER_PASSWORD=your-secure-password
   ```
3. Redeploy the application

### Additional Configuration

PocketBase can be configured via environment variables. Add to `docker-compose.yml` or Dokploy UI:

```yaml
environment:
  - PB_ENCRYPTION_KEY=your-encryption-key
```

See [PocketBase docs](https://pocketbase.io/docs/going-to-production/) for available options.

## Backup

### Automated Cloudflare R2 Backups

This setup includes automatic backups to Cloudflare R2 using rclone.

#### Setup R2 Backups

1. **Create R2 bucket** in Cloudflare dashboard

2. **Generate R2 API tokens:**
   - Go to Cloudflare Dashboard → R2 → Manage R2 API Tokens
   - Create API token with read/write permissions
   - Note down: Account ID, Access Key ID, Secret Access Key

3. **Configure in Dokploy:**
   - Go to your application → **Environment** tab
   - Add R2 credentials:
   ```
   R2_ACCOUNT_ID=your-account-id
   R2_ACCESS_KEY_ID=your-access-key-id
   R2_SECRET_ACCESS_KEY=your-secret-access-key
   R2_BUCKET_NAME=your-bucket-name
   ```

4. **Create scheduled backup in Dokploy:**
   - Go to **Schedules** tab → **Create Schedule**
   - Service Name: `pocketbase`
   - Task Name: `Daily R2 Backup`
   - Schedule: `0 2 * * *` (daily at 2 AM)
   - Shell Type: `Bash`
   - Command: `/usr/local/bin/backup-r2.sh`
   - Enable the schedule

Backups are stored in your R2 bucket at: `pocketbase-backups/YYYY-MM-DD_HH-MM-SS/`

### Manual Local Backup

Backup the persistent directories on your VPS:

```bash
tar -czf pocketbase-backup-$(date +%Y%m%d).tar.gz /opt/pocketbase/
```

## License

MIT

## Resources

- [PocketBase Documentation](https://pocketbase.io/docs/)
- [Dokploy Documentation](https://docs.dokploy.com/)
