FROM arm32v7/debian:bullseye-slim
LABEL maintainer="kaanreal"

ENV ASPHYXIA_VERSION=1.60a
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/local/share

COPY bootstrap.sh .

# Install dependencies (wget, unzip, libstdc++) and setup Asphyxia
RUN apt-get update && \
    apt-get install -y wget unzip libstdc++6 ca-certificates && \
    wget https://github.com/asphyxia-core/core/releases/download/v${ASPHYXIA_VERSION}/asphyxia-core-armv7.zip && \
    wget https://github.com/asphyxia-core/plugins/archive/refs/heads/stable.zip -O plugins-stable.zip && \
    mkdir -p ./asphyxia && \
    unzip asphyxia-core-armv7.zip -d ./asphyxia && \
    unzip plugins-stable.zip -d ./ && \
    mkdir -p ./asphyxia/plugins_default && \
    cp -r plugins-stable/* ./asphyxia/plugins_default/ 2>/dev/null || true && \
    cp ./asphyxia/config.ini ./asphyxia/config_default.ini 2>/dev/null || true && \
    rm -f *.zip && \
    rm -rf plugins-stable && \
    sed -i 's/\r$//' bootstrap.sh && \
    chmod +x bootstrap.sh && \
    chmod -R 777 ./asphyxia && \
    mkdir -p /data && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

VOLUME /data
EXPOSE 8083

CMD ["/usr/local/share/bootstrap.sh"]
