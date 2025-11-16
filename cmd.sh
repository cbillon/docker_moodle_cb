#!/bin/bash

source includes/env.cnf
source includes/functions.cfg

function show_help() {
	# Here doc, note _not_ in quotes, as we want vars to be substituted in.
	# Note that the here doc uses <<- to allow tabbing (must use tabs)
	# Note argument zero used here
	cat > /dev/stdout <<- END
		${0} [-d] [-h] [-f]

    REQUIRED ARG
	  -c : command

	OPTIONAL ARGS:
	  -d : debug default : false			
	  -h : show help
    
    - cd docker_moodle_cb
		- ./cmd.sh -c start

	Les commandes disponibles : 
	- start, stop, down
	- exec-app, exec-db, exec-web pour executer une commande dans le container eponyme
	- status, stats, top 

END
}

# while loop, and getopts
DEBUG=false
while getopts "h?o?c:d" opt
do
	# case statement
	case "${opt}" in
	h|\?)
		show_help
		# exit code
		exit 0
		;;	
	o) OPT=${OPTARG} ;;
	c) CMD=${OPTARG} ;;
  d) DEBUG=true ;;
	
	esac
done


case "$CMD" in

exec-app)
  docker compose exec -it docker_moodle-app bash ;;

exec-db)
  docker compose exec -it docker_moodle-db bash ;;

exec-web)
  docker compose exec -it docker_moodle-web bash ;;

start)
  echo opt "$OPT"
  if [[ "$OPT" == 'f' ]]; then
	 echo optio force-recreate
   docker compose up -d --force-recreate
	else
	 docker compose up -d
	fi
	echo opt "$OPT" ;;
	

stop)
  docker compose stop ;;
down)
  docker compose down ;;
stats)
  docker compose stats ;;
status)
  docker compose ps --status running ;;
top)
  docker compose top ;;
*)
  error "$CMD" not yet supported
esac

info "That's All!"
