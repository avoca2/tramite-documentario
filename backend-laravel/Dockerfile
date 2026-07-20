FROM php:8.4-cli

WORKDIR /app

# Instalar dependencias del sistema y PostgreSQL
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    libpq-dev \
    && docker-php-ext-install zip pdo pdo_pgsql pgsql

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar código (sin .env)
COPY . /app

# Crear directorios y dar permisos
RUN mkdir -p bootstrap/cache storage/framework/views storage/framework/cache storage/framework/sessions && \
    chmod -R 775 bootstrap/cache storage

# Instalar dependencias
RUN composer install --no-dev --optimize-autoloader

# Dar permisos
RUN chmod -R 775 bootstrap/cache storage

# Exponer puerto
EXPOSE 10000

# Iniciar servidor
CMD php artisan serve --host=0.0.0.0 --port=10000
