FROM --platform=linux/arm/v7 debian:bookworm-slim

WORKDIR /app

# Install dependencies including ca-certificates
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    ca-certificates \
    libatomic1 \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# 1. Download Asphyxia Core
RUN wget --no-check-certificate https://github.com/asphyxia-core/core/releases/download/v1.60a/asphyxia-core-armv7.zip && \
    unzip asphyxia-core-armv7.zip && \
    rm asphyxia-core-armv7.zip && \
    chmod +x asphyxia-core-armv7

# 2. Robust Plugin Extraction
# We unzip, then move whatever folder starts with 'plugins-' to 'plugins_default'
RUN wget --no-check-certificate https://github.com/asphyxia-core/plugins/archive/refs/heads/stable.zip && \
    unzip stable.zip && \
    mv plugins-* plugins_default && \
    mkdir plugins && \
    rm stable.zip

COPY bootstrap.sh .
RUN chmod +x bootstrap.sh

RUN mkdir -p /app/data

EXPOSE 8083 5700

ENTRYPOINT ["./bootstrap.sh"]