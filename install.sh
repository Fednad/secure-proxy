#!/bin/bash

echo "🔹 Welcome to Reverse Proxy Setup!"
read -p "Enter your main domain (e.g., example.com): " DOMAIN
read -p "Enter the subdomain you want to use (e.g., login): " SUBDOMAIN
read -p "Enter your Telegram Bot Token: " BOT_TOKEN
read -p "Enter your Telegram Chat ID: " CHAT_ID

FULL_DOMAIN="$SUBDOMAIN.$DOMAIN"

echo "🔹 Installing dependencies..."
sudo apt update && sudo apt install nginx certbot python3-certbot-nginx python3-pip -y
pip3 install -r requirements.txt

echo "🔹 Setting up SSL for wildcard domain..."
sudo certbot certonly --manual --preferred-challenges=dns --email your@email.com \
  --agree-tos --no-eff-email --manual-public-ip-logging-ok \
  -d $DOMAIN -d *.$DOMAIN

echo "🔹 Configuring Nginx for subdomain..."
sudo cp reverseproxy.conf /etc/nginx/sites-available/reverseproxy
sudo sed -i "s/yourdomain.com/$FULL_DOMAIN/g" /etc/nginx/sites-available/reverseproxy
sudo ln -s /etc/nginx/sites-available/reverseproxy /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

echo "🔹 Updating Python script with Telegram credentials..."
sed -i "s/YOUR_BOT_TOKEN/$BOT_TOKEN/g" proxy.py
sed -i "s/YOUR_CHAT_ID/$CHAT_ID/g" proxy.py

# Generate the final URL
FINAL_URL="https://$FULL_DOMAIN"
echo "🔹 Sending the final URL to Telegram..."

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
     -d "chat_id=$CHAT_ID" \
     -d "text=✅ Setup complete! Your Reverse Proxy is live at: $FINAL_URL"

echo "✅ Setup complete! Your Reverse Proxy is live at: $FINAL_URL"
