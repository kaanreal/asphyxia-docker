FROM --platform=linux/arm/v7 debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    wget unzip libatomic1 libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Download ARMv7 Core
RUN wget https://github.com/asphyxia-core/core/releases/download/v1.60a/asphyxia-core-armv7.zip && \
    unzip asphyxia-core-armv7.zip && \
    rm asphyxia-core-armv7.zip && \
    chmod +x asphyxia-core-armv7

# Download Plugins and store them in the BACKUP folder
RUN wget https://github.com/asphyxia-core/plugins/archive/refs/heads/stable.zip && \
    unzip stable.zip && \
    mkdir -p /app/plugins_backup && \
    cp -r plugins-stable/* /app/plugins_backup/ && \
    rm -rf stable.zip plugins-stable
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Create the data mount point
RUN mkdir -p /app/data

EXPOSE 8083 5700

ENTRYPOINT ["./entrypoint.sh"]