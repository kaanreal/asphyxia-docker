# Force the platform to ARMv7
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

# Download Plugins
RUN wget https://github.com/asphyxia-core/plugins/archive/refs/heads/master.zip && \
    unzip master.zip && \
    mkdir -p /app/plugins_backup && \
    cp -r plugins-master/* /app/plugins_backup/ && \
    rm -rf master.zip plugins-master

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 8083 5700

ENTRYPOINT ["./entrypoint.sh"]