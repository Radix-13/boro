from rest_framework import serializers
from .models import Review, ReputationScore
from apps.users.serializers import UserPublicSerializer


class ReviewSerializer(serializers.ModelSerializer):
    reviewer_detail = UserPublicSerializer(source='reviewer', read_only=True)

    class Meta:
        model = Review
        fields = (
            'id', 'reviewer', 'reviewer_detail', 'reviewee', 'agreement',
            'item', 'rating', 'comment', 'is_reliable', 'was_on_time',
            'good_condition', 'created_at'
        )
        read_only_fields = ('id', 'reviewer', 'created_at')

    def validate(self, data):
        request = self.context['request']
        agreement = data.get('agreement')
        if agreement and agreement.borrower != request.user and agreement.item.owner != request.user:
            raise serializers.ValidationError('You are not part of this agreement.')
        if agreement and agreement.status != 'completed':
            raise serializers.ValidationError('Rental must be completed before reviewing.')
        return data

    def create(self, validated_data):
        review = super().create(validated_data)
        # Trigger reputation recompute
        rep, _ = ReputationScore.objects.get_or_create(user=review.reviewee)
        rep.recompute()
        return review


class ReputationScoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReputationScore
        fields = (
            'overall_score', 'reliability_pct', 'on_time_pct',
            'condition_pct', 'total_reviews', 'last_updated'
        )
