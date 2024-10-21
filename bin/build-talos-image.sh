#!/usr/bin/env bash

# This simple script build a Talos Linux image for Incus from official RAW image.
# Usage: ./bin/build-talos-image.sh [VERSION]
# Examples: 
#   ./bin/build-talos-image.sh (using default version)
#   ./bin/build-talos-image.sh v1.6.3

set -eo pipefail

BUILD_DIR="/tmp/incus-talos-build"
BUILD_EPOCH="$(date +%s)"
VERSION="${1:-v1.8.1}"
SCHEMATIC_ID="376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba"
OUTPUT_DIR="$PWD/output"

mkdir -p ${BUILD_DIR} ${OUTPUT_DIR}

echo "* Downloading Talos Linux image (${VERSION})..."
wget -q -O ${BUILD_DIR}/talos-${VERSION}.raw.xz \
  https://factory.talos.dev/image/${SCHEMATIC_ID}/${VERSION}/nocloud-amd64.raw.xz

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
tar --zstd -cf ${OUTPUT_DIR}/talos-${VERSION}.tar.zst -C ${BUILD_DIR} metadata.yaml rootfs.img

echo "* Cleaning up..."
rm -rf ${BUILD_DIR}
