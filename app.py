from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return '<h1>Cloudops vibes activated!</h1><p>This is my Flask app running on EC2. Bow down to my automation skills.</p>'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000
