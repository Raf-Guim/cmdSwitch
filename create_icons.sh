#!/bin/bash

# Criar diretórios necessários
mkdir -p Sources/quickswitch/Resources
mkdir -p Sources/quickswitch/Resources/Assets.xcassets/AppIcon.appiconset
mkdir -p iconset.iconset

# Copiar o logo original
cp logo.png iconset.iconset/icon_1024x1024.png

# Gerar diferentes tamanhos do ícone usando sips
sips -z 16 16 iconset.iconset/icon_1024x1024.png --out iconset.iconset/icon_16x16.png
sips -z 32 32 iconset.iconset/icon_1024x1024.png --out iconset.iconset/icon_16x16@2x.png
sips -z 32 32 iconset.iconset/icon_1024x1024.png --out iconset.iconset/icon_32x32.png
sips -z 64 64 iconset.iconset/icon_1024x1024.png --out iconset.iconset/icon_32x32@2x.png
sips -z 128 128 iconset.iconset/icon_1024x1024.png --out iconset.iconset/icon_128x128.png
sips -z 256 256 iconset.iconset/icon_1024x1024.png --out iconset.iconset/icon_128x128@2x.png
sips -z 256 256 iconset.iconset/icon_1024x1024.png --out iconset.iconset/icon_256x256.png
sips -z 512 512 iconset.iconset/icon_1024x1024.png --out iconset.iconset/icon_256x256@2x.png
sips -z 512 512 iconset.iconset/icon_1024x1024.png --out iconset.iconset/icon_512x512.png
sips -z 1024 1024 iconset.iconset/icon_1024x1024.png --out iconset.iconset/icon_512x512@2x.png

# Gerar o arquivo .icns
iconutil -c icns iconset.iconset -o AppIcon.icns

# Copiar os arquivos para os locais corretos
cp AppIcon.icns Sources/quickswitch/Resources/
cp -r iconset.iconset/* Sources/quickswitch/Resources/Assets.xcassets/AppIcon.appiconset/

# Criar o Contents.json
cat > Sources/quickswitch/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json << 'EOL'
{
  "images" : [
    {
      "size" : "16x16",
      "idiom" : "mac",
      "filename" : "icon_16x16.png",
      "scale" : "1x"
    },
    {
      "size" : "16x16",
      "idiom" : "mac",
      "filename" : "icon_16x16@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "32x32",
      "idiom" : "mac",
      "filename" : "icon_32x32.png",
      "scale" : "1x"
    },
    {
      "size" : "32x32",
      "idiom" : "mac",
      "filename" : "icon_32x32@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "128x128",
      "idiom" : "mac",
      "filename" : "icon_128x128.png",
      "scale" : "1x"
    },
    {
      "size" : "128x128",
      "idiom" : "mac",
      "filename" : "icon_128x128@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "256x256",
      "idiom" : "mac",
      "filename" : "icon_256x256.png",
      "scale" : "1x"
    },
    {
      "size" : "256x256",
      "idiom" : "mac",
      "filename" : "icon_256x256@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "512x512",
      "idiom" : "mac",
      "filename" : "icon_512x512.png",
      "scale" : "1x"
    },
    {
      "size" : "512x512",
      "idiom" : "mac",
      "filename" : "icon_512x512@2x.png",
      "scale" : "2x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOL

# Limpar arquivos temporários
rm -rf iconset.iconset
rm -f AppIcon.icns
