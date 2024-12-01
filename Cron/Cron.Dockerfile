FROM php:8.1-fpm

RUN apt-get update && apt-get install -y zlib1g-dev libexif-dev libpng-dev libjpeg-dev libxml2-dev libzip-dev libxslt-dev libldap-dev locales
RUN docker-php-ext-configure gd --with-jpeg
RUN docker-php-ext-install pdo pdo_mysql mysqli exif gd soap intl zip xsl opcache ldap
RUN pecl install -o -f redis &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis

RUN apt-get -y install tzdata cron
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Paris" > /etc/timezone
    

RUN apt-get -y remove tzdata
RUN rm -rf /var/cache/apk/*

# Copy cron file to the cron.d directory
COPY crontab /etc/cron.d/cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/cron

# Apply cron job
RUN crontab /etc/cron.d/cron

# Create the log file to be able to run tail
RUN mkdir -p /var/log/cron

# Run the command on container startup
CMD cron && tail -f /var/log/cron/cron.log
#CMD sleep 1000
