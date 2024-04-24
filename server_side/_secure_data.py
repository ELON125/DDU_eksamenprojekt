from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import hashes
import base64

fernet_key = Fernet(b'5ahI6Cv8wRv3IYXmsorvTcFaL_PHfxsI2kPbixF8tMA=')

# Load the private key
def load_private_key(filename):
    with open(filename, "rb") as key_file:
        private_key = serialization.load_pem_private_key(
            key_file.read(),
            password=None  # No password protection
        )
    return private_key

# Decrypt function
def asymmetric_decrypt_message(encrypted_message_base64):
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

def encrypt(input_string):
    return fernet_key.encrypt(str(input_string).encode('utf-8'))

def decrypt(input_string):
    return fernet_key.decrypt(input_string.decode('utf-8'))


