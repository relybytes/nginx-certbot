# NGINX and Certbot Integration

This repository contains a setup that integrates NGINX with Certbot for automated management of SSL/TLS certificates. It's designed to simplify the process of creating and renewing certificates, ensuring secure connections for your domains.

## Overview

The integration of NGINX and Certbot in this repository automates the creation and renewal of SSL/TLS certificates. This solution is ideal for those seeking a hassle-free way to handle HTTPS encryption for their web services.

## Features

- **Automatic Certificate Management**: Seamlessly handles the creation and renewal of SSL/TLS certificates for your domains.
- **NGINX Integration**: Configured to work with NGINX, providing a robust web server solution with SSL support.
- **Docker Compatibility**: Designed to be run in a Docker environment, ensuring easy deployment and scalability.

## Usage

To use this setup, you need to specify a couple of environment variables and ensure the persistence of the certificates.

### Environment Variables

Set the following environment variables:

- `NGINX_DOMAINS`: A list of domains for which the certificates will be managed. Format: `domain1.com, domain2.com`.
- `NGINX_DOMAINS_EMAIL_VALIDATION`: The email address used for certificate registration and urgent renewal notifications.

### Persistence of Certificates

To ensure that certificates persist across container restarts and rebuilds, mount a volume to `/etc/letsencrypt` in your Docker container:

    ```yaml
    volumes:
      - volume_letsencrypt_folder:/etc/letsencrypt
    ```

This volume stores all Certbot-generated certificates and configurations, safeguarding them from data loss.

## Installation

To use this you need only docker.

## Contributing

See the Relybytes Contributing indications.

## License

This project is open source and available under the [MIT License](LICENSE).

---

For more information and detailed configuration instructions, refer to the official NGINX and Certbot documentation.
