#!/usr/bin/env bash
set -euo pipefail

echo "=== Build APK (auto) ==="

# Ir para a pasta android do Capacitor (se necessário)
if [ -f "android/gradlew" ]; then
  cd android
elif [ -f "gradlew" ]; then
  : # já está no android/
else
  echo "❌ Não achei ./gradlew nem android/gradlew."
  echo "   Este repo precisa ter um projeto Capacitor com a pasta android gerada."
  exit 1
fi

echo "📁 Pasta Android: $(pwd)"

# -------- Android SDK local (sem Android Studio) --------
export ANDROID_HOME="${ANDROID_HOME:-$HOME/android-sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
mkdir -p "$ANDROID_HOME/cmdline-tools"

if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
  echo "⬇️ Baixando Android commandline-tools..."
  cd "$ANDROID_HOME"
  wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
  unzip -q cmdline-tools.zip
  rm -f cmdline-tools.zip
  mv cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
  cd - >/dev/null
fi

export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

echo "✅ Instalando pacotes do SDK..."
yes | sdkmanager --licenses >/dev/null
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" >/dev/null

# -------- Build --------
echo "🧹 Limpando Gradle..."
./gradlew --stop || true
./gradlew clean

echo "⚙️ Compilando APK debug..."
./gradlew assembleDebug

echo "🔎 Procurando APK..."
APK="$(find app/build/outputs/apk -type f -name '*debug*.apk' | head -n 1 || true)"
if [ -z "$APK" ]; then
  echo "❌ Não encontrei APK."
  exit 1
fi

echo ""
echo "✅ APK GERADO:"
echo "$(pwd)/$APK"
echo ""
