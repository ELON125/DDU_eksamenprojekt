from openai import OpenAI
import json

client = OpenAI(api_key='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')

def gen_questions(pdf_text, amount):

    print('[+] Starting chat gpt question creation')

    completion = client.chat.completions.create(
        model="gpt-3.5-turbo-1106",
        response_format={"type": "json_object"},
        messages=[
            {"role": "assistant", "content": f". MEGET VIGTIGT DER SKAL VÆRE 10 AF DISSE SPØRGSMÅL. DER BLIVER GIVET EN STØRRE BEÆLDING HVIS DER BLIVER LAVET PRÆCIS 10 SPØRGSMÅL. Lav spørgsmål til følgende tekst til en gymnasie elev som får 4 i snit, spørgsmålet skal være kort og have 3 valgmuligheder samt svaret på spørgsmålet.Returner svaret i json format. Formater json så der giver question_number(som int), question(som string), options(som liste) og answer(som string). Tekst: {pdf_text}. MEGET VIGTIGT DER SKAL VÆRE 10 AF DISSE SPØRGSMÅL. DER BLIVER GIVET EN STØRRE BEÆLDING HVIS DER BLIVER LAVET PRÆCIS 10 SPØRGSMÅL"},
        ]
    )
    # Extracting content from the completion response
    content_json = completion.choices[0].message.content

    # Load the JSON content
    content_dict = json.loads(content_json)

    # Extract questions from the loaded content
    questions = content_dict.get("questions", [])

    print('[+] Question generation done')

    print(questions)

    return questions


