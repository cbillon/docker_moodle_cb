# Create your self-built Docker Moodle tesing environment  

This repository provides a minimal Moodle testing environment based on docker compose.

## Disclaimer

This deployment is **NOT** intended for a production environment. 
It is an reference implementation aimed at Moodle testers.

## How to start
1.) Clone this repository inside a folder

``git clone https://github.com/Dmfama20/docker_moodle_minimal.git minimal_moodle``

2.) Place your favourite moodle version inside the *moodle* folder. You can get it from [moodle.org](https://download.moodle.org/releases/latest/).

  supprees if exists dbdata
  update file .env
```
   PHP_VERSION=8.1
   NGINX_VERSION=latest
   MARIADB_VERSION=latest
   MYSQL_USER=admin
   MYSQL_PASSWORD=sesame
   MYSQL_DATABASE=moodle
```
   install mariadb and create database and user password first exec
   
3.) Install moodle via browser 

- create folder moodledata root chmod 0777

- database
   - host: docker_moodle-db (et non **localhost**)
   - dbname: moodle
   - dbuser: moodledude 
   - dbpass: mysecretpassword 
   -prefix : mdl_ 

OR

via CLI:

``docker exec -it docker_moodle-app php admin/cli/install.php --lang=fr --wwwroot=http://localhost:8088 --dataroot=/var/www/moodledata --dbtype=mariadb --dbhost=docker_moodle-db  --dbname=moodle --dbuser=admin --dbpass=sesame --prefix=mdl_ --fullname=moodle_minimal --shortname=moodle_minimal --adminpass=sesame --adminemail=admin@moodle.invalid --agree-license --non-interactive``

Note :

apres installation se connecter au container docker exec -it docker_moodle-app bash
modifier : chmod 0777 config.php
           chown www-data:www-data /var/wwww/moodledata 



4.) Visit your moodle at http://localhost:8088/moodle

Note: pour installer redis

recopier dans config.php
 ```
  $CFG->session_handler_class = '\core\session\redis';
  $CFG->session_redis_host = 'docker_moodle-redis';
```

Se connecter
Plugins -> cache
ajouter une instance : Redis
dans la configuration adresse du serveur docker_moodle-redis
en bas de l'écran modifier les correspondance -> Redis

Vérifier :
Serveur : Opcache, Redis
Fonctionnement du cron : Rapport > Statut du systéme

## Configuration PHP

- php
le fichier php.ini dev est déplacé dans /usr/local/etc/php/php.ini
le fichier de configuration PHP/moodlephp.ini est copié dans /usr/local/etc/php/conf.d
- php-fpm

le fichier de configuration PHP/moodlephpfpm.conf est copié dans /usr/local/etc/php-fpm.d



