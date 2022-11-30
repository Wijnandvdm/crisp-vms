#!/bin/bash -x
log_line=""
### Filename 
# f_name
### Optional hostname
# h_name

### Overrides the default "echo" command with printf to provide
### proper newline inserts.

echo()
    case    ${IFS- } in
    (\ *)   printf  %b\\n "$*";;
    (*)     IFS=\ $IFS
            printf  %b\\n "$*"
            IFS=${IFS#?}            
    esac

function f_log {
    log_line=$1
    if [[ ! "$2" == "" ]]; then
      f_name=$2
    fi
    if [[ ! "$3" == "" ]]; then
      h_name=$3
    fi
    local logdir="$PWD/log"
      
    # in case of vagrant unit test through provisioner
    if [[ "$HOSTNAME" == "$h_name" ]]; then 
      logdir="/vagrant/log" 
    fi
    
    mkdir -p "$logdir"
    log_line="$(date +"%Y-%m-%d %I:%M:%p") "$log_line""
    l_file="${logdir}/${f_name}"
    if [[ -f "$l_file" ]]; then
      $(echo "$log_line" >> "$l_file")
    else
      $(echo "$log_line" > "$l_file")
    fi
}
# tmp=$(ssh docker "sudo adduser dennis --shell /bin/bash --home /home/dennis" 2>&1) || echo $tmp >> baa.txt
function exec_cmd(){
        local h_name=$1
        local s_cmd=$2
        if [[ ! "$HOSTNAME" == "${h_name}" ]]; then 
          # execute remote
          output=$(ssh "${h_name}" "$(${s_cmd})") 
          f_log "${output}"
          echo "${output}"
        else
          output=("$(${s_cmd})")
          f_log "${output}" "${f_name}" "${h_name}"
          echo "${output}"
        fi
}

### Validates packet loss in percentage against expected loss value
function validate_ping(){
  local h_name=$1
  local ip_addr=$2
  local assert_perc=$3
  local loss_perc=$(exec_cmd $h_name "ping -c3 $ip_addr" | grep -oP '\d+(?=% packet loss)')
  
  if [[ $loss_perc == $assert_perc ]]; then 
    f_log "... Layer 2 ping test OK. $loss_perc% package loss"
  else
    f_log "... Layer 2 test FAILED with $loss_perc% package loss. Expected value: $assert_perc%"
  fi
}

function set_log_dir(){
  local h_name=$1
  local logdir=''
  
  if [[ ! "$HOSTNAME" == "$h_name" ]]; then
    logdir="$PWD/log"
  else
    # in case of vagrant unit test through provisioner
    logdir="/vagrant/log"
  fi
  mkdir -p "$logdir"
}
