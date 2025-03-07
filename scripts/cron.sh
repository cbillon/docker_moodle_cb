#!/bin/bash

docker exec -it docker_moodle-app  php /var/www/html/admin/cli/cron.php
echo "That's ALL!"