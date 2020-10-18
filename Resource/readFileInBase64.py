import base64

def read_file_data(filename):
    data = open(filename, "rb").read()
    encoded = base64.b64encode(data)
    encoded.decode('utf-8')
    return (encoded.decode('utf-8'))
