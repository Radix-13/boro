from rest_framework import serializers
from .models import RentalOffer, RentalAgreement
from apps.items.serializers import ItemListSerializer
from apps.users.serializers import UserPublicSerializer


class RentalOfferSerializer(serializers.ModelSerializer):
    item_detail = ItemListSerializer(source='item', read_only=True)
    borrower_detail = UserPublicSerializer(source='borrower', read_only=True)
    total_offered = serializers.ReadOnlyField()
    duration_days = serializers.ReadOnlyField()
    lender_id = serializers.IntegerField(source='item.owner.id', read_only=True)

    class Meta:
        model = RentalOffer
        fields = (
            'id', 'item', 'item_detail', 'borrower', 'borrower_detail',
            'lender_id', 'start_date', 'end_date', 'offered_price_per_day',
            'message', 'status', 'total_offered', 'duration_days',
            'expires_at', 'created_at'
        )
        read_only_fields = ('id', 'borrower', 'status', 'created_at')


class CounterOfferSerializer(serializers.Serializer):
    new_price = serializers.DecimalField(max_digits=10, decimal_places=2)
    message = serializers.CharField(required=False, allow_blank=True)


class RentalAgreementSerializer(serializers.ModelSerializer):
    item_detail = ItemListSerializer(source='item', read_only=True)
    borrower_detail = UserPublicSerializer(source='borrower', read_only=True)
    lender_detail = UserPublicSerializer(source='lender', read_only=True)
    total_cost = serializers.ReadOnlyField()
    duration_days = serializers.ReadOnlyField()

    class Meta:
        model = RentalAgreement
        fields = (
            'id', 'item', 'item_detail', 'borrower', 'borrower_detail',
            'lender_detail', 'start_date', 'end_date', 'agreed_price_per_day',
            'status', 'total_cost', 'duration_days', 'pickup_confirmed',
            'return_confirmed', 'lender_notes', 'borrower_notes',
            'completed_at', 'created_at'
        )
        read_only_fields = ('id', 'borrower', 'agreed_price_per_day', 'status', 'created_at')
