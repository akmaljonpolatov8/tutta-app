from rest_framework import serializers

from .models import Notification, PushDeviceToken


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = (
            'id',
            'type',
            'title',
            'body',
            'payload',
            'is_read',
            'read_at',
            'created_at',
        )
        read_only_fields = fields


class PushDeviceTokenRegisterSerializer(serializers.Serializer):
    token = serializers.CharField(max_length=512)
    platform = serializers.ChoiceField(choices=PushDeviceToken.Platform.choices)
    device_id = serializers.CharField(max_length=128, required=False, allow_blank=True)
    app_version = serializers.CharField(max_length=40, required=False, allow_blank=True)
    locale = serializers.CharField(max_length=16, required=False, allow_blank=True)
    timezone = serializers.CharField(max_length=64, required=False, allow_blank=True)


class PushDeviceTokenUnregisterSerializer(serializers.Serializer):
    token = serializers.CharField(max_length=512)
