# Django-clinicals

# add database container

docker run -d --name mysql-container -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 mysql:latest

docker exec -it mysql-container mysql -uroot -ppassword
CREATE DATABASE clinicals;
SHOW DATABASES;

use clinicals;
select * from clinicalsApp_clinicalsdata;
select * from clinicalsApp_patient;

# install docker and docker compose in amazon linux default image: Amazon Linux 2023.6.20250303

sudo dnf update -y
sudo dnf install git -y
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker
docker --version
sudo usermod -aG docker $USER
newgrp docker
docker ps
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# install minukube in this amazon linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
minikube version
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
minikube start --driver=docker
minikube status


# Building the app image

docker build -t django-clinicals .

docker run -d -p 8000:8000 --name django-app --network clinicals-network -e DB_HOST="mysql-container" django-clinicals

# push image to docker hub

 docker login -u akhil1993
 docker push akhil1993/django-app:latest

# Install Kubernetes in codespace

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
docker --version
minikube start --driver=docker
minikube status
kubectl get nodes


# for running in amazon linux
1) install git
sudo dnf install git -y

2) create keys
ssh-keygen -t rsa

3) add public key in github


if connectivity not in ec2 :
kubectl port-forward svc/django-service 8000:8000 --address=0.0.0.0


# wokring with gcloud
1) install gloud
2) login using command gcloud login
3) connec to GKE with the command