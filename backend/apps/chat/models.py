from django.db import models


class Thread(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)


class Message(models.Model):
    thread = models.ForeignKey(Thread, on_delete=models.CASCADE, related_name='messages')
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
