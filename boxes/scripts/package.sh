#!/bin/bash -x
#
# Author: Dennis in 't Groen <dgroen@virtualsciences.nl>
#
#/ Usage: SCRIPTNAME [OPTIONS]... [ARGUMENTS]...
#/
#/
#/ OPTIONS
#/ -h, --help
#/ Print this help message
#/
#/ EXAMPLES
#/
 
 
#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}
#{{{ Variables
readonly script_name=$(basename "${0}")
readonly script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly script_config="$1"
readonly boxname="$2"
readonly target="$3"
readonly target_path="$(dirname "$3")" 
IFS=$'\t\n' # Split on newlines and tabs (but not on spaces)
 
#}}}
 
main() {
# check_args "${@}"
vagrant_package "${@}"
}
 
#{{{ Helper functions
vagrant_package(){
  printf "PACKAGE SCRIPT"
  if [ $# -eq 0 ] 
    then 
      error 'Usage: ./package.sh boxname target' 
      exit; 
  fi

  echo Checking if path "${target_path}" exists. 
  if [ ! -d "${target_path}" ]; then
    mkdir -p "${target_path}" >> /dev/null 2>&1
  fi
  $(vagrant --boxes-config="${script_config}"  package "${boxname}" --output="${target}")
}

error() {
    printf "%s\\n" "${*}" 1>&2
  }
  
#}}}
 
main "${@}"
