import bcrypt
from flask import Flask, request, jsonify
from database.database_comm_class import DatabaseComm
import _gen_questions
from email_validator import validate_email, EmailNotValidError
import _read_pdf_from_bytes
import secrets
import _secure_data
import datetime
from functools import wraps
from _email_handler import emailHandler
import json


database = DatabaseComm()
database.connect()

app = Flask(__name__)

def check_and_error_decorator(error_message, security_check = True):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            try:
                # Checking if a security check should be made
                if security_check:
                    print(request.get_json())
                    data = [json.loads(request.get_json()[0]), _secure_data.asymmetric_decrypt_message(request.get_json()[1])]

                    # Checking if the security hashes match
                    if not _secure_data.check_data_hash(data):
                        return jsonify({'error': 'Security check failed'})

                # Call the decorated function
                return func(*args, **kwargs)
            except Exception as e:
                # Email the developers
                new_email = emailHandler(f'Error in function {func.__name__}: {e.__context__}')
                new_email.add_content(error=str(e))
                new_email.send_email()

                # Handle the exception
                print("Error:", e)
                #error_message = str(error_message['error']) + '(Developers have been notified in regards to the error and will be in touch)'
                return jsonify(error_message)
        return wrapper
    return decorator



@app.route('/user_signup', methods=['POST'])
@check_and_error_decorator({'error': 'An error happened while trying to create account'})
def user_signup():
    # Fetching data from request
    data = [_secure_data.asymmetric_decrypt_message(json.loads(request.get_json()[0])), _secure_data.asymmetric_decrypt_message(request.get_json()[1])]

    #Checking if email is valid
    try:
        emailinfo = validate_email(data[0]['email'], check_deliverability=True)
        data[0]['email'] = emailinfo.normalized
    except EmailNotValidError as e:
        return jsonify({'error': str(e)})

    # Checking if email is already taken
    email_check = database.fetch_all("SELECT * FROM users_db WHERE email = %s", params=(data[0]['email'],))

    if len(email_check) > 0:
        return jsonify({'error': 'Email has already been used to create an account'})

    # Hashing the password
    hashed_password = bcrypt.hashpw(data[0]['password'].encode('utf-8'), bcrypt.gensalt())

    # Inserting data into user database
    database.execute_query("INSERT INTO users_db (email, password, high_score, client_id, saved_notes) VALUES (%s, %s, %s, %s, %s)", params=(data[0]["email"], hashed_password, 0, data[1]['client_id'], json.dumps({})))

    # Fetching the player id that was given
    user_id = str(database.fetch_all("SELECT * FROM users_db WHERE email = %s", params=(data[0]['email'],))[0]['user_id'])

    return jsonify({'user_data': {'high_score': '0', 'player_id': user_id}})


@app.route('/user_login', methods=['POST'])
@check_and_error_decorator({'error': 'An error happened while trying to log in'})
def user_login():
    # Fetching data from request
    print('JSON FILE')
    print(json.loads(request.get_json()[0]))
    data = _secure_data.asymmetric_decrypt_message(json.loads(request.get_json()[0]))

    submitted_password = data['password']

    # Requesting database for password with the given username
    result_user_db = database.fetch_all("SELECT * FROM users_db WHERE email = %s", params=(data['email'],))

    # If no user was found with given search
    if len(result_user_db) == 0:
        return jsonify({'error': 'User not found'})

    # If results were not none
    result_user_db = result_user_db[0]

    # Check if the entered password matches the stored password
    stored_password = result_user_db['password']

    if bcrypt.checkpw(submitted_password.encode('utf-8'), stored_password.encode('utf-8')):

        return jsonify({'message': 'Password matches', 'user_data': {'high_score': result_user_db['high_score'], 'player_id': result_user_db['user_id']}})
    else:
        return jsonify({'error': 'Password does not match'})

@app.route('/create_nonce', methods=['POST'])
@check_and_error_decorator({'error': 'An error happened while generating nonce'}, False)
def create_nonce():
    # Decrypt the data
    data = _secure_data.asymmetric_decrypt_message(request.get_json())

    # Generate a random 64-bit nonce
    nonce = secrets.token_bytes(8)
    nonce_hex = nonce.hex()

    # Inserting nonce in the database
    database.execute_query("INSERT INTO nonce_db (nonce, client_id, timestamp) VALUES (%s, %s, NOW())", params=(nonce_hex, data['client_id']))

    return jsonify({'message': 'Nonce created successfully', 'nonce': nonce_hex})


@app.route('/gen_questions', methods=['POST'])
@check_and_error_decorator({'error': 'An error happened generator questions'})
def gen_questions():
    # Fetching data from request
    data = json.loads(request.get_json()[0])

    # Fetching user from database
    result_notes_db = database.fetch_all("SELECT * FROM users_db WHERE user_id = %s", params=(data['user_id'],))[0]

    # Checking if the notes are already in the database
    if data['notes_title'] not in result_notes_db['saved_notes']:

        # Converting pdf byte data to text
        text = _read_pdf_from_bytes.read(data['uploaded_file_bytes'])

        # Updating the saved notes with the new ones
        saved_notes = json.loads(result_notes_db['saved_notes'])

        # Updating saved notes
        saved_notes[data['notes_title']] = str(text)

        # Updating the database
        database.execute_query("UPDATE users_db SET saved_notes = %s WHERE user_id = %s", params=(json.dumps(saved_notes), data['user_id']))

    else:
        # Fetching user from database
        result_notes_db = database.fetch_all("SELECT * FROM users_db WHERE user_id = %s", params=(data['user_id'],))[0]

        # Converting the saved notes to dictionary
        text = json.loads(result_notes_db['saved_notes'])[data['notes_title']]

    # Generating question thrugh chat gpt
    questions = _gen_questions.gen_questions(pdf_text=text, amount=['amount'])

    return jsonify({'question_list': questions})

@app.route('/get_saved_notes', methods=['POST'])
@check_and_error_decorator({'error': 'An error happened generator questions'})
def get_saved_notes():
    # Fetching data from request
    data = json.loads(request.get_json()[0])

    # Updating the database
    result_notes_db = database.fetch_all("SELECT * FROM users_db WHERE user_id = %s", params=(data['user_id'],))[0]

    # Iterating through the saved notes dict and extracting only the titles to not compromise and user_data that may lie in the notes
    saved_notes_titles = [key for key, value in json.loads(result_notes_db['saved_notes']).items()]

    return jsonify({'saved_notes': saved_notes_titles})

@app.route('/update_high_score', methods=['POST'])
@check_and_error_decorator({'error': 'An error happened while updating the highscore'})
def update_high_score():
    # Fetching data from request
    data = [_secure_data.asymmetric_decrypt_message(json.loads(request.get_json()[0])), _secure_data.asymmetric_decrypt_message(request.get_json()[1])]
    print(data)
    # Updating the score in the database
    il = database.execute_query("UPDATE users_db SET high_score = %s WHERE user_id = %s", params=(data[0]['new_high_score'], data[0]['user_id']))
    print(il)
    return jsonify({'message': 'High score updated'})

if __name__ == '__main__':
    host = '172.104.132.48'
    port = 40490
    print('Running on following address : ' + host + ':' + str(port))
    app.run(debug=True, host=host, port=port)



    #app.run(debug=True, host='192.168.0.198', port=40490)