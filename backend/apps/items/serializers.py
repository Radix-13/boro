from rest_framework import serializers
from .models import Item, ItemImage, Category, ItemAvailability
from apps.users.serializers import UserPublicSerializer


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ('id', 'name', 'slug', 'icon', 'color')


class ItemImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ItemImage
        fields = ('id', 'image', 'is_primary', 'order')


class ItemListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for list views."""
    category = CategorySerializer(read_only=True)
    primary_image = ItemImageSerializer(read_only=True)
    average_rating = serializers.ReadOnlyField()
    owner_name = serializers.CharField(source='owner.full_name', read_only=True)

    class Meta:
        model = Item
        fields = (
            'id', 'title', 'price_per_day', 'deposit', 'status',
            'condition', 'location', 'category', 'primary_image',
            'average_rating', 'owner_name', 'created_at', 'views_count'
        )


class ItemDetailSerializer(serializers.ModelSerializer):
    """Full serializer for item detail views."""
    category = CategorySerializer(read_only=True)
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(), source='category', write_only=True
    )
    images = ItemImageSerializer(many=True, read_only=True)
    owner = UserPublicSerializer(read_only=True)
    average_rating = serializers.ReadOnlyField()

    class Meta:
        model = Item
        fields = (
            'id', 'title', 'description', 'price_per_day', 'deposit',
            'condition', 'status', 'location', 'latitude', 'longitude',
            'category', 'category_id', 'images', 'owner', 'allow_negotiation',
            'min_rental_days', 'max_rental_days', 'average_rating',
            'views_count', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'owner', 'views_count', 'created_at', 'updated_at')


class ItemAvailabilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = ItemAvailability
        fields = ('id', 'blocked_from', 'blocked_until', 'reason')
