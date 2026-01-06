#!/bin/bash

# Start time
START_TIME=$(date +%s)

# Define Unity package root path (Update this path based on your actual directory)
UNITY_PACKAGE_ROOT_PATH="../unity-package"

# Set git repo branch name
GIT_BRANCH_NAME=master
# Example:
# v0.0.1 or v0.0.2

#=============================================================================
# Set environment variables
# Below is the essential configuration that must be adjusted to suit your environment.
# If you are behind NAT and using port redirection, ensure you enter your public IP, not the private IP.
# Also, do not include a trailing slash (/) at the end of the URL.
IP_ADDRESS="http://[Your_IP_Address]"
# Example: (Use public IP, DON'T use private IP)
# IP_ADDRESS="http://123.11.22.33"

# You can enter your company information here, and it will be displayed on the dashboard.
COMPANY_NAME="[Company_Name]"
COMPANY_URL="[Company_Website_URL]"
# Example:
# COMPANY_NAME="Netswitch Inc."
# COMPANY_URL="https://netswitch.net"

#=============================================================================
# Below is the critical connection setting. Do not modify it unless you are an advanced user.
FRONTEND_PORT=8081
BACKEND_PORT=3006

MONGO_DB_HOST=127.0.0.1
MONGO_DB_PORT=27017
MONGO_DB_NAME=unity
MONGO_DB_DUMP_DIR=./dump/database

# Secure database => https://www.digitalocean.com/community/tutorials/how-to-secure-mongodb-on-ubuntu-20-04
# Use mongosh if mongo not working
MONGO_DB_SECURED=false # Enable (true|false) if mongo database is secure
MONGO_DB_USER=""
MONGO_DB_PASSWORD=""
MONGO_DB_AUTH=""

# Set to "true" or "false" for Blank (true) data on server
IS_EMPTY_BLANK_DATA_DISPLAY="false"

#=============================================================================
# Function to print descriptions in color
print_yellow() {
    echo ""
    echo -e "\033[1;33m========================================================\033[0m"
    echo -e "\033[1;33m $1\033[0m"
    echo -e "\033[1;33m========================================================\033[0m"
}

print_green() {
    echo -e "\033[1;32m========================================================\033[0m"
    echo -e "\033[1;32m -- $1\033[0m"
    echo -e "\033[1;32m========================================================\033[0m"
}

print_red() {
    echo -e "\033[1;31m========================================================\033[0m"
    echo -e "\033[1;31m $1\033[0m"
    echo -e "\033[1;31m========================================================\033[0m"
}

# Function to check for errors and exit
handle_error() {
  local message="$1"
  print_red "$message"
  echo ""
  read -p "Press Enter to exit..."
  exit 1
}

#=============================================================================
# Checking if Git is installed
print_yellow "Checking if Git is installed..."
if ! command -v git >/dev/null 2>&1; then
    print_green "Git is not installed. Installing Git..."
    sudo apt update -y || handle_error "Failed to update apt package list."
    sudo apt install -y git || handle_error "Failed to install Git."
    print_green "Git installation completed successfully."
else
    print_green "Git is already installed."
fi

#=============================================================================
# Check for .git directory
print_yellow "Check for .git directory"
if [ ! -d ".git" ]; then
    print_green "No .git directory found. Initializing repository..."
    git init || handle_error "Failed to initialize Git repository."
    git remote add origin https://github.com/unityri/unity || handle_error "Failed to add remote origin."
fi

# Configure Git safe directory to avoid ownership issues
print_yellow "Configuring Git safe directory..."
git config --global --add safe.directory "$(pwd)" 2>/dev/null || true

#=============================================================================
# Fetching the latest repository changes
print_yellow "Fetching the latest repository changes"

git fetch --depth=1 origin ${GIT_BRANCH_NAME} || handle_error "Failed to fetch from remote repository."
git checkout ${GIT_BRANCH_NAME} 2>/dev/null || git checkout -b ${GIT_BRANCH_NAME} origin/${GIT_BRANCH_NAME} || handle_error "Failed to checkout branch."
git reset --hard origin/${GIT_BRANCH_NAME} || handle_error "Failed to reset branch."

