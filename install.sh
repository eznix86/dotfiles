#!/bin/bash

##############
# Setup personal dotfiles
##############

DIRECTORY="$HOME/.dotfiles"

mkdir -p $DIRECTORY

curl -sSL https://raw.githubusercontent.com/theArtechnology/dotfiles/main/install.sh | bash -s

git clone git@github.com:theArtechnology/dotfiles.git $DIRECTORY

app_dir="$HOME/.dotfiles"
script_dir="$app_dir/scripts"


chmod +x "$script_dir/setup.sh"
chmod +x "$script_dir/start.sh"
chmod +x "$script_dir/post-setup.sh"

$script_dir/setup.sh
$script_dir/start.sh
$script_dir/post-setup.sh