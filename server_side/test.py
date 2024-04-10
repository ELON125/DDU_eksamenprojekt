import secrets

# Generate a random 64-bit nonce
nonce = secrets.token_bytes(8)

# To display it as a hexadecimal string instead of bytes
nonce_hex = nonce.hex()


print(f"Nonce (hex): {nonce_hex}")
