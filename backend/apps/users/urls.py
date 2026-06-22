from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    RegisterView, LoginView, MeView,
    UserPublicView, LenderProfileView, BorrowerProfileView
)

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('me/', MeView.as_view(), name='me'),
    path('me/lender/', LenderProfileView.as_view(), name='lender-profile'),
    path('me/borrower/', BorrowerProfileView.as_view(), name='borrower-profile'),
    path('users/<int:pk>/', UserPublicView.as_view(), name='user-public'),
]
