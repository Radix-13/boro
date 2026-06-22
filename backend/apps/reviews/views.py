from rest_framework import generics, permissions
from rest_framework.response import Response
from .models import Review, ReputationScore
from .serializers import ReviewSerializer, ReputationScoreSerializer


class ReviewListCreateView(generics.ListCreateAPIView):
    serializer_class = ReviewSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user_id = self.request.query_params.get('user_id')
        item_id = self.request.query_params.get('item_id')
        qs = Review.objects.all()
        if user_id:
            qs = qs.filter(reviewee_id=user_id)
        if item_id:
            qs = qs.filter(item_id=item_id)
        return qs

    def perform_create(self, serializer):
        serializer.save(reviewer=self.request.user)


class ReputationView(generics.RetrieveAPIView):
    serializer_class = ReputationScoreSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_object(self):
        user_id = self.kwargs['user_id']
        rep, _ = ReputationScore.objects.get_or_create(user_id=user_id)
        return rep
