#!/bin/bash

### CREATE_UNIX_USER ###
### usage
### source  <script_location>/utils-users.sh && create_unix_user <hostname> <username> <script_location> <log_location> <secrets_location>
### params
###     script_location: relative / absolute path to the scripts folder (required)
###     username: name for the new user (required)
###     hostname: hostname of the target machine (required)
###     log_location: relative / absolute path to the log folder (required)
###     secrets_location: relative / absolute path to the secrets folder (required)

function create_unix_user(){
    local BOX=""
    # target hostname
    local h_name=$1
    # new username
    local u_name=$2
    # Script folder
    sf_name=$3
    # Target log folder
    log_dir=$4
    # Secrets location (folder)
    s_loc=$5
    printf "SLOC=${s_loc}"
    f_name="${h_name}_$(date +"%Y%m%d").log"
    source $sf_name/utils/utils-command.sh  
    f_log "###   Create user ${u_name} on host ${h_name}    ###"
    ### CREATE USER
    
    if [[ ! "$HOSTNAME" == "$h_name" ]]; then 
        # execute remote; 
        BOX=$(ssh $h_name "sudo hostnamectl" | grep  "Operating System" | awk -F: '{ print $2}')
       
        if [[ $BOX == *"Ubuntu"* ]]; then            
            # skip login prompt
            tmp=$(ssh $h_name "sudo adduser --disabled-password --gecos '' $u_name --shell /bin/bash --home /home/$u_name" 2>&1) || echo $tmp >> $log_dir/$f_name         
            tmp=$(ssh $h_name "sudo usermod -aG sudo $u_name" 2>&1) || echo $tmp >> $log_dir/$f_name
        else
            tmp=$(ssh $h_name "sudo adduser $u_name --shell /bin/bash --home /home/$u_name" 2>&1) || echo $tmp >> $log_dir/$f_name
            tmp=$(ssh $h_name "sudo usermod -aG wheel $u_name" 2>&1) || echo $tmp >> $log_dir/$f_name
        fi    
        set_password $h_name $u_name $s_loc true 
    else    
        # local execution
        BOX=$(sudo hostnamectl | grep  "Operating System" | awk -F: '{ print $2}')
        if [[ $BOX == *"Ubuntu"* ]]; then        
            # skip login prompt
            sudo adduser --disabled-password --gecos '' $u_name --shell /bin/bash --home /home/$u_name >> $log_dir/$f_name
            sudo  usermod -aG sudo $u_name >> $log_dir/$f_name
        else
            sudo adduser $u_name --shell /bin/bash --home /home/$u_name >> $log_dir/$f_name
            sudo usermod -aG wheel $u_name >> $log_dir/$f_name
        fi       
        set_password $h_name $u_name $s_loc false 
    fi
   
    set_authorized_keys $h_name $u_name $s_loc
}

### GENERATE "SECURE" PASSWORD ###
function set_password(){
    # hostname
    local h_name=$1
    # username
    local u_name=$2
    # secrets folder
    local s_loc=$3
    # execute remote / local
    local is_remote=$4
    secret=$(date +%s | sha256sum | base64 | head -c 12)
    if [[ $is_remote == true ]]; then 
        ssh $h_name "echo $u_name':'$secret | sudo chpasswd"
        echo "Password stored in: ${s_loc}/${h_name}_pwd" && echo "${u_name} : $(cut -d'\' -f1 <<<${secret}) >> ${s_loc}/${h_name}_pwd"
    else 
        echo $u_name':'$secret | sudo chpasswd
        echo "Password stored in: ${s_loc}/${h_name}_pwd" && echo "${u_name} : $(cut -d'\' -f1 <<<${secret})" >>  "${s_loc}/${h_name}_pwd"
    fi    
}

### SET AUTHORIZED KEY FOR REMOTE SSH ACCESS
function set_authorized_keys(){
    # hostname
    local h_name=$1
    # username
    local u_name=$2
    # secrets folder
    local s_loc=$3
    exec_cmd $h_name "mkdir /home/${u_name}/.ssh"
    exec_cmd $h_name "chmod 700 /home/${u_name}/.ssh"
    
    local KEYFILE="${s_loc}/${u_name}_id_rsa"
    ssh_keygen "${KEYFILE}"
    local KEYPATH="$(dirname "${KEYFILE}")"
    local AUTHFILE="/home/${u_name}/.ssh/authorized_keys"
    if grep -q "${KEYFILE}.pub" "${AUTHFILE}"; then
        echo key exists.;
    else
        cat "${KEYFILE}.pub" >> "${AUTHFILE}"
        echo "key added"
    fi;
    chmod 600 "${AUTHFILE}"
    chown -R "${u_name}":"${u_name}" "/home/${u_name}/.ssh"
}

ssh_keygen(){
  if [ $# -eq 0 ] 
    then 
      error 'Usage: ./keygen.sh filename-for-key' 
      exit; 
  fi
  sudo mkdir -p "$(dirname "$1")" >> /dev/null 2>&1
  sudo ssh-keygen -t rsa -f "$1" -b 2048 -q -N """" <<< ""$'\n'"y" 2>&1 >/dev/null
}