INSTALLED_APPS = [
    # ...
    'django.contrib.admin',            # precisa estar!
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
     'produtos.apps.ProdutosConfig',         
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    ...
    # ...
]

# Ajuste conforme seu app Flutter/host (ou libere tudo durante dev)
CORS_ALLOW_ALL_ORIGINS = True
ALLOWED_HOSTS = ['192.168.15.12', 'localhost', '127.0.0.1']

# ou:
# CORS_ALLOWED_ORIGINS = [
#     "http://localhost:3000",
#     "http://127.0.0.1:3000",
#     "http://10.0.2.2:3000",  # emulador Android
# ]

REST_FRAMEWORK = {
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 20,
}
