#!/bin/bash
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
IFS=$'\t\n' # Split on newlines and tabs (but not on spaces)
 
#}}}
 
main() {
# check_args "${@}"
printf "In main"
ssh_keygen "${@}"
}
 
#{{{ Helper functions
ssh_keygen(){
  printf "KEYGEN SCRIPT"
  if [ $# -eq 0 ] 
    then 
      error 'Usage: ./keygen.sh filename-for-key' 
      exit; 
  fi
  local KEYPATH="$(dirname "$1")" 

  echo Checking if path "${KEYPATH}" exists. 
  if [ ! -d "${KEYPATH}" ]; then
    mkdir -p "${KEYPATH}" >> /dev/null 2>&1
  fi
  ssh-keygen -t rsa -f "$1" -b 2048 -q -N """"
}

error() {
    printf "%s\\n" "${*}" 1>&2
  }
  
#}}}
 
main "${@}"
 
# cursor: 33 del