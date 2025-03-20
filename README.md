# CrispVMs
First things first, congratulations for actually reading a README!

Secondly, CrispVMs is a tool for generating disposable Virtual Machines (VMs) for development purposes. It provides a quick and easy way to spin up fully provisioned VMs, so you can focus on coding instead of setup.

## Prerequisites
Before you begin, make sure you have the following installed:
- **[Vagrant](https://developer.hashicorp.com/vagrant/docs)**
  A tool for managing virtual machine environments.
- **[VirtualBox](https://www.virtualbox.org/)**
  A free and open-source virtualization software for creating and managing VMs.
- **[Git Bash](https://git-scm.com/)** – A command-line tool for running Git and Unix commands on Windows.
  - The provisioning process includes setting up a `gitconfig` and `git-credentials` file.
  - If you don’t need these, feel free to remove the corresponding lines in the Vagrantfile.
- **[VSCode](https://code.visualstudio.com/)**
  A popular code editor with support for extensions and remote development.
- **[VSCode Remote - SSH Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)**
  Allows you to connect to a remote machine using SSH directly from VSCode.

## How it works
1. **Create and Configure Your VM**
   - *(Optional)* Customize the provisioning script (`provisioning.sh`) to install any additional tools you may need.
   - *(Optional)* Modify VM settings such as memory or CPU in the `Vagrantfile` by adjusting the parameters at the top.
   - Spin up the VM using the following command:
     ```sh
     vagrant up
     ```

2. **Connect with VS Code Remote SSH**
   - Sync your SSH configuration to enable the **VS Code Remote - SSH extension** - IMPORTANT NOTE, if you do not wish to overwrite your current ssh config, append with `>>` instead of replace with `>`:
     ```sh
     vagrant ssh-config > ~/.ssh/config
     ```
   - This allows you to seamlessly connect to your VM from VS Code and start working on your project.

That’s pretty much it! Still want to know more? Don't be shy, ask the creator of this repo!