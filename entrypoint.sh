#!/bin/sh

# Wir arbeiten im Ordner /app/data, welcher auf den Pi gemountet ist
mkdir -p /app/data/plugins /app/data/savedata

# Falls der Plugins-Ordner auf dem Pi leer ist, fülle ihn
if [ ! "$(ls -A /app/data/plugins 2>/dev/null)" ]; then
    echo "First run: Copying plugins to your Pi folder..."
    cp -r /app/plugins_backup/* /app/data/plugins/
fi

# Erstelle config.ini auf dem Pi, falls sie fehlt
if [ ! -f /app/data/config.ini ]; then
    echo "Creating config.ini on your Pi..."
    touch /app/data/config.ini
fi

# Linke alles aus /app/data zurück nach /app, damit Asphyxia es findet
ln -sf /app/data/config.ini /app/config.ini
ln -sf /app/data/plugins /app/plugins
ln -sf /app/data/savedata /app/savedata

echo "Starting Asphyxia..."
exec ./asphyxia-core-armv7