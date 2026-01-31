FROM arm32v7/alpine:latest
LABEL maintainer="kaanreal"

ENV ASPHYXIA_VERSION=1.60a

WORKDIR /usr/local/share

COPY bootstrap.sh .

RUN apk add --no-cache gcompat libgcc libstdc++ && \
    wget https://github.com/asphyxia-core/core/releases/download/v${ASPHYXIA_VERSION}/asphyxia-core-armv7.zip && \
    wget https://github.com/asphyxia-core/plugins/archive/refs/heads/stable.zip -O plugins-stable.zip && \
    mkdir -p ./asphyxia && \
    unzip asphyxia-core-armv7.zip -d ./asphyxia && \
    unzip plugins-stable.zip -d ./ && \
    mkdir -p ./asphyxia/plugins_default && \
    cp -r plugins-stable/* ./asphyxia/plugins_default/ 2>/dev/null || true && \
    # Save a copy of the default config
    cp ./asphyxia/config.ini ./asphyxia/config_default.ini 2>/dev/null || true && \
    rm -f *.zip && \
    rm -rf plugins-stable && \
    chmod -R 774 ./asphyxia && \
    chmod +x ./bootstrap.sh && \
    mkdir -p /data

VOLUME /data

EXPOSE 8083

CMD ["/usr/local/share/bootstrap.sh"]
