#!/bin/bash

docker exec -it docker_moodle-app  sudo www-data php admin/cli/cron.php
echo "That's ALL!"