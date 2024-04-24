from io import BytesIO
import PyPDF2
import re
def clean_extracted_text(text):
    # Replace vertical bars with commas or remove them
    text = text.replace('|', ', ')

    # Replace non-breaking spaces with regular spaces
    text = text.replace('\xa0', ' ')

    # Reduce multiple newlines to a single newline
    text = re.sub(r'\n+', '\n', text)

    # Optional: Reduce multiple spaces to a single space
    text = re.sub(r' +', ' ', text)

    # Optional: Replace newline with space if you prefer a continuous block of text
    text = text.replace('\n', ' ')

    return text

def read(input_bytes):
    # Convert bytes to a PDF file-like object
    pdf_bytes = BytesIO(bytes(input_bytes))

    # Reading bytes object
    pdf = PyPDF2.PdfReader(pdf_bytes)

    # Extracting all the text into the text variable
    text = ''
    for page in pdf.pages:
        if page.extract_text():
            text += page.extract_text() + '\n'  # Optionally add a newline between pages

    return clean_extracted_text(text)

