from .models import Notification


def create_notification(
    *,
    recipient,
    notification_type: str,
    title: str,
    body: str,
    payload: dict | None = None,
) -> Notification:
    return Notification.objects.create(
        recipient=recipient,
        type=notification_type,
        title=title,
        body=body,
        payload=payload or {},
    )
