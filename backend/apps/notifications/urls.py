from django.urls import path

from .views import (
    NotificationDeviceRegisterView,
    NotificationDeviceUnregisterView,
    NotificationListView,
    NotificationMarkAllReadView,
    NotificationMarkReadView,
)

urlpatterns = [
    path('', NotificationListView.as_view(), name='notifications-list'),
    path('devices/register', NotificationDeviceRegisterView.as_view(), name='notifications-devices-register'),
    path('devices/unregister', NotificationDeviceUnregisterView.as_view(), name='notifications-devices-unregister'),
    path('read-all', NotificationMarkAllReadView.as_view(), name='notifications-read-all'),
    path('<int:pk>/read', NotificationMarkReadView.as_view(), name='notifications-read'),
]
