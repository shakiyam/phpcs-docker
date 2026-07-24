FROM docker.io/composer:2.10 AS composer

FROM docker.io/php:8.5-alpine3.24
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY composer.json composer.lock /app/
WORKDIR /app
RUN composer install --no-progress
ENV PATH=/app/vendor/bin:${PATH}
WORKDIR /work
ARG SOURCE_COMMIT
ENV SOURCE_COMMIT=$SOURCE_COMMIT
ENTRYPOINT ["phpcs"]
