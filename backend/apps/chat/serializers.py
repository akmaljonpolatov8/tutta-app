from rest_framework import serializers


class ChatPlaceholderSerializer(serializers.Serializer):
    detail = serializers.CharField(read_only=True)
