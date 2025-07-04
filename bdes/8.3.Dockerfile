FROM php:8.3-fpm

# Node JS repo
RUN curl -s https://deb.nodesource.com/setup_18.x | bash

# Install dependencies
RUN apt-get update -y && apt-get install -y \
    libicu-dev libsqlite3-dev libzip-dev libpng-dev libgd3 make curl wget git unzip libbz2-dev default-mysql-client \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb sudo nodejs g++ gcc libssl-dev

# Install git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && apt-get install git-lfs

RUN docker-php-ext-install intl
RUN docker-php-ext-configure ftp --with-openssl-dir=/usr \
    && docker-php-ext-install ftp


# Install yarn
RUN npm install --global yarn

# Install dockerize to wait mysql
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN docker-php-ext-install zip bcmath sockets pdo pdo_mysql gd bz2

# Add `install-php-extensions` from https://github.com/mlocati/docker-php-extension-installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions gnupg

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY bdes/symfony.ini $PHP_INI_DIR/conf.d/symfony.ini
RUN ln -sf /usr/share/zoneinfo/Europre/Paris /etc/localtime

# INSTALL COMPOSER
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer
RUN alias composer='php /usr/bin/composer'

# Install symfony cli
RUN curl -LsS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony5/bin/symfony /usr/local/bin/symfony \
    && symfony server:ca:install

# install chrome
ARG CHROME_VERSION="google-chrome-stable"
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update -qqy \
    && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
    && rm /etc/apt/sources.list.d/google-chrome.list \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    && google-chrome --version

RUN CHROME_VERSION="$(google-chrome --version)" \
    && export CHROMEDRIVER_RELEASE="$(echo $CHROME_VERSION | sed 's/^Google Chrome //')" && export CHROMEDRIVER_RELEASE=${CHROMEDRIVER_RELEASE%%.*} \
    && CHROMEDRIVER_VERSION=$(curl --silent --show-error --location --fail --retry 4 --retry-delay 5 https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE) \
    && curl --silent --show-error --location --fail --retry 4 --retry-delay 5 --output /tmp/chromedriver_linux64.zip "https://storage.googleapis.com/chrome-for-testing-public/$CHROMEDRIVER_VERSION/linux64/chromedriver-linux64.zip" \
    && cd /tmp \
    && unzip chromedriver_linux64.zip \
    && rm -rf chromedriver_linux64.zip \
    && mv chromedriver-linux64/chromedriver /usr/local/bin/chromedriver \
    && chmod +x /usr/local/bin/chromedriver \
    && chromedriver --version

# Cypress dependencies
RUN yarn global add cypress@13.14.2 && cypress install --force

# CLEAN
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    /usr/share/doc/* /usr/share/groff/* /usr/share/info/*

RUN mkdir -p /var/www/html
WORKDIR /var/www/html
