from django.urls import path

from .views import ChatHealthView

urlpatterns = [
    path('health', ChatHealthView.as_view(), name='chat-health'),
]
