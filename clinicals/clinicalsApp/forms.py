from django import forms
from clinicalsApp.models import ClinicalsData, Patient

class PatientForm(forms.ModelForm):
    class Meta:
        form = Patient
        fields = '__all__'

class ClinicalsDataForm(forms.ModelForm):
    class Meta:
        form = ClinicalsData
        fields = '__all__'
