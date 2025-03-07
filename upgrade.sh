#!/bin/bash

source env.cnf
source functions.cfg

info "$FUNCNAME" Start

[ ! -f "$PROJECTS"/"$PROJECT"/"$PROJECT".yml ] && error PROJECT "$PROJECT" unknown && exit 1
[ ! -d "$PROJECTS"/"$PROJECT"/env/"$ENV_DEPLOY" ] && error ENVIRONMENT "ENV_DEPLOY$" unknown && exit 1
# RELEASE optional
RELEASE="$1"

docker compose up -d
# docker_moodle-app must be up
n=0
while [ -z "$ret" ]  && [ "$n" -lt 5 ]; do
  ret=$(docker compose ps --status running | grep docker_moodle-app)
  sleep 3
  let n++
done

info docker_moodle-app up and running  
# mettez à jour config.php manuellement dans  "$PROJECTS"/"$PROJECT"/env/"$ENV_DEPLOY"/config.php
# c'est cette version qui sera prise en compte lorsde la prochaine lise à jour
# sinon on récupere la config en cours avant mise à jour
if [ ! -f "$PROJECTS"/"$PROJECT"/env/"$ENV_DEPLOY"/config.php ]; then
  cp "$TARGET"/config.php "$PROJECTS"/"$PROJECT"/env/"$ENV_DEPLOY"/config.php   
fi

docker exec -it docker_moodle-app  php admin/cli/maintenance.php --enable 
update_moodle_volume "$PROJECT" "$ENV_DEPLOY" "$RELEASE" 
cp "$PROJECTS"/"$PROJECT"/env/"$ENV_DEPLOY"/config.php "$TARGET"/config.php
 
docker exec -it docker_moodle-app  php admin/cli/upgrade.php
docker exec -it docker_moodle-app  php admin/cli/maintenance.php --disable
docker exec -it docker_moodle-app  php admin/cli/purge_caches.php
  
info "$FUNCNAME" Fin