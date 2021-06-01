FROM composer:2.0 as composer

FROM php:8-alpine
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY composer.json composer.lock /app/
WORKDIR /app
RUN composer install --no-progress
ENV PATH /app/vendor/bin:${PATH}
WORKDIR /work
ENTRYPOINT ["phpcs"]
