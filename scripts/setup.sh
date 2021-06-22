#!/bin/bash

function install_yq () {
	# install yq for yaml
	# https://learnxinyminutes.com/docs/yaml/
	# https://mikefarah.gitbook.io/yq/
	sudo wget -q https://github.com/mikefarah/yq/releases/download/v4.9.6/yq_linux_amd64  -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
}

function install_picom () {
	# https://www.linuxfordevices.com/tutorials/linux/picom
	sudo apt install -qqqy cmake meson git pkg-config asciidoc libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev  libpcre2-dev  libevdev-dev uthash-dev libev-dev libx11-xcb-dev
	cd /tmp
	git clone https://github.com/jonaburg/picom
	cd picom
	git submodule update --init --recursive
	meson --buildtype=release . build
	ninja -C build
	sudo ninja -C build install
	cd ..
	rm picom -rf
}


function install_i3_gaps () {
	# mixing https://gist.github.com/chewwt/cbdb71b92b9a45e3ac9314e64c58cbf4
	# and https://gist.github.com/boreycutts/6417980039760d9d9dac0dd2148d4783
    sudo add-apt-repository -y ppa:regolith-linux/stable
    sudo apt install i3-gaps

	cd /tmp
	sudo apt install -y libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm0 libxcb-xrm-dev automake libxcb-shape0-dev libxcb-xrm-dev

	# clone the repository
	git clone https://www.github.com/Airblader/i3 i3-gaps
	cd i3-gaps

	sudo apt install -qqqy meson asciidoc
	meson -Ddocs=true -Dmans=true ../build
	meson compile -C ../build
	sudo meson install -C ../build

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
		if [[ "$1" == "picom" ]]; then
			install_picom
			return 1
		fi
		
		if [[ "$1" == "i3-gaps" ]]; then
			install_i3_gaps
			return 1
		fi

		apt_install $1
	fi

	echo "$1 installed"

}

# ask for password
sudo -p "Please enter your admin password: " date 2>/dev/null 1>&2
# Add and update deps
sudo add-apt-repository ppa:mmstick76/alacritty -y
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
commands=(rofi xsel flameshot compton viewnior hsetroot make jq i3 i3blocks neovim zsh yq bat alacritty i3lock-fancy picom i3-gaps)
printf "\n"
for c in ${commands[@]}
do
	install $c
done

printf "\n"


