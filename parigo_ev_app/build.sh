#!/bin/bash
# Exit on error
set -e

echo "Downloading Flutter..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

echo "Enabling Flutter Web..."
flutter config --enable-web

echo "Fetching dependencies..."
flutter pub get

echo "Building Flutter Web App..."
flutter build web --release
