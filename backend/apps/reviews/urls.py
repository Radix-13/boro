from django.urls import path
from .views import ReviewListCreateView, ReputationView

urlpatterns = [
    path('', ReviewListCreateView.as_view(), name='reviews'),
    path('reputation/<int:user_id>/', ReputationView.as_view(), name='reputation'),
]
