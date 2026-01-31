# Asphyxia Docker (ARMv7 / Raspberry Pi)

This is a Docker setup for Asphyxia CORE, optimized for ARMv7 devices (like Raspberry Pi) and designed to work easily with Portainer.

## Features
- **ARMv7 Support**: Downloads the correct binary for Raspberry Pi.
- **Persistent Data**: All important data (config, plugins, savedata) is stored in a single `/data` volume.
- **Auto-Setup**: If your data volume is empty, it automatically populates it with default config and plugins.

## Quick Start (CLI)

1.  Build and run:
    ```bash
    docker-compose up -d --build
    ```
2.  Your data will appear in the `./asphyxia-data` folder on your host.

## Portainer Setup

1.  Go to **Stacks** > **Add stack**.
2.  Name it `asphyxia`.
3.  Paste the contents of `docker-compose.yml` into the Web editor.
    *   **Important**: You cannot "Build" from a local path in Portainer unless you use a git repository.
    *   **Option A (Git)**: Connect this repository to Portainer.
    *   **Option B (Image)**: Build the image locally first (`docker build -t asphyxia-armv7 .`) and change `build: .` to `image: asphyxia-armv7` in the compose file.

### Recommended Portainer Volume Path
In the `docker-compose.yml`, change the volume path to where you want files on your Pi:

```yaml
    volumes:
      - /home/pi/asphyxia-data:/data
```

## Directory Structure
After the first run, your host directory (e.g., `/home/pi/asphyxia-data`) will contain:

*   `config.ini` - Main configuration file.
*   `plugins/` - Put your plugins here.
*   `savedata/` - Player save data is stored here.

## Troubleshooting
- **Permissions**: If files are created as `root`, run `sudo chown -R $USER:$USER ./asphyxia-data` on your host to edit them.
