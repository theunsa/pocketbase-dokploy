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

PocketBase can be configured via environment variables. Add to `docker-compose.yml`:

```yaml
environment:
  - PB_ENCRYPTION_KEY=your-encryption-key
```

See [PocketBase docs](https://pocketbase.io/docs/going-to-production/) for available options.

## Backup

Backup the persistent directories on your VPS:

```bash
tar -czf pocketbase-backup-$(date +%Y%m%d).tar.gz /opt/pocketbase/
```

## License

MIT

## Resources

- [PocketBase Documentation](https://pocketbase.io/docs/)
- [Dokploy Documentation](https://docs.dokploy.com/)
