#!/bin/bash

##############
# curl -sSL url/to/install.sh | bash -s
##############

# TODO: clone repository to .dotfiles in home
# TODO: run setup.sh
# TODO: run restore or backup
# TODO: run post-setup.sh

app_dir="$HOME/.dotfiles"
script_dir="$app_dir/scripts"


chmod +x "$script_dir/setup.sh"
chmod +x "$script_dir/start.sh"
chmod +x "$script_dir/post-setup.sh"

$script_dir/setup.sh
$script_dir/start.sh
$script_dir/post-setup.sh