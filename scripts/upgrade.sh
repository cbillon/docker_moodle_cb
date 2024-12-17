#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELOW=$(tput setaf 3)
BLUE=$(tput setaf 14)
NC=$(tput sgr 0)

function info() { echo "${BLUE}${@}${NC}"; }
function warn() { echo "${YELOW}${@}${NC}"; }
function error() { echo "${RED}${@}${NC}"; }
function success() { echo "${GREEN}${@}${NC}"; }


deploy () {

  info "$FUNCNAME" Début
  docker exec -it docker_moodle-app  php admin/cli/maintenance.php --enable

  rsync -a --exclude .git --delete /home/cb/adele/projects/"$PROJECT"/releases/"$RELEASE"/*  ../moodle/
  cp config.php ../moodle/
    
  # [] "$DEBUG" = true ]&&info config.php copy in "$SERVER" from previous deploiment
  
  docker exec -it docker_moodle-app  php admin/cli/upgrade.php
  docker exec -it docker_moodle-app  php admin/cli/maintenance.php --disable

  info "$FUNCNAME" Fin

}

[ -z $1 ] && error "$1" Parametre projet missing && exit 1

PROJECT="$1"
[  -z "$2" ] && RELEASE='current' || RELEASE="$2"
info Project: "$PROJECT" Release: "$RELEASE"

deploy "$PROJECT" "$RELEASE"
 
info "That's All!"