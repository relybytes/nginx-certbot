#!/bin/ash

# Manage the domains
echo "Starting manage_domains.sh script..."
./manage_domains.sh
echo "Finished manage_domains.sh script."

# Stop the currently running Nginx service
echo "Checking if Nginx is running..."
if [ -f /var/run/nginx.pid ]; then
    echo "Stopping Nginx..."
    nginx -s stop
else
    echo "Nginx is not running. Skipping stop command."
fi

# Function to replace environment variables in template files
process_template() {
  local template="$1"
  local output_file="${template%.template}"

  # Use 'envsubst' to replace environment variables
  envsubst "$(printf '${%s} ' $(env | cut -d '=' -f 1))" < "$template" > "$output_file"

  # (Optional) You can read and do something with the config file here
  local config
  config=$(cat "$output_file")
}

iterate_directory() {
    local dir="$1"
    for item in "$dir"/* "$dir"/.*; do
        if [[ $(basename "$item") == "." || $(basename "$item") == ".." ]]; then
            # skip current and parent directory references
            continue
        fi
        if [ -d "$item" ]; then
            # Inside the process_template function
            echo "Processing folder: $item"
            iterate_directory "$item"
        elif [[ "$(basename "$item")" == *.template ]]; then
            # Inside the process_template function
            echo "Processing template: $item"
            process_template "$item"
        fi
    done
}

# Starting directory
start_dir="/etc/nginx/conf.d"
iterate_directory "$start_dir"

# Start Nginx
nginx -g "daemon off;"
