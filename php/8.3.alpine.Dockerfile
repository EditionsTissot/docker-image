FROM php:8.3-alpine

# Install custom extensions
RUN apk upgrade --update && \
    apk add --no-cache sqlite git openssh zip make openssl bash jq icu mysql-client && \
    apk add --no-cache --virtual .build-deps rabbitmq-c rabbitmq-c-dev libxml2-dev sqlite-dev curl-dev libzip-dev libpng-dev icu-dev $PHPIZE_DEPS && \
    apk add --update linux-headers

ENV DOCKERIZE_VERSION v0.7.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN docker-php-ext-install zip bcmath sockets pdo pdo_mysql gd intl calendar
RUN pecl install xdebug amqp \
    && docker-php-ext-enable xdebug amqp
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY php/symfony.ini $PHP_INI_DIR/conf.d/symfony.ini

# INSTALL COMPOSER
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer
RUN alias composer='php /usr/bin/composer'

RUN mkdir ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN wget https://get.symfony.com/cli/installer -O - | bash
RUN mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

RUN rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*
