#!/bin/bash
# 1 PROJECT
# 2 env
source env.cnf
source functions.cfg

function show_help() {
	# Here doc, note _not_ in quotes, as we want vars to be substituted in.
	# Note that the here doc uses <<- to allow tabbing (must use tabs)
	# Note argument zero used here
	cat > /dev/stdout <<- END
		${0} [-d] [-h] [-f]


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

[ ! -f "$PROJECTS"/"$PROJECT"/"$PROJECT".yml ] && error PROJECT "$PROJECT" unknown && exit 1
[ ! -d "$PROJECTS"/"$PROJECT"/env/"$ENV_DEPLOY" ] && error ENVIRONMENT "ENV_DEPLOY$" unknown && exit 1
# RELEASE optional

# while loop, and getopts
DEBUG=false
FORCE=false

while getopts "h?dfm:" opt
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
	m) RELEASE=${OPTARG} ;;
	esac
done

[[ "$FORCE" == true ]] && raz

info volume docker Moodle: "$RACINE"/moodle
if [ -d "$RACINE"/moodle ]; then
  error dir "$RACINE"/moodle already exists
  exit 1
else
  mkdir "$RACINE"/moodle
fi

docker compose up -d
n=0
while [ -z "$ret" ]  && [ "$n" -lt 5 ]; do
  ret=$(docker compose ps --status running | grep docker_moodle-app)
  sleep 3
  let n++
done 

update_moodle_volume "$PROJECT" "$ENV_DEPLOY" "$RELEASE"

docker exec -it docker_moodle-app php /var/www/html/admin/cli/install.php \
 --lang=fr --wwwroot=http://localhost:8088 --dataroot=/var/www/moodledata --dbtype=mariadb \
 --dbhost=docker_moodle-db  --dbname=moodle --dbuser=admin --dbpass=sesame \
 --prefix=mdl_ --fullname=Moodle_45 --shortname=moodle_minimal --adminpass=sesame \
 --adminemail=claude.billon@gmail.com --agree-license --non-interactive

docker exec -it docker_moodle-app chmod 0777 /var/www/html/config.php
docker exec -it docker_moodle-app  php /var/www/html/admin/cli/cron.php
#  copy config.php after fresh install
cp "$TARGET"/config.php  "$PROJECTS"/"$PROJECT"/env/"$ENV_DEPLOY"/config.php
cp "$TARGET"/config.php  "$PROJECTS"/"$PROJECT"/env/"$ENV_DEPLOY"/config.bck

info config.php saved in "$PROJECTS"/"$PROJECT"/env/"$ENV_DEPLOY"

success "That's All!"