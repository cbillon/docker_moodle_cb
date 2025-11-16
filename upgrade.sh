#!/bin/bash

source includes/env.cnf
source includes/functions.cfg

function show_help() {
	# Here doc, note _not_ in quotes, as we want vars to be substituted in.
	# Note that the here doc uses <<- to allow tabbing (must use tabs)
	# Note argument zero used here
	cat > /dev/stdout <<- END
		${0} [-d] [-e] [-h] [-p]

		REQUIRED ARGS:
        -p : Project
        -e : Environment	

		OPTIONAL ARGS:
		-d : debug default : false		
		-h : show help		
		-r : release version  (optional) ; must exists as tag in MOODLE_SRC branch PROJECT
		
		EXAMPLES
    - cd docker_moodle_cb
		- ./upgrade -p demo -e dev
END
}

# while loop, and getopts
DEBUG=false
RELEASE=''

while getopts "h?de:p:r:" opt
do
	# case statement
	case "${opt}" in
	h|\?)
		show_help
		# exit code
		exit 0
		;;
	d) DEBUG=true ;;
	e) ENV=${OPTARG} ;;
	p) PROJECT=${OPTARG} ;;
    r) RELEASE=${OPTARG} ;;

	esac
done

info Start upgrade
info RACINE: "$RACINE"

[ ! -f "$PROJECTS"/"$PROJECT"/"$PROJECT".yml ] && error PROJECT "$PROJECT" unknown && exit 1
[ ! -d "$RACINE"/env/"$ENV" ] && error ENVIRONMENT "$ENV" unknown && exit 1
# RELEASE optional

info PROJECT: "$PROJECT"
info RELEASE: "$RELEASE"
info ENVIRONMENT: "$RACINE"/env/"$ENV"

docker compose up -d
# docker_moodle-app must be up
n=0
while [ -z "$ret" ]  && [ "$n" -lt 5 ]; do
  ret=$(docker compose ps --status running | grep docker_moodle-app)
  sleep 1
  ((n++))
done

info docker_moodle-app up and running  

docker exec -it docker_moodle-app  php admin/cli/maintenance.php --enable 

# mettez à jour config.php manuellement dans  "$RACINE"/env/"$ENV"/config.php
# c'est cette version qui sera prise en compte lors de la prochaine lise à jour
# sinon on récupere la config en cours avant mise à jour

if [ ! -f "$RACINE"/env/"$ENV"/config.php ]; then
  cp "$VOL_MOODLE"/config.php "$RACINE"/env/"$ENV"/config.php
  info config.php comes from "$VOL_MOODLE"/config.php
else
  info config.php comes from "$RACINE"/env/"$ENV"/config.php
fi

update_moodle_volume "$PROJECT" "$ENV" "$RELEASE" 

cp "$RACINE"/env/"$ENV"/config.php  "$VOL_MOODLE"/config.php
 
docker exec -it docker_moodle-app  php admin/cli/upgrade.php
docker exec -it docker_moodle-app  php admin/cli/maintenance.php --disable
docker exec -it docker_moodle-app  php admin/cli/purge_caches.php

mv "$RACINE"/env/"$ENV"/config.php "$RACINE"/env/"$ENV"/config.php.bck
info current config.php saved in "$RACINE"/env/"$ENV"/config.php.bck
info "That's All!"