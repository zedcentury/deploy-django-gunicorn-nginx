#!/bin/bash

# JSON file path
json_file="data.json"

# Parse JSON using jq
db_name=$(jq -r '.db.name' "$json_file")
db_user=$(jq -r '.db.user' "$json_file")
db_password=$(jq -r '.db.password' "$json_file")

# Create database and set owner to database
# Run psql command to create a database
sudo -u postgres psql -c "CREATE DATABASE $db_name;"
sudo -u postgres psql -c "CREATE USER $db_user WITH PASSWORD '$db_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;"
sudo -u postgres psql -c "ALTER DATABASE $db_name OWNER TO $db_user;"
