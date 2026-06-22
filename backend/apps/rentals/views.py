from rest_framework import generics, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from .models import RentalOffer, RentalAgreement
from .serializers import (
    RentalOfferSerializer, CounterOfferSerializer, RentalAgreementSerializer
)


class RentalOfferViewSet(ModelViewSet):
    serializer_class = RentalOfferSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return RentalOffer.objects.filter(
            borrower=user
        ) | RentalOffer.objects.filter(item__owner=user)

    def perform_create(self, serializer):
        serializer.save(borrower=self.request.user)

    @action(detail=True, methods=['post'])
    def accept(self, request, pk=None):
        offer = self.get_object()
        if offer.item.owner != request.user:
            return Response({'error': 'Only the lender can accept.'}, status=status.HTTP_403_FORBIDDEN)
        if offer.status != RentalOffer.STATUS_PENDING:
            return Response({'error': 'Offer is not pending.'}, status=status.HTTP_400_BAD_REQUEST)
        agreement = offer.accept()
        return Response(RentalAgreementSerializer(agreement).data)

    @action(detail=True, methods=['post'])
    def decline(self, request, pk=None):
        offer = self.get_object()
        if offer.item.owner != request.user:
            return Response({'error': 'Only the lender can decline.'}, status=status.HTTP_403_FORBIDDEN)
        offer.decline()
        return Response({'status': 'declined'})

    @action(detail=True, methods=['post'])
    def counter(self, request, pk=None):
        offer = self.get_object()
        serializer = CounterOfferSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        counter = offer.counter(
            new_price=serializer.validated_data['new_price'],
            message=serializer.validated_data.get('message', '')
        )
        return Response(RentalOfferSerializer(counter).data)


class RentalAgreementViewSet(ModelViewSet):
    serializer_class = RentalAgreementSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['get', 'patch', 'head', 'options']

    def get_queryset(self):
        user = self.request.user
        return RentalAgreement.objects.filter(
            borrower=user
        ) | RentalAgreement.objects.filter(item__owner=user)

    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        agreement = self.get_object()
        if agreement.item.owner != request.user:
            return Response({'error': 'Only lender can complete.'}, status=status.HTTP_403_FORBIDDEN)
        agreement.complete()
        return Response(RentalAgreementSerializer(agreement).data)

    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        agreement = self.get_object()
        if request.user not in [agreement.borrower, agreement.item.owner]:
            return Response({'error': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)
        agreement.cancel()
        return Response({'status': 'cancelled'})
