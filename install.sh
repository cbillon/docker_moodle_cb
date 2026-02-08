#!/bin/bash

source conf/env.cnf
source includes/functions.cfg

function show_help() {
	# Here doc, note _not_ in quotes, as we want vars to be substituted in.
	# Note that the here doc uses <<- to allow tabbing (must use tabs)
	# Note argument zero used here
	cat > /dev/stdout <<- END
		${0} [-d] [-h] [-f] [-r]
    
		Parameters PROJECT ENV from includes/env.cnf 

		OPTIONAL ARGS:
		-d : debug default : false
		-h : show help
    -f :force - option force re initialisation if previous install exists
		-r : release version  (optional) ; must exists as tag in MOODLE_SRC branch PROJECT
		EXAMPLES
    - cd docker_moodle_cb
		- ./install.sh -f
	END
}

# RELEASE optional
# while loop, and getopts
DEBUG=false
FORCE=false
RELEASE=''

while getopts "h?dfr:" opt
do
	# case statement
	case "${opt}" in
	h|\?)
		show_help
		# exit code
		exit 0
		;;
	d) DEBUG=true ;;
  f) FORCE=true ;;
  r) RELEASE=${OPTARG} ;;

	esac
done

info PROJECT: "$PROJECT" RELEASE: "$RELEASE" RACINE: "$RACINE" FORCE: "$FORCE"

[ ! -d "$VOL_MOODLE" ] && error "$VOL_MOODLE" not exists &&  exit 1
[ ! -f "$PROJECTS"/"$PROJECT"/"$PROJECT".json ] && error PROJECT "$PROJECT" unknown && exit 1

info volume docker Moodle: "$VOL_MOODLE"
set_state
info option traitement: "$STATE" -force: "$FORCE"

update_moodle_volume "$PROJECT" "$RELEASE"

info option traitement: "$STATE" -force: "$FORCE"

#read -n 1 -p "To continue, press any key"

if [ "$STATE" == install ]; then

  info install Moodle
  # update script before install
  # envsubst < "$RACINE"/templates/php.dockerfile > "$RACINE"/php/php.dockerfile
  # envsubst < "$RACINE"/templates/dropdb.sql > "$RACINE"/dropdb.sql
  # envsubst < "$RACINE"/templates/composer_install.sh > "$RACINE"/composer_install.sh
  # envsubst < "$RACINE"/templates/post_install.sh > "$RACINE"/post_install.sh
  chmod 0777 "$VOL_MOODLE"
  docker compose up -d
  wait_docker_up docker_moodle-db
    
  read -n 1 -p "To continue, press any key"

  docker exec -it -u www-data docker_moodle-app php /var/www/html/admin/cli/install.php \
   --lang="$LANG" --wwwroot=http://localhost:8088 --dataroot=/var/www/moodledata --dbtype="$DBTYPE" \
   --dbhost=docker_moodle-db  --dbname="$DBNAME" --dbuser="$DBUSER" --dbpass="$DBPASS" \
   --prefix=mdl_ --fullname="$FULLNAME" --shortname="$SHORTNAME" --adminpass="$ADMINPASS"\
   --adminemail="$ADMINEMAIL" --agree-license --non-interactive

  #docker exec -it docker_moodle-app ./post_install.sh
  #  save config.php after fresh install
  sudo chown cb:cb "$VOL_MOODLE"/config.php
  chmod 0755 "$VOL_MOODLE"
  sudo chmod 0644 "$VOL_MOODLE"/config.php
  cp "$VOL_MOODLE"/config.php  "$RACINE"/save/config.php
  info config.php saved in "$RACINE"/save
  info
  success Moodle installation completed successfully. You can now log on to your new Moodle with admin "$ADMINPASS"
  
else

  info update Moodle

# docker_moodle-app must be up

  docker exec -it -u www-data docker_moodle-app  php admin/cli/maintenance.php --enable 
  docker exec -it -u www-data docker_moodle-app  ./composer_install.sh
  docker exec -it -u www-data docker_moodle-app  php admin/cli/upgrade.php
  docker exec -it -u www-data docker_moodle-app  php admin/cli/maintenance.php --disable
  docker exec -it -u www-data docker_moodle-app  php admin/cli/purge_caches.php

fi  
info "That's All!"