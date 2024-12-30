# ARG PHP_VERSION
# FROM php:"${PHP_VERSION}"-fpm
# RUN apt-get update && apt-get install -y zlib1g-dev libpng-dev curl libicu-dev libxml2-dev g++ libxslt-dev libzip-dev zip 

# RUN docker-php-ext-install mysqli pdo pdo_mysql gettext zip gd intl xmlrpc soap opcache xsl\
#     && docker-php-ext-enable mysqli pdo pdo_mysql gd intl xmlrpc soap opcache xsl
# # Install YAML extension
# RUN apt-get install libyaml-dev -y
# RUN  pecl install yaml && echo "extension=yaml.so" > /usr/local/etc/php/conf.d/ext-yaml.ini && docker-php-ext-enable yaml

FROM php:8.1-fpm

RUN apt-get update && apt-get install -y zlib1g-dev libexif-dev libpng-dev libjpeg-dev libxml2-dev libzip-dev libxslt-dev libldap-dev locales
RUN docker-php-ext-configure gd --with-jpeg
RUN docker-php-ext-install pdo pdo_mysql mysqli exif gd soap intl zip xsl opcache ldap
RUN pecl install -o -f redis &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis
# RUN pecl install xdebug && docker-php-ext-enable xdebug
#RUN localedef -c -i en_AU -f UTF-8 en_AU.UTF-8
RUN localedef -c -i fr_FR -f UTF-8 fr_FR.UTF-8
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
RUN usermod -u 1000 www-data
#COPY ../moodlephp.ini "$PHP_INI_DIR/conf.d/moodlephp.ini"
#COPY ../moodlephp.ini "$PHP_INI_DIR/conf.d/moodlephp.ini"
COPY ../moodlephpfpm.conf "/usr/local/etc/php-fpm.d"