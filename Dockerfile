FROM docker.io/composer:2.9 AS composer

FROM docker.io/php:8.5-alpine3.22
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY composer.json composer.lock /app/
WORKDIR /app
RUN composer install --no-progress
ENV PATH=/app/vendor/bin:${PATH}
WORKDIR /work
ENTRYPOINT ["phpcs"]
