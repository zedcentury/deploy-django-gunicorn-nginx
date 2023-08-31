#!/bin/bash

# JSON file path
json_file="data.json"

# Parse JSON and get variable values

# Parse repository name
repository=$(jq -r '.repository' "$json_file")

# Get project name from repository name
project=$(basename "$repository" .git)

# Set database name and replace - and . to _
db_name=$(echo "$project" | tr '-' '_')
db_name=$(echo "$db_name" | tr '.' '_')

# Set database user
db_user="${db_name}_user"

# Parse password of user
db_password=$(jq -r '.db_password' "$json_file")

## Create database and set owner to database
sudo -u postgres psql -c "CREATE DATABASE \"$db_name\";"
sudo -u postgres psql -c "CREATE USER $db_user WITH PASSWORD '$db_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;"
sudo -u postgres psql -c "ALTER DATABASE $db_name OWNER TO $db_user;"

echo "Your database name: $db_name"
echo "Your database user: $db_user"
echo "Your database password: $db_password"
