from django.db import models
from django.conf import settings


class Category(models.Model):
    """Encapsulates item categories with icon and color metadata."""
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(unique=True)
    icon = models.CharField(max_length=50, default='package')
    color = models.CharField(max_length=7, default='#1D9E75')

    class Meta:
        db_table = 'categories'
        verbose_name_plural = 'Categories'
        ordering = ['name']

    def __str__(self):
        return self.name


class Item(models.Model):
    """
    Core item model. Encapsulates all rental item data.
    Lender is the owner; multiple images via ItemImage (composition).
    """
    STATUS_AVAILABLE = 'available'
    STATUS_RENTED = 'rented'
    STATUS_UNAVAILABLE = 'unavailable'
    STATUS_CHOICES = [
        (STATUS_AVAILABLE, 'Available'),
        (STATUS_RENTED, 'Rented'),
        (STATUS_UNAVAILABLE, 'Unavailable'),
    ]

    CONDITION_NEW = 'new'
    CONDITION_LIKE_NEW = 'like_new'
    CONDITION_GOOD = 'good'
    CONDITION_FAIR = 'fair'
    CONDITION_CHOICES = [
        (CONDITION_NEW, 'New'),
        (CONDITION_LIKE_NEW, 'Like New'),
        (CONDITION_GOOD, 'Good'),
        (CONDITION_FAIR, 'Fair'),
    ]

    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='items'
    )
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, related_name='items')
    title = models.CharField(max_length=200)
    description = models.TextField()
    price_per_day = models.DecimalField(max_digits=10, decimal_places=2)
    deposit = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    condition = models.CharField(max_length=10, choices=CONDITION_CHOICES, default=CONDITION_GOOD)
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default=STATUS_AVAILABLE)
    location = models.CharField(max_length=200, blank=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    allow_negotiation = models.BooleanField(default=True)
    min_rental_days = models.PositiveIntegerField(default=1)
    max_rental_days = models.PositiveIntegerField(default=30)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    views_count = models.PositiveIntegerField(default=0)

    class Meta:
        db_table = 'items'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.title} by {self.owner.full_name}'

    def mark_as_rented(self):
        """Encapsulated state transition."""
        self.status = self.STATUS_RENTED
        self.save(update_fields=['status'])

    def mark_as_available(self):
        """Encapsulated state transition."""
        self.status = self.STATUS_AVAILABLE
        self.save(update_fields=['status'])

    def increment_views(self):
        self.views_count = models.F('views_count') + 1
        self.save(update_fields=['views_count'])

    @property
    def average_rating(self):
        from apps.reviews.models import Review
        reviews = Review.objects.filter(item=self)
        if not reviews.exists():
            return None
        return round(reviews.aggregate(avg=models.Avg('rating'))['avg'], 1)

    @property
    def primary_image(self):
        img = self.images.filter(is_primary=True).first()
        return img or self.images.first()


class ItemImage(models.Model):
    """
    Supports multiple images per item (composition with Item).
    One image can be marked as primary/thumbnail.
    """
    item = models.ForeignKey(Item, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='items/')
    is_primary = models.BooleanField(default=False)
    order = models.PositiveIntegerField(default=0)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'item_images'
        ordering = ['order', 'uploaded_at']

    def save(self, *args, **kwargs):
        # Ensure only one primary image per item
        if self.is_primary:
            ItemImage.objects.filter(item=self.item, is_primary=True).update(is_primary=False)
        super().save(*args, **kwargs)

    def __str__(self):
        return f'Image for {self.item.title} (primary={self.is_primary})'


class ItemAvailability(models.Model):
    """
    Tracks blocked/unavailable dates for an item.
    Used for calendar-based scheduling.
    """
    item = models.ForeignKey(Item, on_delete=models.CASCADE, related_name='blocked_dates')
    blocked_from = models.DateField()
    blocked_until = models.DateField()
    reason = models.CharField(max_length=100, default='rented')

    class Meta:
        db_table = 'item_availability'

    def __str__(self):
        return f'{self.item.title} blocked {self.blocked_from} to {self.blocked_until}'
