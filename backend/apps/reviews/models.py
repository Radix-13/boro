from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator


class Review(models.Model):
    """
    Post-rental review. Encapsulates rating + text + trust dimensions.
    Reviewer rates the reviewee after a completed rental.
    """
    reviewer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='reviews_given'
    )
    reviewee = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='reviews_received'
    )
    agreement = models.OneToOneField(
        'rentals.RentalAgreement',
        on_delete=models.CASCADE,
        related_name='review'
    )
    item = models.ForeignKey(
        'items.Item',
        on_delete=models.CASCADE,
        related_name='reviews'
    )
    rating = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    comment = models.TextField(blank=True)
    # Reputation dimensions
    is_reliable = models.BooleanField(null=True, blank=True)
    was_on_time = models.BooleanField(null=True, blank=True)
    good_condition = models.BooleanField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'reviews'
        ordering = ['-created_at']
        unique_together = ('reviewer', 'agreement')

    def __str__(self):
        return f'{self.reviewer.full_name} → {self.reviewee.full_name}: {self.rating}★'


class ReputationScore(models.Model):
    """
    Computed reputation for each user. Updated after each review.
    Encapsulates complex scoring logic in one place.
    """
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='reputation'
    )
    overall_score = models.DecimalField(max_digits=3, decimal_places=1, default=0)
    reliability_pct = models.PositiveSmallIntegerField(default=0)
    on_time_pct = models.PositiveSmallIntegerField(default=0)
    condition_pct = models.PositiveSmallIntegerField(default=0)
    total_reviews = models.PositiveIntegerField(default=0)
    last_updated = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'reputation_scores'

    def __str__(self):
        return f'Reputation({self.user.full_name}): {self.overall_score}★'

    def recompute(self):
        """Recompute all reputation metrics from raw reviews."""
        reviews = Review.objects.filter(reviewee=self.user)
        count = reviews.count()
        if count == 0:
            return

        from django.db.models import Avg, Count

        agg = reviews.aggregate(avg_rating=Avg('rating'))
        self.overall_score = round(agg['avg_rating'], 1)
        self.total_reviews = count

        reliable = reviews.filter(is_reliable=True).count()
        on_time = reviews.filter(was_on_time=True).count()
        condition = reviews.filter(good_condition=True).count()
        total_bool = reviews.filter(is_reliable__isnull=False).count() or 1

        self.reliability_pct = int((reliable / total_bool) * 100)
        self.on_time_pct = int((on_time / total_bool) * 100)
        self.condition_pct = int((condition / total_bool) * 100)
        self.save()
