import sys
import json
import base64
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import hashes

# Load the public key
def load_public_key(filename):
    with open(filename, "rb") as key_file:
        public_key = serialization.load_pem_public_key(
            key_file.read(),
        )
    return public_key

# Encrypt function
def encrypt_message(public_key, message):
    return public_key.encrypt(
        message,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )

def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py '{\"key\": \"value\", \"number\": 123}'")
        return
    data = sys.argv[1]
    public_key = load_public_key("public_key.pem")
    message_bytes = str(data).encode('utf-8')
    encrypted_message = encrypt_message(public_key, message_bytes)
    encrypted_message_base64 = base64.b64encode(encrypted_message)
    print(encrypted_message_base64.decode('utf-8'))

if __name__ == "__main__":
    main()
