#!/bin/bash

# JSON file path
json_file="data.json"

# Parse JSON using jq
repository=$(jq -r '.project.repository' "$json_file")
project=$(jq -r '.project.name' "$json_file")

debug=$(jq -r '.project.env.DEBUG' "$json_file")
secret_key=$(jq -r '.project.env.SECRET_KEY' "$json_file")
allowed_hosts=$(jq -r '.project.env.ALLOWED_HOSTS' "$json_file")
url=$(jq -r '.project.env.URL' "$json_file")

db_name=$(jq -r '.db.name' "$json_file")
db_user=$(jq -r '.db.user' "$json_file")
db_password=$(jq -r '.db.password' "$json_file")

# Enter to /var/www/
cd /var/www/

# Clone repository
git clone $repository

cd $project

# Create virtual environment
python3 -m venv venv
#virtualenv venv

# Activate virtual environment
source venv/bin/activate

# Install requirements
pip install -r requirements.txt

# Install gunicorn and psycopg2-binary
pip install gunicorn psycopg2-binary

# Write data to env file
# Set value of DEBUG variable
echo "DEBUG=${debug}" >"config/.env"

# Set value of SECRET_KEY variable
echo "SECRET_KEY=$secret_key" >>"config/.env"

# Set value of ALLOWED_HOSTS variable
echo "ALLOWED_HOSTS=$allowed_hosts" >>"config/.env"

# Set value of DATABASE_URL variable
echo "DATABASE_URL=psql://${db_user}:${db_password}@127.0.0.1:5432/${db_name}" >>"config/.env"

# Set value of URL variable
echo "URL=${url}" >>"config/.env"

# Make migrations and migrate
python manage.py makemigrations
python manage.py migrate

# Create super user
python manage.py createsuperuser

# Collect static files
python manage.py collectstatic

# Deactivate virtual environment
deactivate
