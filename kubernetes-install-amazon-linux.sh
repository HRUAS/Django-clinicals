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

echo "Starting Kubernetes setup on Amazon Linux 2023.6.20250303..."

# Update the system (recommended even if done in Docker script)
echo "Updating system packages..."
sudo dnf update -y
check_status "System update"

# Install Minikube
echo "Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
check_status "Minikube download"
sudo install minikube-linux-amd64 /usr/local/bin/minikube
check_status "Minikube installation"
rm minikube-linux-amd64
check_status "Minikube cleanup"

# Verify Minikube version
echo "Checking Minikube version..."
minikube version
check_status "Minikube version check"

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
check_status "kubectl download"
chmod +x kubectl
check_status "kubectl permissions"
sudo mv kubectl /usr/local/bin/
check_status "kubectl move"

# Verify kubectl version
echo "Checking kubectl version..."
kubectl version --client
check_status "kubectl version check"

# Start Minikube with Docker driver
echo "Starting Minikube with Docker driver..."
minikube start --driver=docker
check_status "Minikube start"

# Check Minikube status
echo "Checking Minikube status..."
minikube status
check_status "Minikube status"

echo "Kubernetes setup (Minikube and kubectl) completed successfully!"