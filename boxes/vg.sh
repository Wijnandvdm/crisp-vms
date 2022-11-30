#!/bin/bash

#
# Author: Dennis in 't Groen <dgroen@virtualsciences.nl>
#

usage="$(basename "$0") [OPTIONS]... [VAGRANT OPTIONS]... [VAGRANT ARGUMENTS]....
Commandline helper script for custom Vagrantfile implementations.

OPTIONS

-h, --help
Print this help message

*** Required ***
-bc [filename], --boxes-config [filename]

Configuration file (YAML) in ./config/boxes/[filename] in which [filename] is the 
yaml filename with extension.

*** Optional ***
-rt, --run-test    -  Run a single named test
-sk, --skip-tests  -  Skip unit tests if any defined
-to, --tests-only  -  Ignore provisioning script execution and only run unit tests. Use in com

VAGRANT OPTIONS

*** required ***
up, reload [box] [--provision]
provision, status, halt, destroy [box]


VAGRANT ARGUMENTS, 

*** Optional ***
box - Box to process; If no box specified all boxes in the configuration file will be processed
--provision Run the provisioning scripts if applicable


EXAMPLES

bash $(basename "$0") [--boxes-config=<file>] [--skip-tests] up/reload [box] --provision
bash $(basename "$0") [--boxes-config=<file>] [--skip-tests] [--tests-only] provision [box]
bash $(basename "$0") [--boxes-config=<file>] [--skip-tests] status/halt/destroy [box]

Run a single test
bash vg.sh -rt docker_mysql -to provision docker
"

 
#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
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
 
main() {
    readonly script_name=$(basename "${0}")
    readonly script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    readonly boxes_config_dir="${_config_dir}/${_boxes_config_subdir}"
    readonly valid_cfg_files=(${boxes_config_dir}/*.yaml)
    readonly config_options=("${valid_cfg_files[@]}" "${_extra_config_menu_options[@]}")
    check_args "${@}"
    if ! $_has_bc ; then 
        menu_config
        if [[ "${_bc_opt}" == "Quit" ]]; then       
            exit 1
        fi
        if [[ "${_bc_opt}" == "--help" ]]; then       
            show_help
            exit
        else
            _params="--boxes-config=$_bc_opt $_params"
        fi
    fi

    if [[ ! -d "./secrets" ]]; then
        mkdir -p "./secrets"
    fi
    printf '%b\n' "Passing arguments to vagrant with the following command: "
    printf '%b\n' "vagrant ${_params}"
    do_confirm
    eval "vagrant $_params"
    }
 
#{{{ Helper functions
#/ Test for valid arguments
#/ Transform to custom Vagrant option/argument string
#/
check_args () {
    while (( "$#" )); do
        case "$1" in
            -bc=*|-rt=*|--boxes-config=*|--run-test=*) # unsupported flags
            echo "Error: Unsupported flag $1" >&2
            exit 1
            ;;
            -h|--help)
            show_help
            exit
            ;;
            -rt|--run-test)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then    
                _params="$_params --run-test=$2"
                shift 2
            else
                echo "Error: Argument for $1 is missing" >&2           
                exit 1
            fi
            ;;
            -st|--skip-tests)
            _params="$_params --skip-tests"
            shift
            ;;
            -to|--tests-only)
            _params="$_params --tests-only"
            shift
            ;;
            -bc|--boxes-config)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then    
                tmp=$(elementInArray $2 "${valid_cfg_files[@]}") 
                if [[ "$tmp" == "no" ]]; then
                    echo "Error: Argument for $1 is invalid" >&2         
                    echo "expected one of: ${valid_cfg_files[@]}" 
                    exit 1
                fi
                _params="$_params --boxes-config=$2"
                _has_bc=true
                shift 2
            else
                echo "Error: Argument for $1 is missing" >&2           
                exit 1
            fi
            ;;
            -*=|--*=) # unsupported flags
            echo "Error: Unsupported flag $1" >&2
            exit 1
            ;;
            *|--*) # preserve positional arguments
            _params="$_params $1"
            shift
            ;;
        esac
    done 
    # set positional arguments in their proper place
    eval set -- "$_params"
}
menu_config(){
    PS3='Please choose a configuration: '    
    val_opt=$((${#config_options[@]}-1))    
    all_opt=$((${#config_options[@]})) 
    select opt in "${config_options[@]}"
    do
        case $REPLY in
            [1-$val_opt])
                _bc_opt="$opt"
                break
            ;;
            [$val_opt-$all_opt])
                case $opt in
                    "Quit")
                        _bc_opt="Quit"
                        break
                    ;;
                    "Help")
                        _bc_opt="--help"
                        break
                    ;;
                esac
                echo " OPT= $opt"
            ;;
            *) 
                echo "Invalid option $REPLY"
            ;;
        esac
    done
}
show_help(){
    printf '%b\n' ""
    printf '%b\n' "${usage}" | less -g
    exit
}

do_confirm(){
    read -p "Are you sure? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
}

joinByChar() {
  local IFS="$1"
  shift
  echo "$*"
}

# arguments 
# array - An array with valid optionss
# element - String value to search for in the array
# See: https://dev.to/meleu/checking-if-an-array-contains-an-element-in-bash-5bn1
elementInArray() {
  local element="$1"
  shift
  local array=("$@")
  [[ "$element" == @($(joinByChar '|' "${array[@]//|/\\|}")) ]] && echo yes || echo no
}

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT
 
ctrl_c() {
  echo "** CTRL-C invoked by user."
}

#}}}
 
main "${@}"

