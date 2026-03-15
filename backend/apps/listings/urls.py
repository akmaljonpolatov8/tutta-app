from django.urls import path

from .views import ListingDetailView, ListingListCreateView

urlpatterns = [
    path('', ListingListCreateView.as_view(), name='listings-list-create'),
    path('<int:pk>', ListingDetailView.as_view(), name='listings-detail'),
]
