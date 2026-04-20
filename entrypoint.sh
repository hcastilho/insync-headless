#!/bin/bash
set -e

CONFIG_DIR=/home/ubuntu/.config/Insync-headless

echo "--- Initializing Insync-headless Container ---"

# Remove stale socket left by a prior crash
rm -f "$CONFIG_DIR/insync.sock"

# Ensure the bind mount is writable by the ubuntu user
chown ubuntu:ubuntu "$CONFIG_DIR"

echo "Starting Insync-headless engine..."
exec gosu ubuntu insync-headless start --no-daemon
