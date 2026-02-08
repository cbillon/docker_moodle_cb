#!/bin/bash

find /var/www/html/moodle -type d -exec chmod 0755 {} \;
find /var/www/html/moodle -type f -exec chmod 0644 {} \;
