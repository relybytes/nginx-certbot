# Use the specified nginx base image
FROM nginx:stable-alpine3.17-slim

# Set the working directory
WORKDIR /etc/nginx

# Install Certbot
RUN apk add --update --no-cache certbot
RUN apk add --no-cache certbot-nginx

# Copy configuration and necessary files
COPY ./run_with_env.sh .
COPY ./manage_domains.sh .
RUN chmod +x /etc/nginx/manage_domains.sh /etc/nginx/run_with_env.sh
RUN sed -i 's/\r//' ./run_with_env.sh

EXPOSE 80
EXPOSE 443

# Set the default command
CMD ["ash","run_with_env.sh"]