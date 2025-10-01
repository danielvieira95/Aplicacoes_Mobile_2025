from django.contrib import admin
from .models import Produto

@admin.register(Produto)
class ProdutoAdmin(admin.ModelAdmin):
    list_display = ("id","nome","quantidade","preco","created_at")
    search_fields= ("nome",)

# Register your models here.
