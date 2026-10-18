#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ TeleTurbo - Local Builder & Packaging Tool"
echo "=========================================================="

if [ -z "$THEOS" ]; then
    export THEOS=~/theos
fi

if [ ! -d "$THEOS" ]; then
    echo "❌ Error: Theos is not installed at $THEOS."
    echo "Install it via: git clone --recursive https://github.com/theos/theos.git ~/theos"
    exit 1
fi

echo "🧹 Cleaning previous build artifacts..."
make clean
rm -rf packages/

echo "🔨 Building Rootless .deb (iOS 15 - 17+ / Dopamine)..."
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless

echo "🔨 Building Rootful .deb (palera1n / checkra1n)..."
make package FINALPACKAGE=1

echo "✅ Compilation finished! Generated debian packages in ./packages/:"
ls -lh packages/*.deb

echo ""
echo "To install on connected device over SSH:"
echo "make do THEOS_DEVICE_IP=192.168.1.xxx"
