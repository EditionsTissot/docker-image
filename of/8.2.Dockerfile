FROM php:8.2-fpm-alpine

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.6/community' >> /etc/apk/repositories

RUN apk upgrade --update && \
apk add --no-cache ${PHPIZE_DEPS} bash zip curl wget libpng libzip icu mariadb-client openssh make openssl imagemagick imagemagick-dev 'tidyhtml-dev==5.2.0-r1' linux-headers && \
apk add --no-cache --virtual .build-deps libxml2-dev curl-dev libzip-dev libpng-dev icu-dev libjpeg-turbo-dev libwebp-dev zlib-dev libxpm-dev

RUN docker-php-ext-install pdo pdo_mysql ftp zip bcmath xml curl gd intl sysvsem sockets

# Xdebug
RUN pecl install xdebug \
&& docker-php-ext-enable xdebug

# Imagick
RUN pecl install -o -f imagick \
&& docker-php-ext-enable imagick

# Apcu
RUN pecl install apcu \
&& docker-php-ext-enable apcu

# Tidy
RUN apk update \
&& apk add --no-cache 'tidyhtml-dev==5.2.0-r1' \
&& docker-php-ext-install tidy \
&& docker-php-ext-enable tidy

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY of/symfony.ini $PHP_INI_DIR/conf.d/symfony.ini

# INSTALL COMPOSER
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer
RUN alias composer='php /usr/bin/composer'

RUN mkdir ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN wget https://get.symfony.com/cli/installer -O - | bash
RUN mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

ARG imagemagic_config=/etc/ImageMagick-6/policy.xml
RUN if [ -f $imagemagic_config ] ; then sed -i 's/<policy domain="coder" rights="none" pattern="PDF" \/>/<policy domain="coder" rights="read" pattern="PDF" \/>/g' $imagemagic_config ; else echo did not see file $imagemagic_config ; fi

RUN apk del .build-deps \
&& pecl clear-cache \
&& rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*

WORKDIR /var/www/html
