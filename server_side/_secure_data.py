from cryptography.fernet import Fernet
import hashlib
from flask_server import database
import datetime
import json
from flask import Flask, request, jsonify

fernet_key = Fernet(b'5ahI6Cv8wRv3IYXmsorvTcFaL_PHfxsI2kPbixF8tMA=')

def encrypt(input_string):
    return fernet_key.encrypt(str(input_string).encode('utf-8'))

def decrypt(input_string):
    return fernet_key.decrypt(input_string.decode('utf-8'))

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
        is_old = (current_time - stored_timestamp).total_seconds() > 5

        if is_old is False:
            request_nonce = nonce

        # Deleting nonce after usage
        database.execute_query("DELETE FROM nonce_db WHERE nonce = %s AND client_id = %s", params=(nonce, client_id))

    # Returning the nonce
    return request_nonce

# This function is to check that the security hash sent with the request matches to one created by the server will return false on error
def check_data_hash(request_data):
    client_id = request_data[0]['client_id']
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
    # Checking if the two hashesh match
    if client_hash == hash_object:
        return True

    # If they don't match then returning false
    else:
        return False







