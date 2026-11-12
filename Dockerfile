FROM docker.io/composer:2.11 AS vendor
COPY composer.json composer.lock /app/
WORKDIR /app
RUN composer install --no-progress

FROM docker.io/php:8.5-alpine3.24
COPY --from=vendor /app/vendor /app/vendor
ENV PATH=/app/vendor/bin:${PATH}
WORKDIR /work
# nobody:nogroup
USER 65534:65534
ARG SOURCE_COMMIT
LABEL org.opencontainers.image.revision=$SOURCE_COMMIT
ENTRYPOINT ["phpcs"]