#=============================================================================
# Set 777 permission for Unity package root path
print_yellow "Setting 0777 permissions for Unity package directory..."
if [ -d "$UNITY_PACKAGE_ROOT_PATH" ]; then
    sudo chmod -R 0777 "$UNITY_PACKAGE_ROOT_PATH" || handle_error "Failed to set permissions."
else
    handle_error "Unity package root path does not exist: $UNITY_PACKAGE_ROOT_PATH"
fi

#=============================================================================
# Export environment variables
print_yellow "Exporting environment variables"
export FRONTEND_PORT
export BACKEND_PORT
export MONGO_DB_HOST
export MONGO_DB_PORT
export MONGO_DB_NAME
export MONGO_DB_DUMP_DIR
export MONGO_DB_SECURED
export MONGO_DB_USER
export MONGO_DB_PASSWORD
export MONGO_DB_AUTH

# Construct URLs
FRONTEND_WEB_URL="${IP_ADDRESS}:${FRONTEND_PORT}"
BACKEND_API_URL="${IP_ADDRESS}:${BACKEND_PORT}"

#=============================================================================
# Define env files
ROOT_ENV_FILE="./.env"
BACKEND_ENV_FILE="./backend/.env"
FRONTEND_ENV_FILE="./frontend/.env"

# Function to update .env files
update_environment_file() {
    local env_file=$1
    local key=$2
    local value=$3

    [ ! -f "$env_file" ] && touch "$env_file"

    if grep -q "^$key=" "$env_file"; then
        sed -i "s|^$key=.*|$key=$value|" "$env_file"
    else
        echo "$key=$value" >> "$env_file"
    fi
}

#=============================================================================
# Update root .env
print_yellow "Updating root .env file..."
update_environment_file "$ROOT_ENV_FILE" "FRONTEND_PORT" "$FRONTEND_PORT"
update_environment_file "$ROOT_ENV_FILE" "BACKEND_PORT" "$BACKEND_PORT"
update_environment_file "$ROOT_ENV_FILE" "MONGO_DB_HOST" "$MONGO_DB_HOST"
update_environment_file "$ROOT_ENV_FILE" "MONGO_DB_PORT" "$MONGO_DB_PORT"
update_environment_file "$ROOT_ENV_FILE" "MONGO_DB_NAME" "$MONGO_DB_NAME"
update_environment_file "$ROOT_ENV_FILE" "MONGO_DB_DUMP_DIR" "$MONGO_DB_DUMP_DIR"
update_environment_file "$ROOT_ENV_FILE" "MONGO_DB_SECURED" "$MONGO_DB_SECURED"
update_environment_file "$ROOT_ENV_FILE" "MONGO_DB_USER" "$MONGO_DB_USER"
update_environment_file "$ROOT_ENV_FILE" "MONGO_DB_PASSWORD" "$MONGO_DB_PASSWORD"
update_environment_file "$ROOT_ENV_FILE" "MONGO_DB_AUTH" "$MONGO_DB_AUTH"
update_environment_file "$ROOT_ENV_FILE" "REACT_APP_IS_EMPTY_BLANK_DATA_DISPLAY" "$IS_EMPTY_BLANK_DATA_DISPLAY"

#=============================================================================
# Update backend .env
print_yellow "Updating backend .env file..."
update_environment_file "$BACKEND_ENV_FILE" "FRONT_WEB_URL" "$FRONTEND_WEB_URL"
update_environment_file "$BACKEND_ENV_FILE" "PORT" "$BACKEND_PORT"
update_environment_file "$BACKEND_ENV_FILE" "DATABASE_NAME" "$MONGO_DB_NAME"
update_environment_file "$BACKEND_ENV_FILE" "DB_PORT" "$MONGO_DB_PORT"
update_environment_file "$BACKEND_ENV_FILE" "DATABASE_USER" "$MONGO_DB_USER"
update_environment_file "$BACKEND_ENV_FILE" "DATABASE_PASSWORD" "$MONGO_DB_PASSWORD"
update_environment_file "$BACKEND_ENV_FILE" "DATABASE_AUTH" "$MONGO_DB_AUTH"
update_environment_file "$BACKEND_ENV_FILE" "BACK_UNITY_URL" "$BACKEND_API_URL"

