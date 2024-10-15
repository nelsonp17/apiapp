FROM php:8.2-fpm-alpine

# Add non-root user
ARG USERNAME=lempdock
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN addgroup -g ${USER_GID} -S ${USERNAME} \
	&& adduser -D -u ${USER_UID} -S ${USERNAME} -s /bin/sh ${USERNAME} \
	&& adduser ${USERNAME} www-data \
    && chown -R ${USERNAME}:www-data /var/www/* \
    && sed -i "s/user = www-data/user = ${USERNAME}/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/group = www-data/group = ${USERNAME}/g" /usr/local/etc/php-fpm.d/www.conf

# Install packages and dependencies for PHP extensions
RUN apk add --update \
    $PHPIZE_DEPS \
    libpng-dev freetype-dev libjpeg-turbo-dev libxml2-dev libzip-dev libpq-dev \
    zip \
    openssl \
    vim \
    php-cli \
    php-mbstring \
    unzip \
    php-gd \
    php-zip \
    php-xml \
    php-common \
    php-curl \
    php-bcmath

RUN apk add nodejs npm \
    && node -v \
    && npm -v


# Install and config PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        gd \
        bcmath\
        exif \
        opcache \
        mysqli \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        zip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && chown -R ${USERNAME}:${USERNAME} /usr/local/bin/composer
    # It's important can to run composer as non-root user

COPY ./.docker/php-fpm/php.ini /usr/local/etc/php/

# Setting vim configuration for root user
COPY ./.docker/.vimrc /root/

# Switch to non-root user
USER ${USERNAME}

WORKDIR /var/www/html

# Setting vim configuration for non-root user
COPY ./.docker/.vimrc /home/${USERNAME}/

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
