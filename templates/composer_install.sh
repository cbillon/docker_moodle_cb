#!/bin/bash

# if [ ! -d "$CACHE_DIR" ]; then
#   mkdir -p "$CACHE_DIR"
#   chown -R www-data:www-data "$CACHE_DIR"
#   chmod -R 750 "$CACHE_DIR"
# fi
# COMPOSER_CACHE_DIR=/var/www/.cache 
composer install --no-dev --classmap-authoritative
chown -R www-data:www-data vendor