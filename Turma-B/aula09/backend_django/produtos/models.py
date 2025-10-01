from django.db import models

# Create your models here.

# Cria classe chamada produto
class Produto(models.Model):
    nome = models.CharField(max_length=120)
    quantidade = models.PositiveIntegerField(default=0)
    preco = models.DecimalField(max_digits=10,decimal_places=2) #ex 9999999999.99

    created_at = models.DateTimeField(auto_now_add=True) # registro de timestamp automatico quando o produto é cadastrado


    def __str__(self):
        return f"{self.nome} (qtd={self.quantidade})"
