# Asphyxia Docker (ARMv7 / Raspberry Pi)

## 1. Build & Push (Required for Portainer)
Portainer cannot build images from local files on the host (unless you use Git). You must build the image on your PC and push it to Docker Hub.

Run this command in the project folder:
```powershell
docker buildx build --platform linux/arm/v7 -t kaanreal/asphyxia:latest --push .
```
*(Make sure you are logged in with `docker login` first)*

## 2. Deploy on Portainer (Raspberry Pi)
1.  Go to **Stacks** -> **Add stack**.
2.  Name: `asphyxia`
3.  Paste the contents of `docker-compose.yml`:
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
          # Use absolute path on the Pi
          - /home/pi/asphyxia-data:/data
        environment:
          - TZ=Europe/Amsterdam
    ```
4.  Click **Deploy the stack**.

## 3. Manage Files
The first time it runs, it will populate `/home/pi/asphyxia-data` with:
- `config.ini`
- `plugins/`
- `savedata/`

You can edit `config.ini` or add plugins directly in that folder on your Pi.
