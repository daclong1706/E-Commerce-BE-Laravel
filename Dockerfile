# ---- builder (Debian) ----
FROM php:8.2-cli AS builder
ARG MONGODB_EXT_VER=1.21.1

RUN apt-get update \
 && apt-get install -y git unzip libssl-dev pkg-config $PHPIZE_DEPS \
 && pecl install mongodb-${MONGODB_EXT_VER} \
 && docker-php-ext-enable mongodb \
 && rm -rf /var/lib/apt/lists/*

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader
COPY . .
RUN chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# ---- runtime ----
FROM php:8.2-fpm
ARG MONGODB_EXT_VER=1.21.1

RUN apt-get update && apt-get install -y \
    nginx supervisor ca-certificates git unzip \
    libssl-dev pkg-config libpng-dev libjpeg62-turbo-dev libfreetype6-dev libonig-dev libxml2-dev \
 && pecl install mongodb-${MONGODB_EXT_VER} && docker-php-ext-enable mongodb \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j"$(nproc)" gd pdo_mysql mbstring exif pcntl bcmath opcache \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www
COPY --from=builder /app ./
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD php-fpm -D && nginx -g 'daemon off;'
