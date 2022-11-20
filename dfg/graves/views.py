from django.shortcuts import render
from django.http import HttpResponse
from graves.models import Publication, Grave
from django.views import generic
from django.views.generic.detail import DetailView

class PublicationIndex(generic.ListView):
    template_name = 'publications/index.html'
    context_object_name = 'publications'

    def get_queryset(self):
        return Publication.objects.all()

class PublicationDetail(DetailView):
    model = Publication
    template_name = 'publications/show.html'
