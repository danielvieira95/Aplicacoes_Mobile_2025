from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from produtos.views import ProdutoViewSet

router = DefaultRouter()
router.register(r'produtos', ProdutoViewSet, basename='produto')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
]
