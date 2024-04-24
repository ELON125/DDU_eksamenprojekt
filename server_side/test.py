import hashlib

hash_object = hashlib.sha256('123'.encode())
print(hash_object)
print(hash_object.hexdigest())
