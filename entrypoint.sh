#!/bin/bash
set -e

# Remove stale socket left by a prior crash
rm -f /home/ubuntu/.config/Insync-headless/insync.sock

exec insync-headless start --no-daemon
