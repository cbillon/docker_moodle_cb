# Create your self-built Docker Moodle tesing environment  

This repository provides a minimal Moodle testing environment based on docker compose.

## Disclaimer

This deployment is **NOT** intended for a production environment.

It is an reference implementation aimed at Moodle testers.

## How to start

Clone this repository inside a folder

``git clone git@github.com:cbillon/docker_moodle_cb.git``

d'apres : git clone https://github.com/Dmfama20/docker_moodle_minimal.git minimal_moodle

## Installation via script

### env.cnf

Mettre à jour le fichier de configuration env.cnf

```
  PROJECT=demo
  ENV_DEPLOY=dev
  DEBUG=true

  RACINE=$(pwd)
  TARGET="$RACINE"/moodle
  # environnement CodeBase Manager
  MOODLE_SRC=/data/cbm/moodle
  PROJECTS=/data/cbm/projects

```

### Installation

dans le répertoire d'installation :
  
 ./install.sh

 Le script :
 - copie les sources du site dans le répertoire moodle
 - sauvegarde la configuration config.php dans l'environnent dev de CodeBase Manager

 en cas de re installation, il faut faire le ménage

 ./install.sh --force
 
 le script supprimme les répertoires qui sevent de volume à Docker
 - sources du site moodle
 - base de données dbdata
 - base redis : cache
 Le répertoire moodledata est re créé avec les owner:group www-data

### Mise à jour

 apres une nouvelle livraison :

 ./upgrade.sh

 cette commande permet la mise à jour du site
 le fichier config.php est pris dans l'environnement CodeBase Manager
 si ce fichier n'existe pas, on prend le fichier present dans la configuration avant mise à jour.
 ceci permet de mettre à jour le fichier de configuration manuellement.

### Pour installer redis

recopier dans config.php
 ```
  $CFG->session_handler_class = '\core\session\redis';
  $CFG->session_redis_host = 'docker_moodle-redis';
```
 ## Install moodle via browser 

- create folder moodledata www-data www-data  
```
    mkdir moodledata
    chown www-data:www-data
``` 



- database
   - host: docker_moodle-db (et non **localhost**)
   - dbname: moodle
   - dbuser: moodledude 
   - dbpass: mysecretpassword 
   - prefix : mdl_ 

OR

via CLI:

``docker exec -it docker_moodle-app php /var/www/html/admin/cli/install.php --lang=fr --wwwroot=http://localhost:8088 --dataroot=/var/www/moodledata --dbtype=mariadb --dbhost=docker_moodle-db  --dbname=moodle --dbuser=admin --dbpass=sesame --prefix=mdl_ --fullname=moodle_minimal --shortname=moodle_minimal --adminpass=sesame --adminemail=admin@moodle.invalid --agree-license --non-interactive``

## Visit your moodle at http://localhost:8088

Note: pour installer redis

recopier dans config.php
 ```
  $CFG->session_handler_class = '\core\session\redis';
  $CFG->session_redis_host = 'docker_moodle-redis';
```
Le fichier complet config-sample.php dans le repertoire principal.

Se connecter
Plugins -> cache
ajouter une instance : Redis
dans la configuration adresse du serveur: docker_moodle-redis
en bas de l'écran modifier les correspondances -> Redis

Vérifier :
Serveur : Opcache, Redis
Fonctionnement du cron : Rapport > Statut du systéme

## Notes d'installation

### integration a traefik

Ajouter dans docker_moodle-web

```
  networks:
    - proxy
    - docker_moodle
  labels:
    - traefik.enable=true
    - traefik.http.routers.moodle.rule=Host(`moodle.cbillon.ovh`)
    - traefik.http.routers.moodle.entrypoints=https
    - traefik.http.services.moodle.loadbalancer.server.port=8088
    - traefik.http.routers.moodle.tls.certresolver=letsencrypt
    - traefik.http.routers.moodle.tls.domains[0].main=cbillon.ovh
    - traefik.http.routers.moodle.tls.domains[0].sans=*.cbillon.ovh

```

### Configuration PHP

- php
le fichier php.ini dev est déplacé dans /usr/local/etc/php/php.ini
le fichier de configuration PHP/moodlephp.ini est copié dans /usr/local/etc/php/conf.d
- php-fpm

le fichier de configuration PHP/moodlephpfpm.conf est copié dans /usr/local/etc/php-fpm.d

Muliple configuration file php-fpm
Analyzing the source code of php7.0-fpm and more specifically fpm-conf.c, it appears that

    the main configuration file php-fpm.conf is read first [ fpm_conf_load_ini_file() ],
    all include directives are read in order, giving a list of files thanks to glob(),
    each of the file is parsed by the same fpm_conf_load_ini_file(),
    an entry in the file overwrites any previously set value,
    any new include will have a recursive call to the includes processing function, and
    the glob() function sorts names, by default (no GLOB_NOSORT option)

Thus we can assume - at least in this version but this is unlikely to change soon considering the present code - that it is safe to arrange the pool.d directory configuration files in alphabetical order ; any previously recorded value being overwritten by an entry with the same name read after.

We have a clean way to handle configuration files for php-fpm, keeping the distribution ones untouched, and adding custom files having name alphabetically greater than the packaged ones, that contain the few options that have to be changed.

### Debug containers

pour se connecter à la base de données
docker exec -it docker_moodle-app bash
mariadb -u admin -psesame

show databases;
use moodle;
show variables like "collation_database";
show variables like "character_set_database";

pour modifier
ALTER DATABASE moodle CHARACTER SET utf8mb4 COLLATION utf8mb4_unicode_ci;
