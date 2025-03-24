from django.shortcuts import render
from clinicalsApp.models import Patient, ClinicalsData
from django.views.generic import ListView, UpdateView, CreateView, DeleteView
from django.urls import reverse_lazy
# Create your views here.

class PatientListView(ListView):
    model = Patient

class PatientCreateView(CreateView):
    model = Patient
    success_url = reverse_lazy('index')
    fields = '__all__'

class PatientUpdateView(UpdateView):
    model = Patient
    success_url = reverse_lazy('index')
    fields = '__all__'

class PatientDeleteView(DeleteView):
    model = Patient
    success_url = reverse_lazy('index')

