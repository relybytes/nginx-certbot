#!/bin/ash

# Check if domains are provided
if [ -z "$NGINX_DOMAINS" ]; then
    echo "No domains provided. Set the NGINX_DOMAINS environment variable."
    exit 1
fi

# Install lsof if not available (optional, uncomment if needed)
# apk update && apk add lsof

# Stop the currently running Nginx service
echo "Checking if Nginx is running..."
if [ -f /var/run/nginx.pid ]; then
    echo "Stopping Nginx..."
    nginx -s stop
else
    echo "Nginx is not running. Skipping stop command."
fi

# Create a temporary Nginx configuration for the Let's Encrypt challenge
FOLDER_NGINX_CONF="/tmp/temp_www"
TEMP_NGINX_CONF="/tmp/temp_nginx.conf"
cat << EOF > $TEMP_NGINX_CONF
user nginx;
# it's common practice to run 1 => https://www.nginx.com/blog/thread-pools-boost-performance-9x/
worker_processes 1;
error_log /var/log/nginx/error.log error;
pid /run/nginx.pid;
events { worker_connections 1024; }
http {
    server {
        listen 80;
        server_name _;  # Catch-all server name

        location ~ /.well-known/acme-challenge {
            allow all;
            root $FOLDER_NGINX_CONF;  # Ensure this path is correct
        }
    }
}
EOF

# Start Nginx with the temporary configuration
echo "Starting temporary Nginx for Let's Encrypt challenge..."
nginx -c $TEMP_NGINX_CONF
echo "Starting correctly temporary Nginx for Let's Encrypt challenge..."
mkdir -p $FOLDER_NGINX_CONF
# Loop through each domain and run Certbot
for domain in $NGINX_DOMAINS; do
    echo "Checking certificate for $domain"

    # Check if a certificate already exists for the domain
    if certbot certificates | grep -q "Domains: $domain"; then
        echo "Certificate exists for $domain. Attempting renewal..."
        certbot renew --non-interactive --agree-tos --cert-name "$domain"
    else
        # Check if the folder for certificate generation exists
        if [ -d "$FOLDER_NGINX_CONF" ]; then
            echo "Creating certificate for $domain"
            certbot certonly --webroot -w $FOLDER_NGINX_CONF -d $domain --non-interactive --agree-tos -m $NGINX_DOMAINS_EMAIL_VALIDATION --redirect --expand
        else
            echo "Webroot path $FOLDER_NGINX_CONF does not exist for $domain, skipping..."
        fi
    fi
done

# Stop the temporary Nginx
echo "Stopping temporary Nginx..."
nginx -s stop

rm TEMP_NGINX_CONF
rm -rf FOLDER_NGINX_CONF

echo "Certificate creation complete."
