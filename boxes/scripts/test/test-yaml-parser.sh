#!/bin/bash


#{{{ Bash settings
# abort on nonzero exitstatus
#set -o errexit
# abort on unbound variable - Not suitable in this UC->test on empty arg value required
# set -o nounset
# don't hide errors within pipes
set -o pipefail
#shopt -s extglob
#}}}
#{{{ Variables

# Internal Field Separator
IFS=$'\t\n' # Split on newlines and tabs (but not on spaces)

# initialze global variables
_params=""
_has_bc=false
_bc_opt=""
_config_dir="./config"
_boxes_config_subdir="boxes"
_extra_config_menu_options=("Quit" "Help") 


#}}}
 
 main(){
    local HOSTNAME=""
    local SERVICES=""
    local COMPOSE_FILE=""
    printf "%b\n" "config=$2"
    printf "%b\n Starting test-yaml-parser in: "`pwd`
    cur_dir="$(dirname "$0")"
    source "./scripts/utils/utils-yaml.sh"
    source "./scripts/utils/utils-command.sh"

    key=$1
    cfg=$2
    # Get config from yaml
    eval $(parse_yaml "${cfg}" "${key}")
    eval HOSTNAME=\$$key\_vm_hostname
    eval COMPOSE_FILE=\$$key\_services_docker_compose_file
    printf "%b\n" "\n${COMPOSE_FILE}"

 }

main "${@}"