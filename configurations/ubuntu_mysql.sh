## OPERATING SYSTEM
os_type="Ubuntu_64" # to list os types, use "VBoxManage list ostypes"
ram=8192
vram=256
cpus=4
time_zone="America/New_York" # America/New_York
disk_size=51200
language="en_US"
array_of_commands=(
    "mkdir ~/repos"
    "sudo snap install code --classic"
    "sudo apt-get install -y git"
    "sudo apt-get update"
    "sudo apt install mysql-server -y"
    "sudo snap install dbeaver-ce"
    )