#!/bin/bash
# $1 /var/www/html/moodle
# $1 /var/www/html/public
dir="${1:-./public}"

find "$dir" -type d -exec chmod 0755 {} +
find "$dir" -type f -exec chmod 0644 {} +