#!/bin/bash

# JSON file path
json_file="data.json"

# Parse repository name
repository=$(jq -r '.repository' "$json_file")

# Get project name from repository name
project=$(basename "$repository" .git)

# Server name
server_name=$(jq -r '.url' "$json_file")

# Back to main
cd

# Configure socket file
cat <<EOF >"/etc/systemd/system/${project}.socket"
[Unit]
Description=$project socket

[Socket]
ListenStream=/run/${project}.sock

[Install]
WantedBy=sockets.target
EOF

# Configure service file
cat <<EOF >"/etc/systemd/system/${project}.service"
[Unit]
Description=$project daemon
Requires=${project}.socket
After=network.target

[Service]
User=root
Group=www-data
WorkingDirectory=/var/www/${project}
ExecStart=/var/www/${project}/venv/bin/gunicorn --access-logfile - --workers 3 --bind unix:/run/${project}.sock config.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

# Start socket file
systemctl start ${project}.socket

# Enable socket file
systemctl enable ${project}.socket

# Reload systemd manager configuration
systemctl daemon-reload

# Restart service
systemctl restart $project

# Configure Nginx to Proxy Pass to Gunicorn
cat <<EOF >"/etc/nginx/sites-enabled/${project}"
server {
    listen 80;
    server_name $server_name;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /var/www/$project;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/run/${project}.sock;
    }
}
EOF

#ln -sF /etc/nginx/sites-available/$project /etc/nginx/sites-enabled/

nginx -t

systemctl restart nginx
