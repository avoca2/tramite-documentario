FROM php:8.4-cli

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-install zip pdo pdo_mysql

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar código (sin .env)
COPY . /app

# Instalar dependencias
RUN composer install --no-dev --optimize-autoloader

# Dar permisos
RUN chmod -R 755 storage bootstrap/cache

# Exponer puerto
EXPOSE 10000

# Iniciar servidor (usando variables de entorno)
CMD php artisan serve --host=0.0.0.0 --port=10000
