import re

red = '\033[91m'
green = '\033[92m'
yellow = '\033[93m'
blue = '\033[94m'
magenta = '\033[95m'
cyan = '\033[96m'
reset = '\033[0m'

repository = input(f"{reset}Proyektning githubdagi manzili ko'rsatiladi.\nEnter github repository url: {blue}")
default_project = re.findall(r'.*/(.*)\.git', repository)[0]
project = input(f"{reset}Enter project name (default: {default_project}): {blue}") or default_project

default_db_name = project.replace('.', '_').replace('-', '_')
db_name = input(f"{reset}Enter database name (default: {default_db_name}): {blue}") or default_db_name
default_db_user = db_name + "_user"
db_user = input(f"{reset}Enter username (default: {default_db_user}): {blue}") or default_db_user
db_password = input(f"{reset}Enter password: {blue}")

debug = input(f"{reset}Debug (y/n): {blue}") == "y"
secret_key = input(f"{reset}Secret key: {blue}")
allowed_hosts = input(f"{reset}Allowed host: {blue}")
url = input(f"{reset}Url: {blue}")

socket = input(f"{reset}Socket file name (default: {project}.socket): {blue}") or project
service = input(f"{reset}Service file name (default: {project}.service): {blue}") or project
nginx_configuration_file = input(f"{reset}Nginx configuration file name (default: {project}): {blue}") or project
server_name = input(f"{reset}Server name (e.g. apple.com): {blue}")

file_name = input(f"{reset}Enter file name (default: deploy.sh): {blue}") or "deploy"
print(f"{reset}")

shell_code = f"""
#!/bin/bash

apt update
apt install python3-pip python3-dev python3-venv git libpq-dev postgresql postgresql-contrib nginx

# Create database
sudo -u postgres psql -c 'CREATE DATABASE "{db_name}";'

# Create user
sudo -u postgres psql -c "CREATE USER {db_user} WITH PASSWORD '{db_password}';"

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE {db_name} TO {db_user};"
sudo -u postgres psql -c "ALTER DATABASE {db_name} OWNER TO {db_user};"

# Enter to working directory
cd /var/www/

# Clone repository
git clone {repository} {project}

# Enter to project
cd {project}

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install requirements
pip install -r requirements.txt
pip install gunicorn psycopg2-binary

# Set values of variables in .env
echo "DEBUG={debug}" >"config/.env"
echo "SECRET_KEY={secret_key}" >>"config/.env"
echo "ALLOWED_HOSTS={allowed_hosts}" >>"config/.env"
echo "DATABASE_URL=psql://{db_user}:{db_password}@127.0.0.1:5432/{db_name}" >>"config/.env"
echo "URL={url}" >>"config/.env"

# Make migrations and migrate
python manage.py makemigrations
python manage.py migrate

# Collect static files
python manage.py collectstatic

# Deactivate virtual environment
deactivate

# Configure socket file
cat <<EOF >"/etc/systemd/system/{socket}.socket"
[Unit]
Description={socket} socket

[Socket]
ListenStream=/run/{socket}.sock

[Install]
WantedBy=sockets.target
EOF

# Configure service file
cat <<EOF >"/etc/systemd/system/{service}.service"
[Unit]
Description=$project daemon
Requires={socket}.socket
After=network.target

[Service]
User=root
Group=www-data
WorkingDirectory=/var/www/{project}
ExecStart=/var/www/{project}/venv/bin/gunicorn --access-logfile - --workers 3 --bind unix:/run/{socket}.sock config.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

# Start socket file
systemctl start {socket}.socket

# Enable socket file
systemctl enable {socket}.socket

# Reload systemd manager configuration
systemctl daemon-reload

# Restart service
systemctl restart {service}

# Configure Nginx to Proxy Pass to Gunicorn
cat <<EOF >"/etc/nginx/sites-available/{nginx_configuration_file}"
server {{
    listen 80;
    server_name {server_name};

    location = /favicon.ico {{ access_log off; log_not_found off; }}
    location /static/ {{
        root /var/www/{project};
    }}

    location / {{
        include proxy_params;
        proxy_pass http://unix:/run/{socket}.sock;
    }}
}}
EOF

ln -sF /etc/nginx/sites-available/{nginx_configuration_file} /etc/nginx/sites-enabled/

nginx -t

systemctl restart nginx
"""

with open(f"{file_name}.sh", "w") as f:
    f.write(shell_code)
