FROM --platform=linux/arm/v7 debian:bookworm-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget unzip libatomic1 libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Download Asphyxia Core v1.60a (ARMv7)
RUN wget https://github.com/asphyxia-core/core/releases/download/v1.60a/asphyxia-core-armv7.zip && \
    unzip asphyxia-core-armv7.zip && \
    rm asphyxia-core-armv7.zip && \
    chmod +x asphyxia-core-armv7

# Download Stable Plugins
RUN wget https://github.com/asphyxia-core/plugins/archive/refs/heads/stable.zip && \
    unzip stable.zip && \
    mv plugins-stable plugins_default && \
    mkdir plugins && \
    rm stable.zip

COPY bootstrap.sh .
RUN chmod +x bootstrap.sh

# Data mount point for the Raspberry Pi
RUN mkdir -p /app/data

EXPOSE 8083 5700

ENTRYPOINT ["./bootstrap.sh"]