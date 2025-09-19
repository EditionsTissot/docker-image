FROM php:8.3-fpm

# Node JS repo
RUN curl -s https://deb.nodesource.com/setup_18.x | bash

# Install dependencies
RUN apt-get update -y && apt-get install -y \
    libsqlite3-dev libzip-dev libpng-dev libgd3 make curl wget git nodejs unzip libbz2-dev default-mysql-client \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 sudo libicu-dev nodejs

# Install yarn npm npx
RUN npm install --global yarn npm npx

# Install Playwright
RUN yarn global add @playwright/test
RUN npx playwright install
RUN npx playwright install-deps

# Install dockerize to wait mysql
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN docker-php-ext-install zip bcmath sockets pdo pdo_mysql gd intl calendar
RUN pecl install xdebug amqp \
&& docker-php-ext-enable xdebug amqp

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY php-node/symfony.ini $PHP_INI_DIR/conf.d/symfony.ini
RUN ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

# INSTALL COMPOSER
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer
RUN alias composer='php /usr/bin/composer'

# Install symfony cli
RUN curl -LsS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony5/bin/symfony /usr/local/bin/symfony \
    && symfony server:ca:install

# CLEAN
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
/usr/share/doc/* /usr/share/groff/* /usr/share/info/*

RUN mkdir -p /var/www/html
RUN git config --global --add safe.directory /var/www/html
WORKDIR /var/www/html
