from rest_framework import generics, permissions

from .models import Listing
from .serializers import ListingCreateSerializer, ListingSerializer


class ListingListCreateView(generics.ListCreateAPIView):
    queryset = Listing.objects.select_related('host').prefetch_related('images').filter(is_active=True)
    filterset_fields = ('listing_type', 'location')
    search_fields = ('title', 'description', 'location')
    ordering_fields = ('price_per_night', 'created_at')

    def get_permissions(self):
        if self.request.method == 'POST':
            return [permissions.IsAuthenticated()]
        return [permissions.AllowAny()]

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return ListingCreateSerializer
        return ListingSerializer


class ListingDetailView(generics.RetrieveAPIView):
    queryset = Listing.objects.select_related('host').prefetch_related('images').filter(is_active=True)
    serializer_class = ListingSerializer
    permission_classes = [permissions.AllowAny]
