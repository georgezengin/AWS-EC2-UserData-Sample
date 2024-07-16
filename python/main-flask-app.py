from flask import Flask, request
import os

app = Flask(__name__)

@app.route('/')
def index():
    return open('index.html').read()

@app.route('/python')
def python_shell():
    return os.popen('python3').read()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
