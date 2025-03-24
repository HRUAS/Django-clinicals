# Django-clinicals

<!-- add database container -->

docker run -d --name mysql-container -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 mysql:latest

docker exec -it mysql-container mysql -uroot -ppassword
CREATE DATABASE clinicals;
SHOW DATABASES;

use clinicals;
select * from clinicalsApp_clinicalsdata;
select * from clinicalsApp_patient;


<!-- Building the app image -->

docker build -t django-clinicals .

docker run -d -p 8000:8000 --name django-app --network clinicals-network -e DB_HOST="mysql-container" django-clinicals