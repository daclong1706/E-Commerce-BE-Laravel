# ---- builder (Debian) ----
FROM php:8.2-cli AS builder
ARG MONGODB_EXT_VER=1.21.1

RUN apt-get update \
 && apt-get install -y --no-install-recommends git unzip libssl-dev pkg-config $PHPIZE_DEPS \
 && pecl channel-update pecl.php.net \
 && pecl install mongodb-${MONGODB_EXT_VER} \
 && docker-php-ext-enable mongodb \
 && php -r "echo ini_get('extension_dir');" \
 && cp "$(php -r "echo ini_get('extension_dir');")/mongodb.so" /tmp/mongodb.so \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx ca-certificates \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev libonig-dev libxml2-dev \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j"$(nproc)" gd pdo_mysql mbstring exif pcntl bcmath opcache \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Provide MongoDB extension built in builder stage
COPY --from=builder /tmp/mongodb.so /usr/local/lib/php/extensions/mongodb.so
RUN echo "extension=/usr/local/lib/php/extensions/mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini

WORKDIR /var/www
COPY --from=builder --chown=www-data:www-data /app ./
# Ensure writable dirs (COPY can reset ownership across stages on some Docker versions)
RUN chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# Production OPcache defaults
RUN { \
      echo "opcache.enable=1"; \
      echo "opcache.enable_cli=0"; \
      echo "opcache.memory_consumption=128"; \
      echo "opcache.interned_strings_buffer=16"; \
      echo "opcache.max_accelerated_files=20000"; \
      echo "opcache.validate_timestamps=0"; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD php-fpm -D && nginx -g 'daemon off;'
