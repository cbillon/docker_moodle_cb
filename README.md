# Create your self-built Docker Moodle testing environment  

This repository provides a minimal Moodle testing environment based on docker compose.

## Disclaimer

This deployment is **NOT** intended for a production environment.

It is an reference implementation aimed at Moodle testers.

## How to start

Clone this repository inside a folder

``git clone git@github.com:cbillon/docker_moodle_cb.git``
 
Credits : git clone https://github.com/Dmfama20/docker_moodle_minimal.git minimal_moodle

## Installation via script

Les étapes :
- mettre à jour le fichier includes/env.cnf
- lancer ./install.sh -p <project> -e <env deploiement>

 pour une re installtion complete utiliser le flag **-f**

### includes/env.cnf

Mettre à jour le fichier de configuration env.cnf

```
  # origine des de la base de code
  
  export MOODLE_SRC=~/cbm/moodle
  export PROJECTS=~/cbm/projects

  # version des composants LAMP

  export RACINE=$(pwd)
  export PHP_VERSION='8.2'
  export NGINX_VERSION=latest
  export MARIADB_VERSION=latest
  
  # parametres de l'environnement dev
  
  export ENV=dev
  export SITE=moodle.cbillon.ovh
  export VOL_MOODLE=~/docker_moodle_cb/moodle
  export VOL_MOODLEDATA=~/docker_moodle_cb/moodledata
  export VOL_DBDATA=~/docker_moodle_cb/dbdata
  export LANG=fr
  export DBTYPE=mariadb
  export DBNAME=moodle
  export DBUSER=admin
  export DBPASS=sesame
  export FULLNAME=Moodle_50
  export SHORTNAME=moodle_mini
  export ADMINPASS=sesame
  export ADMINEMAIL=claude.billon@gmail.com

```

### Installation

dans le répertoire d'installation :
  
 ./install.sh -p demo -e env

 Le script :
 - prepare l'environement volumes docker des sources, de la base de données
 - lance le script compose.yaml
 - re copie les sources du site dans le répertoire moodle
 - sauvegarde la configuration config.php dans l'environement dev de CodeBase Manager

 en cas de re installation, il faut faire le ménage

 ./install.sh -p demo -e env -f 
 
 le script supprime les répertoires qui servent de volume à Docker
 - sources du site moodle
 - base de données dbdata
 - base redis : cache
 Le répertoire moodledata est re créé avec les owner:group www-data
 Attention : lors d'une re installation la base de donnée moodle ne sera re creée que si dbdata est vide
(cei est pris en compte avec l'option -f)

### Mise à jour

 apres une nouvelle livraison de la base de code:

 ./upgrade.sh -p demo -e dev

 cette commande permet la mise à jour du site
 le fichier config.php est pris dans l'environnement de deploiement s'il existe
 si ce fichier n'existe pas, on prend le fichier present dans la configuration avant mise à jour.
 ceci permet de mettre à jour le fichier de configuration manuellement.
Apres installation la version de l'environnement de déploiement est renommée config.php.bck

Il est possible d'indiquer une version précédente de la base de code -r (release)



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


## Visit your moodle at http://localhost:8088

### Pour installer redis

Recopier dans config.php dans l'environment de deploiement env/dev

 ```
  $CFG->session_handler_class = '\core\session\redis';
  $CFG->session_redis_host = 'docker_moodle-redis';
```


Le fichier complet config-sample.php dans le repertoire principal.

Se connecter
Plugins -> cache
ajouter une instance : Redis
dans la configuration adresse du serveur: **docker_moodle-redis**
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
    - traefik.http.routers.moodle.rule=Host(${SITE})
    - traefik.http.routers.moodle.entrypoints=https
    - traefik.http.services.moodle.loadbalancer.server.port=8088
    - traefik.http.routers.moodle.tls.certresolver=letsencrypt
    - traefik.http.routers.moodle.tls.domains[0].main=cbillon.ovh
    - traefik.http.routers.moodle.tls.domains[0].sans=*.cbillon.ovh


```
### Debug containers

il existe un script cmd.sh qui permet l'execution d'une commande dans un container
./cmd.sh exec-app 
./cmd.sh exec-db

pour se connecter à la base de données
docker exec -it docker_moodle-app bash
mariadb -u admin -psesame

show databases;
use moodle;
show variables like "collation_database";
show variables like "character_set_database";

pour modifier
ALTER DATABASE moodle CHARACTER SET utf8mb4 COLLATION utf8mb4_unicode_ci;

### Fichiers de cConfiguration 

Les version des composants (php, mariadb, nginx) se trouvent dans includes/env.cnf

Les fichiers de la plate forme pour la création d'images
- php php/moodlephp.ini
- mariadb: conf/mycustom.cnf
- ngnix : conf/nginx.con

Les parametres de l'environement de deploiement viennent surcharger les infos d'installation

php : env/dev/local.ini php, opcache
php-fpm :  env/dev/moodlephpfpm.conf

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


