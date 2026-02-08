#!/bin/bash

composer install --no-dev --classmap-authoritative
chown -R www-data:www-data vendor
