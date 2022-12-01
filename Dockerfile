FROM docker.io/composer:2.4 as composer

FROM docker.io/php:8.1-alpine3.17
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY composer.json composer.lock /app/
WORKDIR /app
RUN composer install --no-progress
ENV PATH /app/vendor/bin:${PATH}
WORKDIR /work
ENTRYPOINT ["phpcs"]
