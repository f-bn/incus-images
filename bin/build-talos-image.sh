#!/usr/bin/env bash

# This simple script build a Talos Linux image for Incus from official RAW image.
# Usage: ./bin/build-talos-image.sh [VERSION]
# Examples: 
#   ./bin/build-talos-image.sh (using default version)
#   ./bin/build-talos-image.sh v1.6.3

set -eo pipefail

BUILD_DIR="/tmp/incus-talos-build"
BUILD_EPOCH="$(date +%s)"
VERSION="${1:-v1.6.5}"

mkdir -p ${BUILD_DIR}

echo "* Downloading Talos Linux image (${VERSION})..."
wget -q -O ${BUILD_DIR}/talos-${VERSION}.raw.xz \
  https://github.com/siderolabs/talos/releases/download/${VERSION}/nocloud-amd64.raw.xz

echo "* Extracting image..."
xz -d ${BUILD_DIR}/talos-${VERSION}.raw.xz

echo "* Convert image to QCOW2 format..."
qemu-img convert -p -f raw -O qcow2 ${BUILD_DIR}/talos-${VERSION}.raw ${BUILD_DIR}/rootfs.img

echo "* Create Incus unified tarball..."
tee ${BUILD_DIR}/metadata.yaml > /dev/null <<EOF
architecture: x86_64
creation_date: ${BUILD_EPOCH}
properties:
  description: Talos Linux ${VERSION//v}
  os: Talos Linux
  release: ${VERSION//v}
EOF
tar --zstd -cf talos-${VERSION}.tar.zst -C ${BUILD_DIR} metadata.yaml rootfs.img

echo "* Cleaning up..."
rm -rf ${BUILD_DIR}
