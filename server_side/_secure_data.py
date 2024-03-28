from cryptography.fernet import Fernet
fernet_key = Fernet(b'5ahI6Cv8wRv3IYXmsorvTcFaL_PHfxsI2kPbixF8tMA=')

def encrypt(input_string):
    return fernet_key.encrypt(str(input_string).encode('utf-8'))
