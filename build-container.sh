#!/usr/bin/env bash
set -veu

BASE_DIR=$(dirname "$0")

CONTAINER_NAME=debian-small
IMAGE_NAME=i386/$CONTAINER_NAME

OUT_ROOTFS_TAR=$BASE_DIR/images/$CONTAINER_NAME-9p-rootfs.tar
OUT_ROOTFS_FLAT=$BASE_DIR/images/$CONTAINER_NAME-9p-rootfs-flat
OUT_FSJSON=$BASE_DIR/images/$CONTAINER_NAME-base-fs.json

docker build . --rm --platform linux/386 --tag "$IMAGE_NAME"
docker rm "$CONTAINER_NAME" || true
docker create --platform linux/386 -t -i --name "$CONTAINER_NAME" "$IMAGE_NAME" bash

docker export "$CONTAINER_NAME" > "$OUT_ROOTFS_TAR"

$BASE_DIR/tools/fs2json.py --out "$OUT_FSJSON" "$OUT_ROOTFS_TAR"

# Note: Not deleting old files here
mkdir -p "$OUT_ROOTFS_FLAT"
$BASE_DIR/tools/copy-to-sha256.py "$OUT_ROOTFS_TAR" "$OUT_ROOTFS_FLAT"

echo "$OUT_ROOTFS_TAR", "$OUT_ROOTFS_FLAT" and "$OUT_FSJSON" created.
