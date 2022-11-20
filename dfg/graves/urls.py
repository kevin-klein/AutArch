from django.urls import path, include

from . import views

urlpatterns = [
    path('', views.PublicationIndex.as_view(), name='index'),
    path('publications/<pk>/', views.PublicationDetail.as_view(), name='publication-detail'),
]
