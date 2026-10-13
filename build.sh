#!/bin/bash

set -e

# Decompile with Apktool (decode resources + classes)
wget -q https://github.com/iBotPeaches/Apktool/releases/download/v3.0.1/apktool_3.0.1.jar -O apktool.jar
java -jar apktool.jar d iceraven.apk -o iceraven-patched  # -s flag removed
rm -rf iceraven-patched/META-INF

# Color patching
sed -i 's/<color name="fx_mobile_surface">.*/<color name="fx_mobile_surface">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_background">.*/<color name="fx_mobile_background">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values-night/colors.xml

# Smali patching (location varies between smali_classesN dirs across releases)
photon=$(find iceraven-patched -path '*/smali*/mozilla/components/ui/colors/PhotonColors.smali' | head -n1)
[ -n "$photon" ] || { echo "PhotonColors.smali not found" >&2; exit 1; }
sed -i 's/ff2b2a33/ff000000/g' "$photon"
sed -i 's/ff42414d/ff15141a/g' "$photon"
sed -i 's/ff52525e/ff15141a/g' "$photon"

# Recompile the APK
java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk

# Align and sign the APK
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk

# Clean up
rm -rf iceraven-patched iceraven-patched.apk
