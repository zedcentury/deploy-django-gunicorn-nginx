#!/bin/bash

# File path
file_path="output.txt"

# Write multi-line text to file using cat and here document
cat << EOF > "$file_path"
[Unit]
Description=$filename daemon
Requires=${filename}.socket
After=network.target

[Service]
User=root
Group=www-data
WorkingDirectory=/var/www/${project}
ExecStart=/var/www/${project}/venv/bin/gunicorn \
          --access-logfile - \
          --workers 3 \
          --bind unix:/run/${filename}.sock \
          config.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

echo "Multi-line text written to $file_path"
