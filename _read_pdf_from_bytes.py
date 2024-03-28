import PyPDF2
from io import BytesIO

def read(input_bytes):
    # Convert bytes to a PDF file-like object
    pdf_bytes = BytesIO(bytes(input_bytes))

    # Reding bytes object
    pdf = PyPDF2.PdfReader(pdf_bytes)

    # Extracting all the text into the text variable
    text = ''
    text = (text.join(page.extract_text()) for page in pdf.pages)
    return text
