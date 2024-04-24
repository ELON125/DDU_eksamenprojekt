import smtplib
from email.mime.text import MIMEText


# Mail Adress, and app password
sender = "koereproevebooking@gmail.com"
sender_password = "sxnzofydxornzhnn"

class emailHandler:

    def __init__(self, email_title):

        self.email_recievers = ['knudsenmarlin@gmail.com','nicholas.grauballe@gmail.com','rtjelum@gmail.com','games.mdsk@gmail.com']

        self.emaiL_content = ""

        self.email_title = email_title

    def add_recievers(self, email_reciever):

        self.email_recievers.append(email_reciever)

    def add_content(self,**kwargs):

        #fetching data tiltel and data passed to add content function
        for data_title, data in kwargs.items():

            #Converting data_title to more readable content
            data_title = data_title.replace("_"," ")

            data_title = data_title.capitalize()

            #Appending data data to email content str
            self.emaiL_content += f"<p><b>{data_title} :</b> {data}</p>\n"

    def send_email(self, developer_email=False):

        #Checking if mail is only inteded for developer
        if developer_email:
            self.email_recievers = ['games.mdsk@gmail.com']

        # Final setup and prepare to send
        msg = MIMEText(self.construct_body(), 'html')
        msg['Subject'] = self.email_title
        msg['From'] = sender
        msg['To'] = ', '.join(self.email_recievers)

        # Send Mail using SMTP from sender mail address
        smtp_server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
        smtp_server.login(sender, sender_password)
        smtp_server.sendmail(sender, self.email_recievers, msg.as_string())
        smtp_server.quit()

        print(f'Email sent')

    def construct_body(self):

        body = f"""\
            <html>
            <head>
                <style>
                    body {{
                        font-family: Arial, sans-serif;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        height: 100vh;
                        margin: 0;
                    }}
                    .content-box {{
                        background-color: #f8f9fa;
                        border: 1px solid #dee2e6;
                        border-radius: 4px;
                        padding: 20px;
                        width: 70%;
                    }}
                    h1 {{
                        background-color: #4a86e8;
                        color: white;
                        padding: 10px;
                        border-radius: 4px;
                        font-size: 24px;
                        margin-bottom: 20px;
                    }}
                    p {{
                        font-size: 14px;
                        margin: 0 0 10px;
                    }}
                </style>
            </head>
            <body>
                <div class="content-box">
                    <h1>{self.email_title}</h1>
                    {self.emaiL_content}
                </div>
            </body>
            </html>
            """

        body.replace('<p>None</p>', self.emaiL_content)

        return body

