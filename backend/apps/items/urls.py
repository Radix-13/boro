from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ItemViewSet, CategoryListView

router = DefaultRouter()
router.register('', ItemViewSet, basename='item')

urlpatterns = [
    path('categories/', CategoryListView.as_view(), name='categories'),
    path('', include(router.urls)),
]
