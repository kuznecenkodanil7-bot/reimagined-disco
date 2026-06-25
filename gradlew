#!/usr/bin/env sh
set -eu

GRADLE_VERSION="8.14.3"
GRADLE_HOME_DIR="${GRADLE_USER_HOME:-$HOME/.gradle}/nauzer-wrapper/gradle-${GRADLE_VERSION}"
GRADLE_BIN="$GRADLE_HOME_DIR/bin/gradle"

if [ ! -x "$GRADLE_BIN" ]; then
  mkdir -p "$(dirname "$GRADLE_HOME_DIR")"
  ZIP="${GRADLE_HOME_DIR}.zip"
  URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
  echo "Downloading Gradle ${GRADLE_VERSION}..."
  if command -v curl >/dev/null 2>&1; then
    curl -fL "$URL" -o "$ZIP"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$ZIP" "$URL"
  else
    echo "Install curl or wget, or install Gradle manually." >&2
    exit 1
  fi
  rm -rf "$GRADLE_HOME_DIR"
  unzip -q "$ZIP" -d "$(dirname "$GRADLE_HOME_DIR")"
  mv "$(dirname "$GRADLE_HOME_DIR")/gradle-${GRADLE_VERSION}" "$GRADLE_HOME_DIR"
  rm -f "$ZIP"
fi

exec "$GRADLE_BIN" "$@"
