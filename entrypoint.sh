#!/bin/bash

# --- 1. Set Defaults ---
PUID=${PUID:-1000}
PGID=${PGID:-1000}

echo "--- Initializing Insync-headless Container ---"
echo "User ID: $PUID | Group ID: $PGID"

# --- 2. Resolve or create the target user ---
TARGET_USER=$(getent passwd "$PUID" | cut -d: -f1)
if [ -z "$TARGET_USER" ]; then
    echo "No user exists at UID $PUID — creating 'insync'..."
    groupadd -g "$PGID" insync 2>/dev/null || true
    useradd -u "$PUID" -g "$PGID" -m -s /bin/bash insync
    TARGET_USER=insync
else
    echo "Using existing user '$TARGET_USER' at UID $PUID"
fi

# --- 3. Emergency Cleanup ---
# Removes stale sockets that prevent Insync from starting after a crash
rm -f /tmp/insync.sock
rm -f /config/insync.sock 2>/dev/null

# --- 4. Smart Permission Handling ---

# A. Always fix /config (Small, contains critical SQLite DB)
echo "Ensuring /config ownership..."
chown -R "$PUID:$PGID" /config

# B. Conditionally fix /data (The 'Smart' part)
if [ "$SKIP_CHOWN" = "true" ]; then
    echo "SKIP_CHOWN is set to true. Skipping /data permission check."
else
    CURRENT_DATA_OWNER=$(stat -c %u /data)
    if [ "$CURRENT_DATA_OWNER" != "$PUID" ]; then
        echo "Ownership mismatch on /data (Current: $CURRENT_DATA_OWNER, Target: $PUID)."
        echo "Fixing permissions recursively... (This may take a while for large datasets)"
        chown -R "$PUID:$PGID" /data
    else
        echo "Ownership on /data is already correct. Skipping recursive chown to save time."
    fi
fi

# --- 5. Point Insync's config dir at /config ---
# Insync has no --config-path flag; it reads from ~/.config/Insync.
# Symlink that path to the /config bind mount so state persists there.
USER_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
mkdir -p "$USER_HOME/.config"
ln -sfn /config "$USER_HOME/.config/Insync"
chown -h "$PUID:$PGID" "$USER_HOME/.config/Insync"

# --- 6. Start Insync ---
echo "Starting Insync-headless engine..."
# We use 'exec' so Insync becomes PID 1 and receives shutdown signals correctly.
# We use 'gosu' to drop from root to our PUID/PGID user.
exec gosu "$TARGET_USER" insync-headless start --no-daemon
