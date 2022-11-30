#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source ${SCRIPTPATH}/secrets.sh

# ##### The following parameters should be set in secrets.sh 
# ##### or can be supplied via command line arguments:

# Username and password for the Nielsen MFT portal
# USERNAME=""
# PASSWORD=""
# # Optional: Storage account SAS URL for the target container
# SAS_URL=""
# # Optional: Storage account connection string; leave SAS_URL empty when using this option
# CONNECTION_STRING=""
# # Target container name when using the Connction_string parameter
# CONTAINER_NAME=""
# #####

# Strict mode, fail on any error
set -euo pipefail

on_error() {
    set +e
    echo "There was an error, execution halted" >&2
    echo "Error at line $1"
    exit 1
}

trap 'on_error $LINENO' ERR

usage() { 
    echo "Usage: $0 " 1>&2;
    echo "[-u <username>] " 1>&2;
    echo "[-p <password>] " 1>&2;
    echo "[-s <sas-url>]" 1>&2; 
    echo "[-c <container name>]" 1>&2; 
    echo "[-C <connection string>]" 1>&2; 
    exit 1; 
}

# Initialize parameters specified from command line
while getopts ":u:p:s:c:C:" arg; do
	case "${arg}" in
		u)
			USERNAME=${OPTARG}
			;;
		p)
			PASSWORD=${OPTARG}
			;;
		s)
			SAS_URL=${OPTARG}
			;;
        c)
            CONTAINER_NAME=${OPARG}
            ;;
        C)
            CONNECTION_STRING=${OPTARG}
            ;;
		esac
done
shift $((OPTIND-1))

if [[ -z "$USERNAME" ]]; then
	echo "Enter the username for the mft portal"
	usage
fi

if [[ -z "$PASSWORD" ]]; then
	echo "Enter the password for the mft portal"
	usage
fi

get_session_id(){
    # authenticate:

    curl -k -v -i --user "${USERNAME}:${PASSWORD}" -D cookies.txt https://eumft.nielseniq.com/cfcc/login/login.jsp
    #  -H "Authorization: Basic [my encrypted string]" \
    session_cookie=$(curl GET -k \
        --user "${USERNAME}:${PASSWORD}" \
        -b cookies.txt \
        -D session.txt \
        -H "Host: localhost"  \
        "https://eumft.nielseniq.com/cfcc/control?view=view/filetransfer/browser/start.jsp")

    session_id=$(cat session.txt | awk -v f='FTServiceSessionID' '$0 ~ f {for (i=2; i<=NF; i++)  {print $i; exit}}' | sed -e  's/FTServiceSessionID\=//; s/\;//')
}

get_folders(){
    folders=$(curl -X GET -k \
        --user "${USERNAME}:${PASSWORD}" \
        -b session.txt \
        -H "Connection: close" \
        -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0" \
        -H "Accept: text/html,application/xhtml+xml,application/json;q=0.9,*/*;q=0.8" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        "https://eumft.nielseniq.com/cfcc/control?view=view/filetransfer/jsondirtree.jsp&action=gettree&path=/" | jq -C '.entries[].name' | awk -F\" '{print $(NF-1)}')
}

get_files_array(){
    files_json=$(curl -X GET -k \
        --user "${USERNAME}:${PASSWORD}" \
        -b session.txt \
        -H "Connection: keep-alive" \
        -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0" \
        -H "Accept: text/html,application/xhtml+xml,application/json;q=0.9,*/*;q=0.8" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        "https://eumft.nielseniq.com/cfcc/control?view=view/filetransfer/jsondirtree.jsp&action=gettree&path=/${folders}/" )

    read_id=$(echo ${files_json} | jq '.readfid' | awk -F\" '{print $(NF-1)}') 
    token=$(echo ${files_json} | jq '.token' | awk -F\" '{print $(NF-1)}') 
    
    files_array=$(echo ${files_json} | jq '.entries[].name' | awk -F\" '{print $(NF-1)}') 
}

get_target_filelist(){
    local target_files_array=$(az storage fs file list --exclude-dir -f "${CONTAINER_NAME}"  --connection-string "${CONNECTION_STRING}" --path / | jq '.[].name' | awk -F\" '{print $(NF-1)}' | awk -F\" '{print $(NF-1)}')
    printf "${target_files_array}"
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

process_file(){
     printf "Start processing file: ${file_name}\n"
            trap 'rm -f "$TMPFILE"' EXIT
            TMPFILE=$(mktemp) || exit 1
            printf "Creating temporary file: $TMPFILE\n"

            curl -k \
            --user "${USERNAME}:${PASSWORD}" \
            -b session.txt \
            -H "Connection: keep-alive" \
            -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0" \
            -H "Accept: application/octet-stream;charset=UTF-8" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            --output "${TMPFILE}" \
            "https://eumft.nielseniq.com/cfcc/control?view=servlet/fileTransfer&FileID=${read_id}&BrowserXfer=Y&BToken=${token}&AliasInPath=Y&ClientFileName=/tmp/${file_name}&SessionID=${session_id}&ServerFileName=/${folders}/${file_name}"

            printf "Copy file ${file_name} to storage container"
            if [[ ! -z "${SAS_URL}" ]]; then
                printf "Copy blob to container using SAS token."
                azcopy copy ${TMPFILE} "${SAS_URL}"
            else
                if [[ ! -z "${CONNECTION_STRING}" ]]; then
                    printf "Copy ${file_name} to ${CONTAINER_NAME} using connection string"
                    az storage azcopy blob upload -c ${CONTAINER_NAME} -s ${TMPFILE} -d ${file_name} --connection-string ${CONNECTION_STRING}
                fi
            fi               
            printf "Removing temporary file: $TMPFILE\n"
            rm -f ${TMPFILE}
}
main(){

    get_session_id
    get_folders
    get_files_array
    
    # IFS=', ' read -r -a target_files_array <<< $(get_target_filelist)


    printf "SessionID: ${session_id}\n"
    printf "Folder ${folders}\n"
    printf "ReadID: ${read_id}\n"
    printf "Token: ${token}\n"
    printf "${files_json}" > files.json

    readarray -t y <<< ${files_array}
    readarray -t x <<< $(get_target_filelist)

    for index in "${!y[@]}"
    do 
        file_name=${y[index]}
        file_exists=$(elementInArray ${file_name} ${x[@]})
        echo "FILE ${file_name} EXISTS: ${file_exists}"
        if [ $file_exists == "yes" ]; then
            echo "Skipping file ${file_name}" >&2
        else
            process_file
        fi
    done
 
    rm -f cookies.txt
    rm -f session.txt
    rm -f files.json
}
 main "${@}"


