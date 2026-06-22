from django.db import models
from django.conf import settings
from django.utils import timezone


class RentalTransaction(models.Model):
    """
    Abstract base class for rental transactions.
    Demonstrates OOP inheritance — shared fields for Offer and Agreement.
    """
    borrower = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='%(class)s_borrower'
    )
    item = models.ForeignKey(
        'items.Item',
        on_delete=models.CASCADE,
        related_name='%(class)s_transactions'
    )
    start_date = models.DateField()
    end_date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True

    @property
    def duration_days(self):
        return (self.end_date - self.start_date).days + 1

    @property
    def lender(self):
        return self.item.owner


class RentalOffer(RentalTransaction):
    """
    Negotiation stage. Inherits from RentalTransaction.
    Supports counter-offers with full offer chain tracking.
    Demonstrates polymorphism — behaves differently from RentalAgreement.
    """
    STATUS_PENDING = 'pending'
    STATUS_COUNTERED = 'countered'
    STATUS_ACCEPTED = 'accepted'
    STATUS_DECLINED = 'declined'
    STATUS_EXPIRED = 'expired'
    STATUS_CHOICES = [
        (STATUS_PENDING, 'Pending'),
        (STATUS_COUNTERED, 'Countered'),
        (STATUS_ACCEPTED, 'Accepted'),
        (STATUS_DECLINED, 'Declined'),
        (STATUS_EXPIRED, 'Expired'),
    ]

    offered_price_per_day = models.DecimalField(max_digits=10, decimal_places=2)
    message = models.TextField(blank=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default=STATUS_PENDING)
    counter_offer = models.OneToOneField(
        'self', null=True, blank=True,
        on_delete=models.SET_NULL,
        related_name='original_offer'
    )
    expires_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'rental_offers'
        ordering = ['-created_at']

    def __str__(self):
        return f'Offer: {self.borrower.full_name} → {self.item.title} @ ৳{self.offered_price_per_day}/day'

    @property
    def total_offered(self):
        return self.offered_price_per_day * self.duration_days

    def accept(self):
        """State transition: accept offer and create rental agreement."""
        self.status = self.STATUS_ACCEPTED
        self.save(update_fields=['status'])
        agreement = RentalAgreement.objects.create(
            borrower=self.borrower,
            item=self.item,
            start_date=self.start_date,
            end_date=self.end_date,
            agreed_price_per_day=self.offered_price_per_day,
            offer=self,
        )
        self.item.mark_as_rented()
        return agreement

    def decline(self):
        self.status = self.STATUS_DECLINED
        self.save(update_fields=['status'])

    def counter(self, new_price, message=''):
        """Create a counter-offer linked to this offer."""
        counter = RentalOffer.objects.create(
            borrower=self.lender,
            item=self.item,
            start_date=self.start_date,
            end_date=self.end_date,
            offered_price_per_day=new_price,
            message=message,
        )
        self.status = self.STATUS_COUNTERED
        self.counter_offer = counter
        self.save(update_fields=['status', 'counter_offer'])
        return counter

    def is_expired(self):
        if self.expires_at:
            return timezone.now() > self.expires_at
        return False


class RentalAgreement(RentalTransaction):
    """
    Finalized rental contract. Inherits from RentalTransaction.
    Created only when an offer is accepted.
    """
    STATUS_ACTIVE = 'active'
    STATUS_COMPLETED = 'completed'
    STATUS_CANCELLED = 'cancelled'
    STATUS_DISPUTED = 'disputed'
    STATUS_CHOICES = [
        (STATUS_ACTIVE, 'Active'),
        (STATUS_COMPLETED, 'Completed'),
        (STATUS_CANCELLED, 'Cancelled'),
        (STATUS_DISPUTED, 'Disputed'),
    ]

    offer = models.OneToOneField(
        RentalOffer, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='agreement'
    )
    agreed_price_per_day = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default=STATUS_ACTIVE)
    pickup_confirmed = models.BooleanField(default=False)
    return_confirmed = models.BooleanField(default=False)
    lender_notes = models.TextField(blank=True)
    borrower_notes = models.TextField(blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'rental_agreements'
        ordering = ['-created_at']

    def __str__(self):
        return f'Agreement: {self.borrower.full_name} ← {self.item.title} ({self.status})'

    @property
    def total_cost(self):
        return self.agreed_price_per_day * self.duration_days

    def complete(self):
        """Mark agreement as completed and free the item."""
        self.status = self.STATUS_COMPLETED
        self.completed_at = timezone.now()
        self.save(update_fields=['status', 'completed_at'])
        self.item.mark_as_available()
        # Update lender earnings and borrower spending
        lender_profile = getattr(self.lender, 'lender_profile', None)
        if lender_profile:
            lender_profile.update_earnings(self.total_cost)
        borrower_profile = getattr(self.borrower, 'borrower_profile', None)
        if borrower_profile:
            borrower_profile.update_spending(self.total_cost)

    def cancel(self):
        self.status = self.STATUS_CANCELLED
        self.save(update_fields=['status'])
        self.item.mark_as_available()
