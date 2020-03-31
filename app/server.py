from flask import Flask, jsonify, request
from os import path
import base64
import time
import subprocess

app = Flask(__name__)

@app.route("/")
def hello_world():
    return {"text": "Hello World!"}

@app.route("/detect", methods=['POST'])
def detect():
    if request.method != 'POST':
        return "HTTP METHOD NOT SUPPORTED"

    request_data = request.get_json()

    if request_data is None:
        print("No valid request body, json missing!")
        return jsonify({'error': 'No valid request body, json missing!'})
    else:
        img_base64_data = request_data['img']
        filepath = convert_and_save(img_base64_data)
        object_detection_result = execute_darknet(filepath)
        return {"response": object_detection_result}

def convert_and_save(b64_string):
    base64_decoded = base64.b64decode(b64_string)
    timestamp = time.gmtime()
    filename = time.strftime("%Y_%m_%d__%H_%M_%S", timestamp) + ".jpeg"
    filepath = path.join("tmp", filename)
    with open(filepath, "wb") as fh:
        fh.write(base64_decoded)
    return filepath

def execute_darknet(img_filepath):
    darknet_command = ['./darknet', 'detect', 'cfg/yolov3.cfg', 'yolov3.weights', "../app/" + img_filepath]
    process_darknet = subprocess.Popen(darknet_command, 
                            stdout=subprocess.PIPE,
                            universal_newlines=True,
                            cwd=r'/darknet/')

    yolov3_weights_loaded = False
    result = ''
    while True:
        output = process_darknet.stdout.readline()
        print(output.strip())

        if 'Done!' in output or yolov3_weights_loaded:
            yolov3_weights_loaded = True
            result = result + output

        return_code = process_darknet.poll()
        if return_code is not None:
            print('RETURN CODE', return_code)
            # Process has finished, read rest of the output 
            for output in process_darknet.stdout.readlines():
                print(output.strip())
            break

    return result