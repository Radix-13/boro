from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone


class UserManager(BaseUserManager):
    """Custom manager for User model."""

    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('Email is required')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(email, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """
    Base user model for the Boro platform.
    Encapsulates authentication and shared profile data.
    """
    email = models.EmailField(unique=True)
    full_name = models.CharField(max_length=150)
    phone = models.CharField(max_length=20, blank=True)
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True)
    bio = models.TextField(blank=True)
    location = models.CharField(max_length=200, blank=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    date_joined = models.DateTimeField(default=timezone.now)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_verified = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['full_name']

    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'

    def __str__(self):
        return f'{self.full_name} <{self.email}>'

    @property
    def reputation_score(self):
        """Compute overall reputation score from reviews."""
        from apps.reviews.models import Review
        reviews = Review.objects.filter(reviewee=self)
        if not reviews.exists():
            return None
        return round(reviews.aggregate(
            avg=models.Avg('rating')
        )['avg'], 1)

    @property
    def total_rentals(self):
        return self.borrower_rentals.count()

    @property
    def total_listings(self):
        return self.items.filter(is_active=True).count()


class LenderProfile(models.Model):
    """
    Extended profile for users who lend items.
    Inherits user identity via OneToOne relationship (composition-based OOP).
    """
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='lender_profile')
    bank_account = models.CharField(max_length=50, blank=True)
    total_earned = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    preferred_payment = models.CharField(
        max_length=20,
        choices=[('bkash', 'bKash'), ('nagad', 'Nagad'), ('bank', 'Bank Transfer')],
        default='bkash'
    )
    auto_approve = models.BooleanField(default=False)

    class Meta:
        db_table = 'lender_profiles'

    def __str__(self):
        return f'LenderProfile({self.user.full_name})'

    def update_earnings(self, amount):
        """Encapsulated method to update total earnings."""
        self.total_earned += amount
        self.save(update_fields=['total_earned'])


class BorrowerProfile(models.Model):
    """
    Extended profile for users who borrow items.
    Polymorphic behavior with LenderProfile — same user can have both.
    """
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='borrower_profile')
    total_spent = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    preferred_categories = models.JSONField(default=list)
    is_trusted = models.BooleanField(default=False)

    class Meta:
        db_table = 'borrower_profiles'

    def __str__(self):
        return f'BorrowerProfile({self.user.full_name})'

    def update_spending(self, amount):
        """Encapsulated method to track spending."""
        self.total_spent += amount
        self.save(update_fields=['total_spent'])
