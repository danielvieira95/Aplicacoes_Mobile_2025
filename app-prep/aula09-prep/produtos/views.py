from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets
from .models import Produto
from .serializers import ProdutoSerializer

class ProdutoViewSet(viewsets.ModelViewSet):
    queryset = Produto.objects.all().order_by('-id')
    serializer_class = ProdutoSerializer
