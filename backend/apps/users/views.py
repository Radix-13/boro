from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from django.contrib.auth import get_user_model
from .serializers import (
    RegisterSerializer, UserSerializer,
    UserPublicSerializer, LenderProfileSerializer, BorrowerProfileSerializer
)
from .models import LenderProfile, BorrowerProfile

User = get_user_model()


class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class LoginView(TokenObtainPairView):
    permission_classes = [permissions.AllowAny]


class MeView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


class UserPublicView(generics.RetrieveAPIView):
    queryset = User.objects.filter(is_active=True)
    serializer_class = UserPublicSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class LenderProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = LenderProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        profile, _ = LenderProfile.objects.get_or_create(user=self.request.user)
        return profile


class BorrowerProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = BorrowerProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        profile, _ = BorrowerProfile.objects.get_or_create(user=self.request.user)
        return profile
