#!/bin/bash

# Parse JSON using jq
filename=$(jq -r '.configuration.filename' "$json_file")
server_name=$(jq -r '.configuration.server_name' "$json_file")

# Back to main
cd

# Configure socket file
cat <<EOF >"/etc/systemd/system/${filename}.socket"
[Unit]
Description=$filename socket

[Socket]
ListenStream=/run/${filename}.sock

[Install]
WantedBy=sockets.target
EOF

# Configure service file
cat <<EOF >"/etc/systemd/system/${filename}.service"
[Unit]
Description=$filename daemon
Requires=${filename}.socket
After=network.target

[Service]
User=root
Group=www-data
WorkingDirectory=/var/www/${filename}
ExecStart=/var/www/${filename}/venv/bin/gunicorn \
          --access-logfile - \
          --workers 3 \
          --bind unix:/run/${filename}.sock \
          config.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

# Start socket file
systemctl start ${filename}.socket

# Enable socket file
systemctl enable ${filename}.socket

# Reload systemd manager configuration
systemctl daemon-reload

# Restart service
systemctl restart $filename

# Configure Nginx to Proxy Pass to Gunicorn
cat <<EOF >"/etc/nginx/sites-available/${filename}"
server {
    listen 80;
    server_name $server_name;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /var/www/$filename;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/run/${filename}.sock;
    }
}
EOF

ln -s /etc/nginx/sites-available/$filename /etc/nginx/sites-enabled

nginx -t

systemctl restart nginx
