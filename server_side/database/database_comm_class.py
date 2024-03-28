import mysql.connector
import configparser
import _secure_data

class DatabaseComm:
    def __init__(self):

        self.host = 'localhost'
        self.user = 'DDU_USR'
        self.password = '1234'
        self.database = 'DDU'
        self.connection = None
        self.cursor = None

    def connect(self):
        try:
            self.connection = mysql.connector.connect(
                host=self.host,
                user=self.user,
                password=self.password,
                database=self.database
            )
            self.cursor = self.connection.cursor(buffered=True, dictionary=True)
            print("Connected to the database")
        except mysql.connector.Error as err:
            print(f"Error: {err}")

    def execute_query(self, query, params=None):
        #Encrypting all the data going into database
        new_params = tuple(_secure_data.encrypt(parameter) for parameter in params) if params is not None else ()
        print(new_params)

        # Executing query
        try:
            result = self.cursor.execute(query, new_params)
            print(result)
            self.connection.commit()
            print("Query executed successfully")

            return result
        except mysql.connector.Error as err:
            print(f"Error: {err}")

    def fetch_all(self, query, params=None):
        try:
            self.cursor.execute(query, params)
            result = self.cursor.fetchall()
            print(result)
            return result
        except mysql.connector.Error as err:
            print(f"Error: {err}")
            return None

    def close(self):
        if self.connection.is_connected():
            self.cursor.close()
            self.connection.close()
            print("Connection closed")



