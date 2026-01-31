FROM --platform=linux/arm/v7 debian:bookworm-slim

WORKDIR /app

# Install dependencies
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

# 2. Plugin Extraction with Debugging
# We list files (ls -la) so you can see exactly what folder was created if it fails.
RUN wget --no-check-certificate https://github.com/asphyxia-core/plugins/archive/refs/heads/stable.zip && \
    unzip stable.zip && \
    ls -la && \
    find . -maxdepth 1 -type d -name "plugins-*" -exec mv {} plugins_default \; && \
    mkdir -p plugins && \
    rm stable.zip

COPY bootstrap.sh .
RUN chmod +x bootstrap.sh

RUN mkdir -p /app/data

EXPOSE 8083 5700

ENTRYPOINT ["./bootstrap.sh"]