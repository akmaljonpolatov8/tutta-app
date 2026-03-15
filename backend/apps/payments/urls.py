from django.urls import path

from .views import PaymentsHealthView

urlpatterns = [
    path('health', PaymentsHealthView.as_view(), name='payments-health'),
]
