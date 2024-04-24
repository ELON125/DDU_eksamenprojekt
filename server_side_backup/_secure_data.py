from cryptography.fernet import Fernet
import hashlib
from flask_server import database
import datetime
import json
from flask import Flask, request, jsonify
from cryptography.fernet import Fernet
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
def asymmetric_decrypt_message(encrypted_message_base64):

    # Dictionary containing the decrypted dictionary
    decryped_dict = {}

    # Load the private    key from the PEM file
    private_key = load_private_key("private_key.pem")

    # Iterating through key and values in the encrypted message
    for key, value in encrypted_message_base64.items():

        # Creating a list that will have the decrypted key and value
        decrypted_items = []

        # Itterating through the key and value and decrypting them
        for encrypted_string in [key, value]:
            # Decode the base64-encoded message and decrypt it
            encrypted_message = base64.b64decode(encrypted_string)

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

            # Appending decrypted message to the list
            decrypted_items.append(decrypted_message_str)

        # Addeing the key and value to the decrypted items dictionary
        decryped_dict[decrypted_items[0]] = decrypted_items[1]

    return decryped_dict

def get_nonce(client_id):
    request_nonce = None

    # Checking nonce
    result = database.fetch_all("SELECT nonce, timestamp FROM nonce_db WHERE client_id = %s", params=(client_id,))

    # Checking if a nonce was found for the client id
    if not result:
        return False

    # Iterrating through all results as there might be some old nonce in the system in some situations
    for result in result:
        # Extract nonce and timestamp from the result
        nonce, stored_timestamp = result['nonce'], result['timestamp']

        # Current time
        current_time = datetime.datetime.now()

        # Check if the nonce is more than a minute old
        is_old = (current_time - stored_timestamp).total_seconds() > 30

        if is_old is False:
            request_nonce = nonce

        # Deleting nonce after usage
        database.execute_query("DELETE FROM nonce_db WHERE nonce = %s AND client_id = %s", params=(nonce, client_id))

    # Returning the nonce
    return request_nonce

# This function is to check that the security hash sent with the request matches to one created by the server will return false on error
def check_data_hash(request_data):
    client_id = request_data[1]['client_id']
    client_hash = request_data[1]['request_hash']
    hash_security_token = 'd1b3a5bece9cb101'
    request_nonce = get_nonce(client_id)

    # Checking if a nonce was found
    if request_nonce is None:
        return False

    # Maniplulating the request_data[0] because the format changes abit under serialization
    request_data_string = str(request_data[0]).replace("'", '"').replace(' ', '')

    # Generating the string to hash
    hashing_str = request_data_string + client_id + hash_security_token + request_nonce

    # Constructing the
    hash_object = hashlib.sha256(hashing_str.encode()).hexdigest()
    print('Client hash : ' + client_hash)
    print('Server hash : ' + hash_object)
    print('Request nonce : ' + str(request_nonce))
    print('Client ID : ' + str(client_id))
    print('Hash security token  : ' + str(hash_security_token))
    print('Request data string  : ' + str(request_data_string))

    # Checking if the two hashesh match
    if str(client_hash) == str(hash_object):
        return True

    # If they don't match then returning false
    else:
        return False







