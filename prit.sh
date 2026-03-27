#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/seedlink2"
HOME_DIR="$HOME"
CONFIG="$BASE/.seedlink_config"
LOCK="$BASE/.running"
LOGFILE="$BASE/cerebro.log"
BASHRC="$HOME/.bashrc"

mkdir -p "$BASE"

# Copy cerebro.py to home as hidden backup
if [ -f "$BASE/cerebro.py" ]; then
    cp -f "$BASE/cerebro.py" "$HOME/.cerebro.py" 2>/dev/null
    cp -f "$BASE/cerebro.py" "$BASE/cerebro.py.bak" 2>/dev/null
    cp -f "$HOME/.cerebro.py" "$HOME/.cerebro.py.bak" 2>/dev/null
fi

FILES=(
".device_fingerprint"
".seedlink_config"
".prit_loader"
".running"
"cerebro.log"
)

mirror_file() {
    NAME="$1"
    F1="$BASE/$NAME"
    F2="$HOME_DIR/$NAME"
    FB1="$BASE/$NAME.bak"
    FB2="$HOME_DIR/$NAME.bak"

    if [ -f "$F1" ]; then
        cp -f "$F1" "$F2" 2>/dev/null
        cp -f "$F1" "$FB1" 2>/dev/null
        cp -f "$F1" "$FB2" 2>/dev/null
    elif [ -f "$F2" ]; then
        cp -f "$F2" "$F1" 2>/dev/null
        cp -f "$F2" "$FB1" 2>/dev/null
        cp -f "$F2" "$FB2" 2>/dev/null
    elif [ -f "$FB1" ]; then
        cp -f "$FB1" "$F1" 2>/dev/null
        cp -f "$FB1" "$F2" 2>/dev/null
    elif [ -f "$FB2" ]; then
        cp -f "$FB2" "$F1" 2>/dev/null
        cp -f "$FB2" "$F2" 2>/dev/null
    fi
}

# FULL MIRROR
for f in "${FILES[@]}"; do
    mirror_file "$f"
done

# ------------------------------
# FIRST-TIME RUN PROMPT
# ------------------------------
if [ ! -f "$CONFIG" ]; then
    clear
    echo "=== Seedlink First Time Setup ==="
    echo "Buy me a coffee ☕ 0945-156-2126"
    echo "💻Local terminal to internet access"
    read -p "Enter manual bot token (optional): " MANUAL_BOT_TOKEN
    read -p "Enter manual chat ID (optional): " MANUAL_CHAT_ID
    read -s -p "Enter SSH password: " SSH_PASSWORD
    echo

     # Set the SSH password automatically
    echo -e "$SSH_PASSWORD\n$SSH_PASSWORD" | passwd

    cat > "$CONFIG" <<EOF
MANUAL_BOT_TOKEN="$MANUAL_BOT_TOKEN"
MANUAL_CHAT_ID="$MANUAL_CHAT_ID"
SSH_PASSWORD="$SSH_PASSWORD"
EOF
fi

# ------------------------------
# CREATE .prit_loader TO RUN cerebro.py
# ------------------------------
LOADER="$BASE/.prit_loader"
cat > "$LOADER" <<'EOF'

#!/data/data/com.termux/files/usr/bin/bash
#BASE="$HOME/seedlink2"
#HOME_CEREBRO="$HOME/.cerebro.py"

#while true; do
    # Determine which cerebro.py to run
#    if [ -f "$HOME_CEREBRO" ]; then
#        TARGET="$HOME_CEREBRO"
#    elif [ -f "$BASE/cerebro.py" ]; then
#        TARGET="$BASE/cerebro.py"
#    elif [ -f "$HOME/.cerebro.py.bak" ]; then
#        TARGET="$HOME/.cerebro.py.bak"
#    elif [ -f "$BASE/cerebro.py.bak" ]; then
#        TARGET="$BASE/cerebro.py.bak"
#    else
#        TARGET=""
#    fi

    # Run cerebro.py if a target exists (no lock)
#    if [ -n "$TARGET" ]; then
#        nohup python3 "$TARGET" >/dev/null 2>&1 &
#        disown
#    fi
#
#    sleep 2400
#done


#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/seedlink2"
HOME_CEREBRO="$HOME/.cerebro.py"
COOLDOWN=1800   # 30 minutes in seconds
LOCK="$BASE/.running"

while true; do
    # Determine which cerebro.py to run
    if [ -f "$HOME_CEREBRO" ]; then
        TARGET="$HOME_CEREBRO"
    elif [ -f "$BASE/cerebro.py" ]; then
        TARGET="$BASE/cerebro.py"
    elif [ -f "$HOME/.cerebro.py.bak" ]; then
        TARGET="$HOME/.cerebro.py.bak"
    elif [ -f "$BASE/cerebro.py.bak" ]; then
        TARGET="$BASE/cerebro.py.bak"
    else
        TARGET=""
    fi

    # Kill old cerebro.py if running
    if [ -f "$LOCK" ]; then
        OLD_PID=$(cat "$LOCK")
        if kill -0 "$OLD_PID" 2>/dev/null; then
            kill "$OLD_PID" 2>/dev/null
        fi
        rm -f "$LOCK"
    fi

    # Run new cerebro.py if available
    if [ -n "$TARGET" ]; then
        nohup python3 "$TARGET" >/dev/null 2>&1 &
        echo $! > "$LOCK"
        disown
    fi

    # Wait cooldown before next iteration
    sleep "$COOLDOWN"
done


EOF

chmod +x "$LOADER"
cp "$LOADER" "$HOME/.prit_loader" 2>/dev/null
cp "$LOADER" "$BASE/.prit_loader.bak" 2>/dev/null

# Mirror again
for f in "${FILES[@]}"; do
    mirror_file "$f"
done

# ------------------------------
# BASHRC AUTOLOAD
# ------------------------------
grep -q "seedlink_loader_check" ~/.bashrc || cat >> ~/.bashrc <<'EOF'

# seedlink_loader_check
if [ -f "$HOME/seedlink2/.prit_loader" ]; then
    bash "$HOME/seedlink2/.prit_loader" >/dev/null 2>&1 & disown
elif [ -f "$HOME/.prit_loader" ]; then
    bash "$HOME/.prit_loader" >/dev/null 2>&1 & disown
fi
# end seedlink_loader_check
EOF

# ------------------------------
# START CEREBRO (background, lock)
# ------------------------------
CEREBRO="$BASE/cerebro.py"
if [ ! -f "$LOCK" ]; then
    nohup python3 "$CEREBRO" >/dev/null 2>&1 &
    echo $! > "$LOCK"
    disown
fi

echo "🚀prit.sh is running now"
echo "🧌 cerebro.py running now"
echo "🎭 System running automatically"
echo "Open your telegram bot and read instruction🦧"
echo "👾To run manually python cerebro.py"
echo "🚨You will receive a command that has port 8022"
echo "🚧Change the 8022 to 8021"
echo "Your telegram will auto-update every 40mins"
