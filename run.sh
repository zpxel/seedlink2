#!/data/data/com.termux/files/usr/bin/bash

# 🔐 PASSWORD
read -sp "Enter password: " pass
echo
[[ "$pass" != "zpxel" ]] && exit 1

# 🔑 KEY
k=23

# 🔒 ENCODED DATA (paste mo dito output ng encode.py)
d='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'

# 📂 TEMP FILE
tmp=$(mktemp)

# 🔓 DECODE (Python handles XOR + gzip)
python3 - << EOF > "$tmp"
import base64, gzip

k = $k
d = """$d"""

# decode
data = gzip.decompress(base64.b64decode(d))

# xor
decoded = bytes([b ^ k for b in data])

# output bash script
print(decoded.decode())
EOF

chmod +x "$tmp"

# 🚀 RUN ORIGINAL prit.sh (DITO LALABAS PROMPTS)
bash "$tmp"

# 🧹 CLEANUP
rm -f "$tmp"
