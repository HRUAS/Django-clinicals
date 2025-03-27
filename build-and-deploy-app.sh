#!/bin/bash

# Define color codes
COLOR='\033[0;33m'
NC='\033[0m' # No Color (reset)

# Check if tag argument is provided
if [ $# -ne 1 ]; then
    echo -e "${COLOR}Usage: $0 <tag>${NC}"
    echo -e "${COLOR}Example: $0 v1.0.0${NC}"
    exit 1
fi

# Store the tag from command line argument
TAG=$1
REPO_NAME="django-app"
K8S_YAML_FILE="deploy-in-kubernetes.yaml"
COMPOSE_YAML_FILE="docker-compose.yaml"
SERVICE_NAME="django-service"
NAMESPACE="django-prod"
DEPLOYMENT_NAME="django-deployment" # Adjust this to match your Deployment name in deploy-in-kubernetes.yaml

# Prompt for Docker Hub credentials
read -p "Enter Docker Hub username: " DOCKERHUB_USERNAME
read -p "Enter Docker Hub password (will be visible): " DOCKERHUB_PASSWORD
echo "" # New line after password input

# Build the Docker image with the specified tag
echo -e "${COLOR}Building Docker image with tag: $TAG${NC}"
docker build -t $DOCKERHUB_USERNAME/$REPO_NAME:$TAG .

# Check if the build was successful
if [ $? -ne 0 ]; then
    echo -e "${COLOR}Failed to build the image${NC}"
    exit 1
fi

# Push the image to Docker Hub
echo -e "${COLOR}Pushing image to Docker Hub...${NC}"
docker push $DOCKERHUB_USERNAME/$REPO_NAME:$TAG

# Check if the push was successful
if [ $? -ne 0 ]; then
    echo -e "${COLOR}Failed to push the image to Docker Hub${NC}"
    echo -e "${COLOR}Make sure the credentials are correct and you have push permissions${NC}"
    exit 1
fi

# Get JWT token for Docker Hub API
echo -e "${COLOR}Authenticating with Docker Hub API...${NC}"
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d "{\"username\": \"$DOCKERHUB_USERNAME\", \"password\": \"$DOCKERHUB_PASSWORD\"}" https://hub.docker.com/v2/users/login/ | jq -r .token)

if [ -z "$TOKEN" ]; then
    echo -e "${COLOR}Failed to authenticate with Docker Hub API${NC}"
    echo -e "${COLOR}Please verify your credentials${NC}"
    exit 1
fi

# Get list of existing tags
echo -e "${COLOR}Fetching existing tags...${NC}"
TAGS=$(curl -s -H "Authorization: JWT $TOKEN" "https://hub.docker.com/v2/repositories/$DOCKERHUB_USERNAME/$REPO_NAME/tags/?page_size=100" | jq -r '.results[].name')

# Delete all tags except the new one
echo -e "${COLOR}Deleting previous tags...${NC}"
for OLD_TAG in $TAGS; do
    if [ "$OLD_TAG" != "$TAG" ]; then
        echo -e "${COLOR}Deleting tag: $OLD_TAG${NC}"
        curl -s -X DELETE -H "Authorization: JWT $TOKEN" "https://hub.docker.com/v2/repositories/$DOCKERHUB_USERNAME/$REPO_NAME/tags/$OLD_TAG/"
        if [ $? -eq 0 ]; then
            echo -e "${COLOR}Successfully deleted tag: $OLD_TAG${NC}"
        else
            echo -e "${COLOR}Failed to delete tag: $OLD_TAG${NC}"
        fi
    fi
done

echo -e "${COLOR}Successfully built and pushed image: $DOCKERHUB_USERNAME/$REPO_NAME:$TAG${NC}"
echo -e "${COLOR}Previous tags have been cleaned up${NC}"

echo "========================================================================================================================="
echo "=========================================== IMAGE BUILD AND UPLOAD COMPLETED ============================================"
echo "========================================================================================================================="
echo ""
echo "========================================================================================================================="
echo "=========================================== STARTING KUBERNETES DEPLOYMENT =============================================="
echo "========================================================================================================================="
echo ""
# Update the Kubernetes YAML file with the new tag
echo -e "${COLOR}Updating Kubernetes YAML file with new tag: $TAG${NC}"
if [ -f "$K8S_YAML_FILE" ]; then
    # Replace the image tag in the Kubernetes YAML file
    sed -i "s|image: .*/$REPO_NAME:.*|image: $DOCKERHUB_USERNAME/$REPO_NAME:$TAG|" "$K8S_YAML_FILE"
    if [ $? -eq 0 ]; then
        echo -e "${COLOR}Successfully updated $K8S_YAML_FILE with image: $DOCKERHUB_USERNAME/$REPO_NAME:$TAG${NC}"
    else
        echo -e "${COLOR}Failed to update $K8S_YAML_FILE${NC}"
        exit 1
    fi
else
    echo -e "${COLOR}Error: $K8S_YAML_FILE not found${NC}"
    exit 1
fi

# Update the Docker Compose YAML file with the new tag
echo -e "${COLOR}Updating Docker Compose YAML file with new tag: $TAG${NC}"
if [ -f "$COMPOSE_YAML_FILE" ]; then
    # Replace the image tag in the Docker Compose YAML file
    sed -i "s|image: .*/$REPO_NAME:.*|image: $DOCKERHUB_USERNAME/$REPO_NAME:$TAG|" "$COMPOSE_YAML_FILE"
    if [ $? -eq 0 ]; then
        echo -e "${COLOR}Successfully updated $COMPOSE_YAML_FILE with image: $DOCKERHUB_USERNAME/$REPO_NAME:$TAG${NC}"
    else
        echo -e "${COLOR}Failed to update $COMPOSE_YAML_FILE${NC}"
        exit 1
    fi
else
    echo -e "${COLOR}Error: $COMPOSE_YAML_FILE not found${NC}"
    exit 1
fi

# Create the namespace if it doesn't exist
echo -e "${COLOR}Ensuring namespace $NAMESPACE exists...${NC}"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
if [ $? -eq 0 ]; then
    echo -e "${COLOR}Namespace $NAMESPACE is ready${NC}"
else
    echo -e "${COLOR}Failed to create or verify namespace $NAMESPACE${NC}"
    exit 1
fi

# # Apply the updated Kubernetes YAML file
# echo -e "${COLOR}Checking if deployment exists before deletion...${NC}"
# kubectl get -f "$K8S_YAML_FILE" -n "$NAMESPACE" > /dev/null 2>&1
# if [ $? -eq 0 ]; then
#     echo -e "${COLOR}Deleting existing deployment...${NC}"
#     kubectl delete -f "$K8S_YAML_FILE" -n "$NAMESPACE"
#     if [ $? -eq 0 ]; then
#         echo -e "${COLOR}Successfully deleted the deployment using file $K8S_YAML_FILE${NC}"
#     else
#         echo -e "${COLOR}Failed to delete deployment using the file $K8S_YAML_FILE${NC}"
#         exit 1
#     fi
# else
#     echo -e "${COLOR}No existing deployment found for $K8S_YAML_FILE, skipping deletion${NC}"
# fi

# Apply the updated Kubernetes YAML file
echo -e "${COLOR}Applying updated Kubernetes YAML file...${NC}"
kubectl apply -f "$K8S_YAML_FILE" -n "$NAMESPACE"
if [ $? -eq 0 ]; then
    echo -e "${COLOR}Successfully applied $K8S_YAML_FILE${NC}"
else
    echo -e "${COLOR}Failed to apply $K8S_YAML_FILE${NC}"
    exit 1
fi

# Wait for the Deployment rollout to complete
echo -e "${COLOR}Waiting for Deployment rollout to complete...${NC}"
kubectl rollout status deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"
if [ $? -eq 0 ]; then
    echo -e "${COLOR}Deployment rollout completed successfully${NC}"
else
    echo -e "${COLOR}Deployment rollout failed${NC}"
    exit 1
fi

# Watch the service until EXTERNAL-IP is assigned
echo -e "${COLOR}Watching service $SERVICE_NAME for EXTERNAL-IP...${NC}"
while true; do
    EXTERNAL_IP=$(kubectl get service "$SERVICE_NAME" -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ -z "$EXTERNAL_IP" ] || [ "$EXTERNAL_IP" = "<pending>" ]; then
        echo -e "${COLOR}EXTERNAL-IP is still pending...${NC}"
        sleep 5 # Check every 5 seconds
    else
        echo -e "${COLOR}EXTERNAL-IP assigned: $EXTERNAL_IP${NC}"
        echo "Application URL: http://$EXTERNAL_IP:8000"
        break
    fi
done
