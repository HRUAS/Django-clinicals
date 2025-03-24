# Django-clinicals

# add database container

docker run -d --name mysql-container -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 mysql:latest

docker exec -it mysql-container mysql -uroot -ppassword
CREATE DATABASE clinicals;
SHOW DATABASES;

use clinicals;
select * from clinicalsApp_clinicalsdata;
select * from clinicalsApp_patient;


# Building the app image

docker build -t django-clinicals .

docker run -d -p 8000:8000 --name django-app --network clinicals-network -e DB_HOST="mysql-container" django-clinicals

# push image to docker hub


# Install Kubernetes

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