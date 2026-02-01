# Asphyxia Docker for ARMv7 (Raspberry Pi)

A production-ready Docker setup for Asphyxia CORE, optimized for Raspberry Pi (ARMv7) and Portainer usage.

## Features
- **ARMv7 Native**: Uses `debian:bullseye-slim` for maximum compatibility with Raspberry Pi.
- **Persistence**: All data (config, plugins, profiles) is stored in a single volume (`/data`).
- **Auto-Setup**: Automatically populates default config and plugins on first run.
- **Robust**: binary runs directly from the persistence layer to prevent pathfinding errors.

## Deployment Instructions

### Option 1: Portainer (Recommended)

Since Portainer cannot build from local files easily, you must build the image locally and push it to Docker Hub, or use a pre-built image.

**1. Build & Push (Run on your PC)**
```powershell
# Login to Docker Hub first
docker login

# Build for ARMv7 and push
docker buildx build --platform linux/arm/v7 -t kaanreal/asphyxia:latest --push .
```

**2. Deploy Stack (On Portainer)**
Create a new stack with the following configuration:

```yaml
version: "3.8"

services:
  asphyxia:
    image: kaanreal/asphyxia:latest
    container_name: asphyxia
    restart: unless-stopped
    ports:
      - "8083:8083"
    volumes:
      # adjust host path as needed
      - /home/pi/asphyxia-data:/data
    environment:
      - TZ=Europe/Amsterdam
```

### Option 2: Docker CLI

If you have the files on your Pi, you can run directly:

```bash
docker-compose up -d --build
```

## Directory Structure (On Host)
Once running, your mapped folder (e.g., `/home/pi/asphyxia-data`) will contain:

| File/Folder | Description |
|---|---|
| `config.ini` | Main server configuration. Edit this file to change settings. |
| `plugins/` | Place custom plugins here. |
| `savedata/` | User profiles and score data. Backup this folder! |
| `savedata.db`| Main database file (SQLite). |
| `asphyxia-core` | The server binary (do not modify). |

## Troubleshooting
- **Permission Errors?** The container attempts to fix permissions automatically (`chmod 777`), but you can manually run `sudo chown -R $USER:$USER ./asphyxia-data` if you cannot edit files on the host.
