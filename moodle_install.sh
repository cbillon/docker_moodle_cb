docker exec -it docker_moodle-app php moodle/admin/cli/install.php \
--lang=fr --wwwroot=http://localhost:8088 --dataroot=/var/www/moodledata --dbtype=mariadb \
 --dbhost=docker_moodle-db  --dbname=moodle --dbuser=admin --dbpass=sesame \
 --prefix=mdl_ --fullname=Moodle_44 --shortname=moodle_minimal --adminpass=sesame \
 --adminemail=admin@moodle.invalid --agree-license --non-interactive

echo "That's All!"