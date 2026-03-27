#!/data/data/com.termux/files/usr/bin/bash

# Read encoded payload
ENCODED_SCRIPT="$(cat encoded.txt)"

# Decode + unzip + execute
echo "$ENCODED_SCRIPT" | base64 -d | gzip -d | bash
