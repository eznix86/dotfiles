#!/bin/bash
####
# NOT REQUIRED BUT NEEDED LATER
####

# install docker
curl -sSL https://get.docker.com  | sudo bash -s

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker 
docker run hello-world


# setup zsh
sudo chsh -s $(which zsh) root
chsh -s $(which zsh) $USER
cat /etc/passwd | grep $USER
