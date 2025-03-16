# CrispVMs
First things first, congratulations for actually reading a README!

Secondly, CrispVMs is a tool for generating disposable Virtual Machines (VMs) for development purposes. It provides a quick and easy way to spin up fully provisioned VMs, so you can focus on coding instead of setup.  

## How it works
1. **Install and familiarize yourself with Vagrant**:
   - Check out the [Vagrant documentation](https://developer.hashicorp.com/vagrant/docs) to get started.  

2. **Create and Configure Your VM**  
   - *(Optional)* Customize the provisioning script (`provisioning.sh`) to install additional/other tools.  
   - *(Optional)* Adjust VM settings by modifying the parameters at the top of the `Vagrantfile`.  
   - Spin up your VM with:  
     ```sh
     vagrant up
     ```  
   - Enable the **VS Code Remote SSH extension** by syncing your SSH config with:  
     ```sh
     vagrant ssh-config > ~/.ssh/config
     ```  

That’s pretty much it! Still want to know more? Don't be shy, ask the creator of this repo!