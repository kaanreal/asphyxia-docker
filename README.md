# Asphyxia Docker for ARMv7 (Raspberry Pi)
# https://hub.docker.com/r/kaanreal/asphyxia
A production-ready Docker setup for Asphyxia CORE, optimized for Raspberry Pi (ARMv7) and Portainer usage.

## Features
- **ARMv7 Native**: Uses `debian:bullseye-slim` for maximum compatibility with Raspberry Pi 3/4.
- **Single-Volume Persistence**: All data (config, plugins, profiles, and the binary) is stored in `/data`.
- **Auto-Provisioning**: Automatically populates default configurations and plugins on the first boot.
- **Portainer Optimized**: Designed to work seamlessly with Portainer Stacks using absolute paths.

## Deployment

### 1. Build for ARMv7
If you are building on a standard PC (x86) to run on a Pi, use `buildx`:

```bash
# Login first
docker login

# Build and Push
docker buildx build --platform linux/arm/v7 -t USERNAME/asphyxia:latest --push .
```
*(Replace `kaanreal` with your Docker Hub username if needed)*

### 2. Portainer / Docker Compose
Use this stack configuration. **Note:** Ensure the host path exists or Docker will create it as root.

```yaml
services:
  asphyxia:
    image: kaanreal/asphyxia:latest
    container_name: asphyxia
    restart: unless-stopped
    ports:
      - "8083:8083"
    volumes:
      # Change /home/pi/asphyxia-data to your preferred local path
      - /home/pi/asphyxia-data:/data
    environment:
      - TZ=Europe/Amsterdam
```

## Directory Structure
Once initialized, your `/data` folder will be populated as follows:

| File/Folder | Purpose |
|---|---|
| `config.ini` | Main server settings. |
| `plugins/` | Drop your `.js` plugins here. |
| `savedata/` | Local save files and user profiles. |
| `asphyxia-core` | The executable (stored in volume for easy updates). |

## ⚠️ A Note on Permissions
If the container fails to start due to "Permission Denied," run the following on your Raspberry Pi:

```bash
sudo chown -R 1000:1000 /home/pi/asphyxia-data
```
