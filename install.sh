#!/bin/bash
# 1 PROJECT
# 2 env
source env.cnf
source functions.cfg

[ ! -f "$PROJECTS"/"$PROJECT"/"$PROJECT".yml ] && error PROJECT "$PROJECT" unknown && exit 1
[ ! -d "$PROJECTS"/"$PROJECT"/env/"$ENV_DEPLOY" ] && error ENVIRONMENT "ENV_DEPLOY$" unknown && exit 1
# RELEASE optional

info "$@"

init=$(echo "$@" | grep "\-\-force")
if [ ! -z "$init" ]; then
   raz
  [ "$#" -eq 2 ] && RELEASE="$1"  
else
  [ "$#" -eq 1 ] && RELEASE="$1"
fi

info volume docker Moodle: "$TARGET"
if [ -d "$TARGET" ]; then
  error dir "$TARGET" already exists
  exit 1
else
  mkdir "$TARGET" 
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