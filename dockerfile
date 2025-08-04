FROM webdevops/php-nginx:8.4-alpine

ENV WEB_DOCUMENT_ROOT=/var/www/html/public
ENV WEB_DOCUMENT_INDEX=index.php
ENV PHP_DATE_TIMEZONE=UTC
ENV PHP_MEMORY_LIMIT=512M
ENV PHP_POST_MAX_SIZE=50M
ENV PHP_UPLOAD_MAX_FILESIZE=50M

WORKDIR /var/www/html

RUN apk add --no-cache bash curl mysql-client nodejs npm


COPY composer.json composer.lock ./

RUN composer install --optimize-autoloader --no-interaction --no-scripts

COPY . .

COPY .env.docker .env

COPY docker/nginx/default.conf /opt/docker/etc/nginx/vhost.conf
COPY docker/php/local.ini /usr/local/etc/php/conf.d/local.ini
COPY docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/views \
    && mkdir -p /var/www/html/bootstrap/cache \
    && chown -R application:application /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

RUN composer install --optimize-autoloader --no-interaction

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/opt/docker/bin/entrypoint.sh", "supervisord"]
