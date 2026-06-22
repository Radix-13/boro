from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import RentalOfferViewSet, RentalAgreementViewSet

router = DefaultRouter()
router.register('offers', RentalOfferViewSet, basename='rental-offer')
router.register('agreements', RentalAgreementViewSet, basename='rental-agreement')

urlpatterns = [path('', include(router.urls))]
