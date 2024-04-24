from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import hashes
import base64

# Load the private key
def load_private_key(filename):
    with open(filename, "rb") as key_file:
        private_key = serialization.load_pem_private_key(
            key_file.read(),
            password=None  # No password protection
        )
    return private_key

# Decrypt function
def decrypt_message(encrypted_message_base64):
    # Load the private key from the PEM file
    private_key = load_private_key("private_key.pem")

    # Decode the base64-encoded message and decrypt it
    encrypted_message = base64.b64decode(encrypted_message_base64)

    decrypted_message = private_key.decrypt(
        encrypted_message,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )

    # Assuming the message is UTF-8 encoded, decode it
    decrypted_message_str = decrypted_message.decode('utf-8')

    return decrypted_message_str

print(decrypt_message('YhP7tqbshZh4Q33oho+89tcyh6o5NMs8AGaqr9fqlyDJYMyTX74BHJUw/Ygyn/iQaRANdQSIUpHoDqu/5MUqUeqDU35mfX7lFD0/K5gzFpxu/e5z3pdJ5OxQlmtVq7PBz5oTTpBBDm1bYJ0wP76rM+EeZy3lfxzuj9hmQnAQnk1aRwZDmgHsso4eAn9z9pL06cZwcYBxozQpKwaq13K3gg80GkVicD7e9GOHPrAlwELx9UD2tKVas8lLyZ9unz1w4dc4kr4XQhmZUY2pMoAg+fBe3TGDedsGWODN4clrYuI6PbQ7KgJHyLDpLffs7TvHEYX+aDVP3D/mK1BtsdStww==\n'))

