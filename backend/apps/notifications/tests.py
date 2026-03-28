from rest_framework import status
from rest_framework.test import APITestCase

from apps.users.models import User
from .models import Notification, PushDeviceToken


class NotificationApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email='notify-user@example.com',
            password='StrongPass123!',
            first_name='Notify',
            last_name='User',
            role='guest',
        )
        self.other_user = User.objects.create_user(
            email='notify-other@example.com',
            password='StrongPass123!',
            first_name='Notify',
            last_name='Other',
            role='guest',
        )

    def test_user_lists_own_notifications(self):
        Notification.objects.create(
            recipient=self.user,
            type='system',
            title='Welcome',
            body='Hello',
        )
        Notification.objects.create(
            recipient=self.other_user,
            type='system',
            title='Hidden',
            body='Should not appear',
        )

        self.client.force_authenticate(user=self.user)
        response = self.client.get('/api/notifications/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)
        self.assertEqual(response.data['results'][0]['title'], 'Welcome')

    def test_user_marks_notification_read(self):
        note = Notification.objects.create(
            recipient=self.user,
            type='system',
            title='Ping',
            body='Message',
        )
        self.client.force_authenticate(user=self.user)
        response = self.client.post(f'/api/notifications/{note.id}/read', {}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        note.refresh_from_db()
        self.assertTrue(note.is_read)

    def test_user_marks_all_notifications_read(self):
        Notification.objects.create(
            recipient=self.user,
            type='system',
            title='A',
            body='A body',
        )
        Notification.objects.create(
            recipient=self.user,
            type='system',
            title='B',
            body='B body',
        )
        self.client.force_authenticate(user=self.user)
        response = self.client.post('/api/notifications/read-all', {}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['updated'], 2)

    def test_user_registers_and_unregisters_push_device(self):
        self.client.force_authenticate(user=self.user)

        register_response = self.client.post(
            '/api/notifications/devices/register',
            {
                'token': 'fcm_token_123',
                'platform': 'android',
                'device_id': 'device-1',
                'app_version': '1.0.0',
                'locale': 'ru',
                'timezone': 'Asia/Tashkent',
            },
            format='json',
        )
        self.assertEqual(register_response.status_code, status.HTTP_200_OK)
        self.assertEqual(PushDeviceToken.objects.filter(user=self.user).count(), 1)
        self.assertTrue(PushDeviceToken.objects.get(token='fcm_token_123').is_active)

        unregister_response = self.client.post(
            '/api/notifications/devices/unregister',
            {'token': 'fcm_token_123'},
            format='json',
        )
        self.assertEqual(unregister_response.status_code, status.HTTP_200_OK)
        self.assertEqual(unregister_response.data['updated'], 1)
        self.assertFalse(PushDeviceToken.objects.get(token='fcm_token_123').is_active)
