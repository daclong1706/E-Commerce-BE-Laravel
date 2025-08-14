# ---- builder (Debian) ----
FROM php:8.2-cli AS builder
RUN apt-get update \
 && apt-get install -y git unzip libssl-dev pkg-config $PHPIZE_DEPS \
 && pecl install mongodb \
 && docker-php-ext-enable mongodb \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin
COPY composer.json composer.lock ./
RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader
COPY . .
RUN chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# ---- runtime ----
FROM php:8.2-fpm
RUN apt-get update && apt-get install -y \
    nginx supervisor ca-certificates git unzip \
    libssl-dev pkg-config libpng-dev libjpeg62-turbo-dev libfreetype6-dev libonig-dev libxml2-dev \
 && pecl install mongodb && docker-php-ext-enable mongodb \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j"$(nproc)" gd pdo_mysql mbstring exif pcntl bcmath opcache \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /var/www
COPY --from=builder /app ./
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD php-fpm -D && nginx -g 'daemon off;'
