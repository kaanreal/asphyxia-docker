# Asphyxia Docker v1.60a - ARMv7

# https://hub.docker.com/r/kaanreal/asphyxia

A clean, ready-to-use Docker setup for running the Asphyxia server. This project provides a simple way to deploy Asphyxia using Docker and Docker Compose, making it easy to manage, update, and persist your data.

## Overview

Asphyxia is a private server emulator for arcade games, designed to be easy to deploy and maintain. This Docker setup automates the installation and configuration process, making it accessible for both beginners and advanced users. The container is optimized for ARMv7 devices (such as Raspberry Pi), but can be adapted for other platforms.

The server automatically downloads the latest Asphyxia core and plugins, and ensures your configuration and data are always persistent.

## Features

- Pre-configured Dockerfile for ARMv7 (Raspberry Pi and similar devices)
- Automatic download and setup of Asphyxia core and plugins
- Persistent storage for configuration, plugins, and savedata
- Easy startup and management with Docker Compose

## Sample Docker Compose Stack

Here is a sample `docker-compose.yml` for running Asphyxia:

```yaml
version: "3"
services:
    asphyxia:
        image: kaanreal/asphyxia:latest
        container_name: asphyxia
        restart: always
        ports:
            - "8083:8083"
            - "5700:5700"
        volumes:
            # Replace the path on the left with your local Pi directory
            - /home/pi/asphyxia-server:/app/data
```

## Quick Start

### 1. Clone this repository

```sh
git clone https://github.com/yourusername/asphyxia-docker.git
cd asphyxia-docker
```

### 2. Build and run with Docker Compose

```sh
docker-compose up -d
```

### 3. Access

- Asphyxia server will be available on ports **8083** and **5700**.
- Configuration, plugins, and savedata are stored in the local folders and mapped into the container.

## Folder Structure

- `config.ini` — Main configuration file (auto-created if missing)
- `plugins/` — Plugins directory (auto-populated on first run)
- `savedata/` — Persistent game/server data
- `Dockerfile` — Container build instructions
- `docker-compose.yml` — Multi-container orchestration
- `entrypoint.sh` — Startup script for container logic

## Customization

- Edit `config.ini` to configure your server.
- Add or update plugins in the `plugins/` folder.
- All changes persist across container restarts.

## Usage Notes

- On first run, the container will copy default plugins and create a `config.ini` if it does not exist.
- All data is stored in the mapped local folders, so you can back up or modify your configuration and plugins easily.
- To reset plugins to default, delete the contents of the `plugins/` folder and restart the container.

## Environment Variables

You can customize the container using environment variables in your `docker-compose.yml` (add under `environment:`):

```
environment:
	- TZ=Europe/Berlin  # Set your timezone
```

Add more variables as needed for your use case.

## Troubleshooting

- **Ports already in use:** Make sure ports 8083 and 5700 are free or change the mapping in `docker-compose.yml`.
- **Permission issues:** Ensure your local folders have the correct permissions for Docker to read/write.
- **ARM architecture errors:** This image is built for ARMv7. For other platforms, adjust the `Dockerfile` base image accordingly.

## Support

For help, open an issue on the GitHub repository or visit the Asphyxia community Discord.

---

## Updating

To update Asphyxia or plugins, rebuild the image:

```sh
docker-compose build --no-cache
```

## Requirements

- Docker
- Docker Compose
- ARMv7 device (e.g., Raspberry Pi) or compatible system

## Credits

- [Asphyxia Core](https://github.com/asphyxia-core/core)
- [Asphyxia Plugins](https://github.com/asphyxia-core/plugins)

## License

MIT License
