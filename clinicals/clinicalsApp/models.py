from django.db import models

# Create your models here.

class Patient(models.Model):
    firstName = models.CharField(max_length=100)
    lastName = models.CharField(max_length=100)
    age = models.IntegerField()

class ClinicalsData(models.Model):
    COMPONENT_NAME = [('hw','Height/Weight'),('bp','Blood Pressure'),('heartrate','Heart Rate')]
    componentName = models.CharField(max_length=100, choices=COMPONENT_NAME)
    componentValue = models.CharField(max_length=100)
    measuredDataTime = models.DateTimeField()
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)