from rest_framework import serializers


class PaymentPlaceholderSerializer(serializers.Serializer):
    detail = serializers.CharField(read_only=True)
