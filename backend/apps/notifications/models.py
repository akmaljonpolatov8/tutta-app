from django.conf import settings
from django.db import models


class Notification(models.Model):
    class Type(models.TextChoices):
        BOOKING_REQUEST = 'booking_request', 'Booking Request'
        BOOKING_CONFIRMED = 'booking_confirmed', 'Booking Confirmed'
        BOOKING_CANCELLED = 'booking_cancelled', 'Booking Cancelled'
        BOOKING_COMPLETED = 'booking_completed', 'Booking Completed'
        LISTING_APPROVED = 'listing_approved', 'Listing Approved'
        LISTING_REJECTED = 'listing_rejected', 'Listing Rejected'
        SYSTEM = 'system', 'System'

    recipient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications',
    )
    type = models.CharField(max_length=40, choices=Type.choices, default=Type.SYSTEM)
    title = models.CharField(max_length=160)
    body = models.TextField()
    payload = models.JSONField(default=dict, blank=True)
    is_read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['recipient', 'is_read']),
            models.Index(fields=['recipient', 'created_at']),
        ]

    def __str__(self):
        return f'{self.recipient_id} {self.type} {self.title}'


class PushDeviceToken(models.Model):
    class Platform(models.TextChoices):
        ANDROID = 'android', 'Android'
        IOS = 'ios', 'iOS'
        WEB = 'web', 'Web'

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='push_devices',
    )
    token = models.CharField(max_length=512, unique=True)
    platform = models.CharField(max_length=20, choices=Platform.choices)
    device_id = models.CharField(max_length=128, blank=True, default='')
    app_version = models.CharField(max_length=40, blank=True, default='')
    locale = models.CharField(max_length=16, blank=True, default='')
    timezone = models.CharField(max_length=64, blank=True, default='')
    is_active = models.BooleanField(default=True)
    last_seen_at = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-last_seen_at']
        indexes = [
            models.Index(fields=['user', 'is_active']),
            models.Index(fields=['platform', 'is_active']),
        ]

    def __str__(self):
        return f'{self.user_id} {self.platform} {self.token[:12]}...'
