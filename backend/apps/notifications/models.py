from django.db import models
from django.conf import settings


class Notification(models.Model):
    """
    In-app notification model. Delivered via WebSocket (Django Channels).
    """
    TYPE_OFFER = 'offer'
    TYPE_COUNTER = 'counter'
    TYPE_ACCEPTED = 'accepted'
    TYPE_DECLINED = 'declined'
    TYPE_REVIEW = 'review'
    TYPE_SYSTEM = 'system'
    TYPE_CHOICES = [
        (TYPE_OFFER, 'New Offer'),
        (TYPE_COUNTER, 'Counter Offer'),
        (TYPE_ACCEPTED, 'Offer Accepted'),
        (TYPE_DECLINED, 'Offer Declined'),
        (TYPE_REVIEW, 'New Review'),
        (TYPE_SYSTEM, 'System'),
    ]

    recipient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    notification_type = models.CharField(max_length=10, choices=TYPE_CHOICES)
    title = models.CharField(max_length=200)
    body = models.TextField()
    is_read = models.BooleanField(default=False)
    related_offer_id = models.IntegerField(null=True, blank=True)
    related_agreement_id = models.IntegerField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.notification_type} → {self.recipient.full_name}'

    def mark_read(self):
        self.is_read = True
        self.save(update_fields=['is_read'])
