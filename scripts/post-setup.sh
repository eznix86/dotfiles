#!/bin/bash
####
# NOT REQUIRED BUT NEEDED LATER
####

while true; do
    printf "Do you want to continue to post-setup (optional)? (y/n): " 
    read post_setup
    if [[ "$post_setup" =~ ^(y|Y|n|N)$ ]]; then
        break
    fi
done


if [[ $post_setup =~ ^(n|N)$  ]]; then
    exit 1
fi


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
