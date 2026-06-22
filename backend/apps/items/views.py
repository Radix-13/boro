from rest_framework import generics, permissions, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from django_filters.rest_framework import DjangoFilterBackend
from django_filters import rest_framework as django_filters
from .models import Item, ItemImage, Category, ItemAvailability
from .serializers import (
    ItemListSerializer, ItemDetailSerializer,
    ItemImageSerializer, CategorySerializer, ItemAvailabilitySerializer
)
from .permissions import IsOwnerOrReadOnly


class ItemFilter(django_filters.FilterSet):
    min_price = django_filters.NumberFilter(field_name='price_per_day', lookup_expr='gte')
    max_price = django_filters.NumberFilter(field_name='price_per_day', lookup_expr='lte')
    category = django_filters.CharFilter(field_name='category__slug')
    status = django_filters.CharFilter(field_name='status')
    condition = django_filters.CharFilter(field_name='condition')

    class Meta:
        model = Item
        fields = ['min_price', 'max_price', 'category', 'status', 'condition']


class CategoryListView(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.AllowAny]


class ItemViewSet(ModelViewSet):
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = ItemFilter
    search_fields = ['title', 'description', 'location']
    ordering_fields = ['price_per_day', 'created_at', 'views_count']

    def get_queryset(self):
        return Item.objects.filter(is_active=True).select_related(
            'owner', 'category'
        ).prefetch_related('images')

    def get_serializer_class(self):
        if self.action == 'list':
            return ItemListSerializer
        return ItemDetailSerializer

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.increment_views()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def my_listings(self, request):
        items = Item.objects.filter(owner=request.user, is_active=True)
        serializer = ItemListSerializer(items, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def upload_image(self, request, pk=None):
        item = self.get_object()
        if item.owner != request.user:
            return Response({'error': 'Not authorized'}, status=status.HTTP_403_FORBIDDEN)
        serializer = ItemImageSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(item=item)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['get'])
    def availability(self, request, pk=None):
        item = self.get_object()
        blocked = ItemAvailability.objects.filter(item=item)
        serializer = ItemAvailabilitySerializer(blocked, many=True)
        return Response(serializer.data)
