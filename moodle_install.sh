docker exec -it docker_moodle-app php /var/www/html/admin/cli/install.php \
--lang=fr --wwwroot=http://localhost:8088 --dataroot=/var/www/moodledata --dbtype=mariadb \
 --dbhost=docker_moodle-db  --dbname=moodle --dbuser=admin --dbpass=sesame \
 --prefix=mdl_ --fullname=Moodle_45 --shortname=moodle_minimal --adminpass=sesame \
 --adminemail=claude.bllon@gmail.com --agree-license --non-interactive

docker exec -it docker_moodle-app chmod 0777 /var/www/html/config.php
echo "That's All!"