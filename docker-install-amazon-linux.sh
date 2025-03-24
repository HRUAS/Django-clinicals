#!/bin/bash

# Exit on any error
set -e

# Function to check if a command was successful
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed"
        exit 1
    fi
}

echo "Starting Docker setup on Amazon Linux 2023.6.20250303..."

# Update the system
echo "Updating system packages..."
sudo dnf update -y
check_status "System update"

# Install git (optional, included since it was in your original list)
echo "Installing Git..."
sudo dnf install git -y
check_status "Git installation"

# Install Docker
echo "Installing Docker..."
sudo dnf install docker -y
check_status "Docker installation"

# Start and enable Docker service
echo "Starting and enabling Docker..."
sudo systemctl start docker
check_status "Docker start"
sudo systemctl enable docker
check_status "Docker enable"

# Verify Docker version
echo "Checking Docker version..."
docker --version
check_status "Docker version check"

# Add user to Docker group
echo "Adding user to Docker group..."
sudo usermod -aG docker $USER
check_status "User modification"

# Note: Skipping newgrp docker as it starts a new shell and exits the script
echo "Note: Docker group membership updated. Please log out and log back in (or reboot) for this to take effect."

# Verify Docker is working with sudo (since group change isn’t active yet)
echo "Verifying Docker access (using sudo, as group change requires relogin)..."
sudo docker ps
check_status "Docker ps"

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
check_status "Docker Compose download"
sudo chmod +x /usr/local/bin/docker-compose
check_status "Docker Compose permissions"

# Verify Docker Compose version
echo "Checking Docker Compose version..."
docker-compose --version
check_status "Docker Compose version check"

echo "Docker and Docker Compose setup completed successfully!"
echo "ACTION REQUIRED: Please log out and log back in (or reboot) to use Docker without sudo."