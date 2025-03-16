VIRTUAL_MACHINE_NAME = "tabula-rasa"
OS = "bento/ubuntu-22.04"
MEMORY = "8192"
CPUS = 4
PROVISIONING_SCRIPT = "provisioning.sh"

Vagrant.configure("2") do |config|
    config.vm.box = OS
    config.vm.hostname = VIRTUAL_MACHINE_NAME
    config.vm.provider "virtualbox" do |vb|
      vb.memory = MEMORY
      vb.cpus = CPUS
      vb.name = VIRTUAL_MACHINE_NAME
    end
    config.vm.provision "shell", path: PROVISIONING_SCRIPT # copy script to /vagrant folder and execute
    config.vm.provision "file", source: "~/.gitconfig", destination: "~/.gitconfig" # copy your local gitconfig file to your virtual machine
  end
  