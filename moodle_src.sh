RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELOW=$(tput setaf 3)
BLUE=$(tput setaf 14)
NC=$(tput sgr 0)

function info() { echo "${BLUE}${@}${NC}"; }
function warn() { echo "${YELOW}${@}${NC}"; }
function error() { echo "${RED}${@}${NC}"; }
function success() { echo "${GREEN}${@}${NC}"; }

# 1 PROJECT
# 2 ENV
# 3 RELEASE (OPTIONAL)
info "$FUNCNAME" Début
[ -z "$1" ] && error  PROJECT parameter missing && exit 1
[ -z "$2" ] && error  ENVIRONMENT parameter missing && exit 1
# RELEASE optional
PROJECT="$1"
ENV_DEPLOY="$2" 
[  -z "$3" ] && RELEASE=current || RELEASE="$3"
   
RACINE=$(pwd)
TARGET="$RACINE"/moodle 
MOODLE_SRC=/home/cb/adele/moodle

info "$PROJECT" "$ENV_DEPLOY" "$RELEASE" "$TARGET"

[ ! -d moodle ] && mkdir moodle || exit 
   
cd "$MOODLE_SRC" || exit
  
info release before: "$RELEASE"
if [ "$RELEASE" == 'current' ]; then
  RELEASE=$(git tag -l | sort -rn | head -n 1)
fi

info release: "$RELEASE"
[ -z "$RELEASE" ] && error release not defined! && exit
git checkout "$RELEASE"
[ $? -ne 0 ] && error git checkout "$RELEASE" && exit  
rsync -a --info=progress2 --exclude .git --delete /home/cb/adele/moodle/ "$TARGET"/
info "mise à jour depuis git de $TARGET"
info "That's All!"
