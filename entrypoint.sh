#!/bin/bash

# --- 1. Set Defaults ---
PUID=${PUID:-1000}
PGID=${PGID:-1000}

echo "--- Initializing Insync-headless Container ---"
echo "User ID: $PUID | Group ID: $PGID"

# --- 2. Create User/Group if they don't exist ---
# Check if group exists, create if not
if ! getent group insync >/dev/null; then
    groupadd -g "$PGID" insync
fi

# Check if user exists, create if not
if ! getent passwd insync >/dev/null; then
    useradd -u "$PUID" -g "$PGID" -m -s /bin/bash insync
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

# --- 5. Start Insync ---
echo "Starting Insync-headless engine..."
# We use 'exec' so Insync becomes PID 1 and receives shutdown signals correctly.
# We use 'gosu' to drop from root to our PUID/PGID user.
exec gosu insync insync-headless start --no-daemon --config-path=/config