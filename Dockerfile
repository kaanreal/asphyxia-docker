# Force the platform to ARMv7 for Raspberry Pi 2/3 compatibility
FROM --platform=linux/arm/v7 debian:bookworm-slim

# Install required system dependencies for Asphyxia
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    libatomic1 \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. Download Asphyxia Core v1.60a ARMv7 binary
RUN wget https://github.com/asphyxia-core/core/releases/download/v1.60a/asphyxia-core-armv7.zip && \
    unzip asphyxia-core-armv7.zip && \
    rm asphyxia-core-armv7.zip && \
    chmod +x asphyxia-core-armv7

# 2. Download and prepare the Official Plugins (backup for first-run sync)
RUN wget https://github.com/asphyxia-core/plugins/archive/refs/heads/master.zip && \
    unzip master.zip && \
    mkdir -p /app/plugins_backup && \
    cp -r plugins-master/* /app/plugins_backup/ && \
    rm -rf master.zip plugins-master

# 3. Add the entrypoint script and set permissions
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# WebUI and Game Data ports
EXPOSE 8083 5700

ENTRYPOINT ["./entrypoint.sh"]