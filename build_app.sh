#!/bin/bash

# Configurações
APP_NAME="CMD Switch"
BUNDLE_ID="com.rfl.cmdswitch"
VERSION="1.0.0"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Limpa diretório de build anterior
rm -rf "$BUILD_DIR"

# Cria estrutura de diretórios
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Compila o projeto
swift build -c release

# Copia o executável
cp ".build/release/quickswitch" "$MACOS_DIR/$APP_NAME"

# Copia o ícone
cp "Sources/quickswitch/Resources/AppIcon.icns" "$RESOURCES_DIR/"

# Cria Info.plist
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>SMLoginItemEnabled</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

# Dá permissão de execução
chmod +x "$MACOS_DIR/$APP_NAME"

echo "Aplicativo criado em $APP_DIR"
echo "Para instalar, copie $APP_NAME.app para a pasta Applications"
