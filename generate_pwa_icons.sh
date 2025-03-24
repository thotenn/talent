#!/bin/bash
# Este script genera los íconos PWA necesarios a partir de una imagen de origen.
# Requisitos: ImageMagick debe estar instalado
# Uso: ./generate_pwa_icons.sh logo.png

SOURCE=$1
OUTPUT_DIR="priv/static/images/icons"
SIZES=(72 96 128 144 152 192 384 512)

if [ -z "$SOURCE" ]; then
  echo "Error: Debes especificar un archivo de imagen de origen."
  echo "Uso: $0 path/to/your/logo.png"
  exit 1
fi

if ! command -v convert &> /dev/null; then
  echo "Error: ImageMagick no está instalado. Por favor, instálalo primero."
  echo "Ubuntu/Debian: sudo apt-get install imagemagick"
  echo "macOS: brew install imagemagick"
  exit 1
fi

# Crear directorio de salida si no existe
mkdir -p "$OUTPUT_DIR"

# Generar íconos en diferentes tamaños
for size in "${SIZES[@]}"; do
  echo "Generando icono de ${size}x${size}..."
  convert "$SOURCE" -resize "${size}x${size}" "$OUTPUT_DIR/icon-${size}x${size}.png"
done

# Generar una versión maskable para Android
echo "Generando icono maskable..."
convert "$SOURCE" -resize "512x512" -background white -gravity center -extent 704x704 "$OUTPUT_DIR/maskable-icon.png"

echo "Íconos PWA generados con éxito en $OUTPUT_DIR"
echo "Recuerda asegurarte de que manifest.json apunta correctamente a estos íconos."