from django.contrib import admin

from .models import Notification, PushDeviceToken


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('id', 'recipient', 'type', 'title', 'is_read', 'created_at')
    list_filter = ('type', 'is_read', 'created_at')
    search_fields = ('recipient__email', 'title', 'body')


@admin.register(PushDeviceToken)
class PushDeviceTokenAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'platform', 'is_active', 'last_seen_at', 'created_at')
    list_filter = ('platform', 'is_active', 'created_at')
    search_fields = ('user__email', 'token', 'device_id')