#=============================================================================
# Update frontend .env
print_yellow "Updating frontend .env file..."
update_environment_file "$FRONTEND_ENV_FILE" "REACT_APP_BACKEND_REST_API_URL" "$BACKEND_API_URL"
update_environment_file "$FRONTEND_ENV_FILE" "PORT" "$FRONTEND_PORT"
update_environment_file "$FRONTEND_ENV_FILE" "REACT_APP_COMPANY_NAME" "$COMPANY_NAME"
update_environment_file "$FRONTEND_ENV_FILE" "REACT_APP_COMPANY_URL" "$COMPANY_URL"
update_environment_file "$FRONTEND_ENV_FILE" "REACT_APP_IS_EMPTY_BLANK_DATA_DISPLAY" "$IS_EMPTY_BLANK_DATA_DISPLAY"

print_green "Updated .env files successfully."

#=============================================================================
# Mongo DB Import
print_yellow "Executing database import script..."
[ -f ./mongoImport.sh ] && bash ./mongoImport.sh || print_yellow "mongoImport.sh not found or failed."

#=============================================================================
# Install NGINX
print_yellow "Check if NGINX is installed."
if command -v nginx >/dev/null 2>&1; then
    print_green "NGINX is already installed."
else
    print_green "NGINX is not installed. Installing NGINX..."
    sudo apt update -y || handle_error "Failed to update apt package list for NGINX installation."
    sudo apt install -y nginx || handle_error "Failed to install NGINX."
    sudo systemctl enable nginx || handle_error "Failed to enable NGINX service."
    sudo systemctl start nginx || handle_error "Failed to start NGINX service."
    print_green "NGINX installation completed successfully."
fi

# Check if NGINX is running
print_yellow "Check if NGINX is running..."
if systemctl is-active --quiet nginx; then
    print_green "NGINX is running."
else
    print_green "NGINX is NOT running. Restarting..."
    sudo systemctl restart nginx || handle_error "Failed to restart NGINX service."
    print_green "NGINX restarted successfully."
fi

#=============================================================================
# Install Docker and Docker Compose
print_yellow "Check if Docker is installed."
if command -v docker >/dev/null 2>&1; then
    print_green "Docker is already installed."
else
    print_green "Docker is not installed. Installing Docker..."

    # Update package list and install dependencies
    sudo apt update -y || handle_error "Failed to update apt package list for Docker installation."
    sudo apt install -y ca-certificates curl gnupg || handle_error "Failed to install dependencies for Docker."

    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings || handle_error "Failed to create directory for Docker GPG key."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null || handle_error "Failed to download Docker GPG key."
    sudo chmod a+r /etc/apt/keyrings/docker.asc || handle_error "Failed to set permissions on Docker GPG key."

    # Set up the Docker repository
    echo "deb [signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || handle_error "Failed to add Docker repository."

    # Update package list again
    sudo apt update -y || handle_error "Failed to update apt package list after adding Docker repository."

    # Install Docker packages
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || handle_error "Failed to install Docker packages."

    # Start and enable Docker service
    sudo systemctl start docker || handle_error "Failed to start Docker service."
    sudo systemctl enable docker || handle_error "Failed to enable Docker service."

    print_green "Docker installed successfully."
fi

# Ensure Docker service is running
print_yellow "Check if Docker is running..."
if systemctl is-active --quiet docker; then
    print_green "Docker service is running."
else
    print_green "Docker service is NOT running. Starting Docker..."
    sudo systemctl start docker || handle_error "Failed to start Docker service."
    print_green "Docker started successfully."
fi

#=============================================================================
# Run Docker Compose
print_yellow "Running Docker Compose..."
sudo docker compose down 2>/dev/null || sudo docker-compose down 2>/dev/null || true
sudo docker compose up --build -d 2>/dev/null || sudo docker-compose up --build -d || handle_error "Docker Compose failed."

#=============================================================================
# Finish
END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))

print_yellow "Installation completed!"
print_yellow "Execution time: ${ELAPSED_TIME} seconds"
print_yellow "Access the Unity portal at $FRONTEND_WEB_URL"
