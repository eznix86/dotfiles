#!/bin/bash

function install_yq () {
	# install yq for yaml
	# https://learnxinyminutes.com/docs/yaml/
	# https://mikefarah.gitbook.io/yq/
	sudo wget -q https://github.com/mikefarah/yq/releases/download/v4.9.6/yq_linux_amd64  -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
}

function apt_install () {
	sudo apt install -qqqy $1 
}

function install() {
	if ! command -v $1 &> /dev/null; then
		echo "$1 could not be found"
		if [[ "$1" == "yq" ]]; then
			install_yq
			return 1
		fi

		apt_install $1
	fi

	echo "$1 installed"

}

# ask for password
sudo -p "Please enter your admin password: " date 2>/dev/null 1>&2
# Add and update deps
sudo add-apt-repository ppa:mmstick76/alacritty
sudo apt update -yq

# install custom items
# rofi for search in i3
# flameshort for screenshots
# xprop for class name of windows (not installed)
# hsetroot to set background
# compton compostitor 
# make
# jq
# i3blocks for i3
# neovim
# zsh
# yq for yaml
# batcat https://github.com/sharkdp/bat alias bat
commands=(rofi xsel flameshot compton viewnior hsetroot make jq i3 i3blocks neovim zsh yq bat alacritty)
printf "\n"
for c in ${commands[@]}
do
	install $c
done

printf "\n"


