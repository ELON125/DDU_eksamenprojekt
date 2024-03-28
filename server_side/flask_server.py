import json

import mysql.connector
import bcrypt
from flask import Flask, request, jsonify
from database.database_comm_class import DatabaseComm
import _gen_questions
from email_validator import validate_email, EmailNotValidError
import _read_pdf_from_bytes

database = DatabaseComm()
database.connect()

app = Flask(__name__)


@app.route('/user_signup', methods=['POST'])
def user_signup():
    try:
        # Fetching data from request
        data = request.get_json()

        #Checking if email is valid
        try:
            emailinfo = validate_email(data['email'], check_deliverability=True)
            data['email'] = emailinfo.normalized
        except EmailNotValidError as e:
            return jsonify({'error': str(e)})

        # Hashing the password
        hashed_password = bcrypt.hashpw(data['password'].encode('utf-8'), bcrypt.gensalt())

        # Inserting data into user database
        database.execute_query("INSERT INTO users (email, password, total_points) VALUES (%s, %s, NULL,)",params=(data["email"], hashed_password))

        return jsonify({'message': 'Data inserted'})

    except Exception as e:
        print(e)
        return jsonify({'error': str(e)})


@app.route('/user_login', methods=['POST'])
def user_login():
    try:
        # Fetching data from request
        data = request.get_json()
        submitted_password = data['password']

        # Requesting database for password with the given username
        result_user_db = database.fetch_all("SELECT * FROM users WHERE email = %s", params=(data['email'],))

        # If no user was found with given search
        if len(result_user_db) == 0:
            return jsonify({'error': 'User not found'})

        # If results were not none
        result_user_db = result_user_db[0]

        # Check if the entered password matches the stored password
        stored_password = result_user_db['password']

        if bcrypt.checkpw(submitted_password.encode('utf-8'), stored_password.encode('utf-8')):
            return jsonify({'message': 'Password matches', 'data': {'name': result_user_db['name'], 'experience': result_user_db['experience'], 'ranked_points': result_user_db['ranked_points']}})
        else:
            return jsonify({'error': 'Password does not match'})

    except Exception as e:
        print(e)
        return jsonify({'error': str(e)})

@app.route('/gen_questions', methods=['POST'])
def gen_questions():
    try:
        # Fetching data from request
        data = request.get_json()

        # Converting pdf byte data to text
        pdf_text = _read_pdf_from_bytes.read(data['uploaded_file_bytes'])

        # Generating question thrugh chat gpt
        questions = _gen_questions.gen_questions(pdf_text=pdf_text, amount=data['amount'])
        return jsonify({'question_list': questions})

    except Exception as e:
        print(e)
        return jsonify({'error': str(e)})

if __name__ == '__main__':
    #app.run(debug=True, host='172.104.132.48', port=40496)
    app.run(debug=True, port=5000)