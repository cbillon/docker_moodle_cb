#!/bin/bash

source includes/env.cnf
source includes/functions.cfg

function show_help() {
	# Here doc, note _not_ in quotes, as we want vars to be substituted in.
	# Note that the here doc uses <<- to allow tabbing (must use tabs)
	# Note argument zero used here
	cat > /dev/stdout <<- END
		${0} [-d] [-h] [-f] [-p] [-e]
    REQUIRED ARGS:
      -p : Project
      -e : Environment	


		OPTIONAL ARGS:
		-d : debug default : false
		-h : show help
    -f :force - option force re initialisation if previous install exists
		-r : release version  (optional) ; must exists as tag in MOODLE_SRC branch PROJECT
		EXAMPLES
    - cd docker_moodle_cb
		- ./install.sh -f -p demo -e dev
END
}

# RELEASE optional
# while loop, and getopts
DEBUG=false
FORCE=false
RELEASE=''

while getopts "h?de:fp:r:" opt
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
  f) FORCE=true ;;
	p) PROJECT=${OPTARG} ;;
  r) RELEASE=${OPTARG} ;;

	esac
done
[ -d "$VOL_MOODLE" ] && [[ "$FORCE" == false ]]&& error dir "$VOL_MOODLE" already exists &&  exit 1
[[ "$FORCE" == true ]] && raz

[ ! -f "$PROJECTS"/"$PROJECT"/"$PROJECT".yml ] && error PROJECT "$PROJECT" unknown && exit 1
[ ! -d "$PROJECTS"/"$PROJECT"/env/"$ENV_DEPLOY" ] && error ENVIRONMENT "$ENV_DEPLOY" unknown && exit 1


info volume docker Moodle: "$VOL_MOODLE"


# gen from template
envsubst '$PHP_VERSION $ENV' < "$RACINE"/templates/php.dockerfile.tmplt > "$RACINE"/php.dockerfile
envsubst '$PHP_VERSION $ENV' < "$RACINE"/templates/php.cron.dockerfile.tmplt > "$RACINE"/cron/cron.dockerfile

docker compose up -d

n=0
while [ -z "$ret" ]  && [ "$n" -lt 5 ]; do
  ret=$(docker compose ps --status running | grep docker_moodle-app)
  sleep 1
  ((n++))
done 

update_moodle_volume "$PROJECT" "$ENV" "$RELEASE"

docker exec -it docker_moodle-app php /var/www/html/admin/cli/install.php \
 --lang="$LANG" --wwwroot=http://localhost:8088 --dataroot="$VOL_MOODLEDATA" --dbtype="$DBTYPE" \
 --dbhost=docker_moodle-db  --dbname="$DBNAME" --dbuser="$DBUSER" --dbpass="$DBPASS" \
 --prefix=mdl_ --fullname="$FULLNAME" --shortname="$SHORTNAME" --adminpass="$ADMINPASS"\
 --adminemail="$ADMINEMAIL" --agree-license --non-interactive

docker exec -it docker_moodle-app chmod 0777 /var/www/html/config.php
docker exec -it docker_moodle-app  php /var/www/html/admin/cli/cron.php
#  copy config.php after fresh install
cp "$VOL_MOODLE"/config.php  "$RACINE"/env/"$ENV"/config.php
cp "$VOL_MOODLE"/config.php  "$RACINE"/env/"$ENV"/config.bck

info config.php saved in "$PROJECTS"/"$PROJECT"/env/"$ENV"

success "That's All!"