# ---------- builder: install deps with Composer (with ext-mongodb present) ----------
FROM composer:2 AS builder
RUN apt-get update \
 && apt-get install -y libssl-dev pkg-config $PHPIZE_DEPS \
 && pecl install -f mongodb \
 && docker-php-ext-enable mongodb \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app

# install PHP deps first (better caching)
COPY composer.json composer.lock ./
RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader
# then app code
COPY . .
RUN chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# ---------- runtime: php-fpm + nginx ----------
FROM php:8.2-fpm

# system & build deps for PHP extensions + nginx/supervisor
RUN apt-get update && apt-get install -y \
    nginx supervisor ca-certificates git unzip \
    libssl-dev pkg-config libsasl2-dev \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev libonig-dev libxml2-dev \
 && pecl install -f mongodb \
 && docker-php-ext-enable mongodb \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j"$(nproc)" gd pdo_mysql mbstring exif pcntl bcmath opcache \
 && mkdir -p /run/php \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# app
WORKDIR /var/www
COPY --from=builder /app ./

# nginx
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80

# start php-fpm (daemon) + nginx (foreground)
CMD php-fpm -D && nginx -g 'daemon off;'
