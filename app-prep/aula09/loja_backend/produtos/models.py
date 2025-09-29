from django.db import models

class Produto(models.Model):
    nome = models.CharField(max_length=120)
    quantidade = models.PositiveIntegerField(default=0)
    preco = models.DecimalField(max_digits=10, decimal_places=2)  # ex: 99999999.99

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.nome} (qtd={self.quantidade})"
