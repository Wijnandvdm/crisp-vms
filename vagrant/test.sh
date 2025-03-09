#!/bin/bash


# commands I'd like to add to provisioner:
echo "great success!"
echo "alias python='python3'" >> ~/.bashrc
mkdir ~/repos

sudo apt update && sudo apt install python3-pip

# install poetry and add to PATH
pip install poetry
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc