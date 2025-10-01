from rest_framework import serializers
from .models import Produto


# cria a classe serializers
class ProdutoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Produto
        fields=["id","nome","quantidade","preco","created_at"]