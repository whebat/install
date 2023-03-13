#!/bin/sh

wget

if [ "$(id -u)" -eq 0 ]; then
   printf "%s\n" "Please run as an unprivileged user."
   exit 1
fi

# mkdir is not required for Fedora Workstation 37.
mkdir -vp \
  ~/.config \
  ~/.cache \
  ~/.local/share \
  ~/.local/state
# All folders should be empty by default.
rmdir -v ~/Desktop
rmdir -v ~/Downloads
rmdir -v ~/Templates
rmdir -v ~/Public
rmdir -v ~/Documents
rmdir -v ~/Music
rmdir -v ~/Pictures
rmdir -v ~/Videos
sudo sed -i "s|Desktop|desktop|"     /etc/xdg/user-dirs.defaults
sudo sed -i "s|Downloads|desktop|"   /etc/xdg/user-dirs.defaults
sudo sed -i "s|Templates|desktop|"   /etc/xdg/user-dirs.defaults
sudo sed -i "s|Public|public|"       /etc/xdg/user-dirs.defaults
sudo sed -i "s|Documents|documents|" /etc/xdg/user-dirs.defaults
sudo sed -i "s|Music|music|"         /etc/xdg/user-dirs.defaults
sudo sed -i "s|Pictures|pictures|"   /etc/xdg/user-dirs.defaults
sudo sed -i "s|Videos|videos|"       /etc/xdg/user-dirs.defaults
xdg-user-dirs-update

# Config shell.
sudo usermod -s /usr/bin/zsh "$(id -nu 1000)"
# Remove bash from user's home folder.
test -f ~/.bash_history && rm -f ~/.bash_history
test -f ~/.bash_logout  && rm -f ~/.bash_logout
test -f ~/.bashrc       && rm -f ~/.bashrc
# Create common folders.
mkdir -p ~/bin

# Rootless Docker
sudo dnf install -y moby-engine podman
sudo usermod -aG podman "$(whoami)"
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
docker run --rm hello-world

# Create a snapshot
# sudo btrfs subvolume list /
mkdir /mnt/snapshot
sudo btrfs subvolume snapshot '/home/' "/mnt/snapshot/@home_$(date +%Y%m%d_%H%M%S)"
sudo btrfs subvolume snapshot '/'      "/mnt/snapshot/@root_$(date +%Y%m%d_%H%M%S)"
