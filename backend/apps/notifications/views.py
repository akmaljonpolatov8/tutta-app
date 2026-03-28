from django.utils import timezone
from drf_spectacular.utils import extend_schema, inline_serializer
from rest_framework import generics, permissions, response, serializers, status, throttling, views

from .models import Notification, PushDeviceToken
from .serializers import (
    NotificationSerializer,
    PushDeviceTokenRegisterSerializer,
    PushDeviceTokenUnregisterSerializer,
)


class NotificationListView(generics.ListAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    throttle_classes = [throttling.ScopedRateThrottle]
    throttle_scope = 'notifications_list'

    def get_queryset(self):
        return Notification.objects.filter(recipient=self.request.user)


class NotificationMarkReadView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    throttle_classes = [throttling.ScopedRateThrottle]
    throttle_scope = 'notifications_action'

    @extend_schema(
        request=None,
        responses={
            200: inline_serializer(
                name='NotificationMarkReadResponse',
                fields={
                    'detail': serializers.CharField(),
                },
            ),
        },
    )
    def post(self, request, pk):
        notification = generics.get_object_or_404(
            Notification,
            pk=pk,
            recipient=request.user,
        )
        if not notification.is_read:
            notification.is_read = True
            notification.read_at = timezone.now()
            notification.save(update_fields=['is_read', 'read_at'])
        return response.Response({'detail': 'Notification marked as read.'}, status=status.HTTP_200_OK)


class NotificationMarkAllReadView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    throttle_classes = [throttling.ScopedRateThrottle]
    throttle_scope = 'notifications_action'

    @extend_schema(
        request=None,
        responses={
            200: inline_serializer(
                name='NotificationMarkAllReadResponse',
                fields={
                    'detail': serializers.CharField(),
                    'updated': serializers.IntegerField(),
                },
            ),
        },
    )
    def post(self, request):
        updated = Notification.objects.filter(
            recipient=request.user,
            is_read=False,
        ).update(
            is_read=True,
            read_at=timezone.now(),
        )
        return response.Response(
            {'detail': 'Notifications marked as read.', 'updated': updated},
            status=status.HTTP_200_OK,
        )


class NotificationDeviceRegisterView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    throttle_classes = [throttling.ScopedRateThrottle]
    throttle_scope = 'notifications_action'

    @extend_schema(
        request=PushDeviceTokenRegisterSerializer,
        responses={
            200: inline_serializer(
                name='NotificationDeviceRegisterResponse',
                fields={
                    'detail': serializers.CharField(),
                },
            ),
        },
    )
    def post(self, request):
        serializer = PushDeviceTokenRegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        payload = serializer.validated_data

        token = payload['token']
        obj, _ = PushDeviceToken.objects.update_or_create(
            token=token,
            defaults={
                'user': request.user,
                'platform': payload['platform'],
                'device_id': payload.get('device_id', ''),
                'app_version': payload.get('app_version', ''),
                'locale': payload.get('locale', ''),
                'timezone': payload.get('timezone', ''),
                'is_active': True,
            },
        )
        if obj.user_id != request.user.id:
            obj.user = request.user
            obj.save(update_fields=['user', 'last_seen_at'])

        return response.Response({'detail': 'Push device registered.'}, status=status.HTTP_200_OK)


class NotificationDeviceUnregisterView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    throttle_classes = [throttling.ScopedRateThrottle]
    throttle_scope = 'notifications_action'

    @extend_schema(
        request=PushDeviceTokenUnregisterSerializer,
        responses={
            200: inline_serializer(
                name='NotificationDeviceUnregisterResponse',
                fields={
                    'detail': serializers.CharField(),
                    'updated': serializers.IntegerField(),
                },
            ),
        },
    )
    def post(self, request):
        serializer = PushDeviceTokenUnregisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        token = serializer.validated_data['token']
        updated = PushDeviceToken.objects.filter(
            user=request.user,
            token=token,
            is_active=True,
        ).update(is_active=False)
        return response.Response(
            {'detail': 'Push device unregistered.', 'updated': updated},
            status=status.HTTP_200_OK,
        )
