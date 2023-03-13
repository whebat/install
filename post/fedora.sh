#!/bin/sh

# wget -qO- https://raw.githubusercontent.com/whebat/install/main/post/fedora.sh | sh

if [ "$(id -u)" -eq 0 ]; then
   printf "%s\n" "Please run as an unprivileged user."
   exit 1
fi

# Config sudo. The last two lines are removed at the end of the script.
sudo tee -a /etc/sudoers.d/README << EOF
# User overrides.
# Show asterisk on password input.
Defaults !tty_tickets
Defaults env_reset,pwfeedback
# sudo lasts 2 hours.
Defaults:$USER timestamp_timeout=120
EOF

# Setup folders
# All folders should be empty by default.
rmdir -v      \
  ~/Desktop   \
  ~/Downloads \
  ~/Templates \
  ~/Public    \
  ~/Documents \
  ~/Music     \
  ~/Pictures  \
  ~/Videos
rm -v ~/.config/user-dirs.dirs
test -f ~/.bash_history && rm -f ~/.bash_history
test -f ~/.bash_logout  && rm -f ~/.bash_logout
test -f ~/.bashrc       && rm -f ~/.bashrc
sudo sed -i "s|Desktop|desktop|"     /etc/xdg/user-dirs.defaults
sudo sed -i "s|Downloads|downloads|" /etc/xdg/user-dirs.defaults
sudo sed -i "s|Templates|templates|" /etc/xdg/user-dirs.defaults
sudo sed -i "s|Public|public|"       /etc/xdg/user-dirs.defaults
sudo sed -i "s|Documents|documents|" /etc/xdg/user-dirs.defaults
sudo sed -i "s|Music|music|"         /etc/xdg/user-dirs.defaults
sudo sed -i "s|Pictures|pictures|"   /etc/xdg/user-dirs.defaults
sudo sed -i "s|Videos|videos|"       /etc/xdg/user-dirs.defaults
xdg-user-dirs-update
mkdir -vp \
  ~/bin \
  ~/.cache \
  ~/.config/git \
  ~/.local/share \
  ~/.local/state \
  ~/repository/clone \
  ~/repository/git \
  ~/repository/local

# Git
touch ~/.config/git/config
git config --global alias.undo 'reset --hard'
git config --global color.status.changed "red normal bold"
git config --global color.status.untracked "magenta normal bold"
git config --global color.status.added "green normal bold"
git config --global core.autocrlf 'input'
git config --global core.editor 'nano'
git config --global init.defaultBranch 'main'
git config --global user.name "$(id -nu 1000)"
git config --global user.email "$(hostname).net"

# Packages
sudo tee -a /etc/dnf/dnf.conf << EOF
exclude_from_weak=gnome-tour
exclude_from_weak=rhythmbox
EOF
sudo dnf remove  -y gnome-tour rhythmbox
sudo dnf install -y gnome-tweaks # Show seconds in clock.
sudo dnf install -y fira-code-fonts
sudo dnf install -y neofetch
sudo dnf install -y make
sudo dnf install -y zsh
sudo dnf install -y htop
sudo dnf install -y fzf
sudo dnf install -y qrencode
sudo dnf install -y calcurse
sudo dnf install -y syncthing
systemctl --"$(whoami)" enable --now syncthing.service
test -d ~/Sync && rm -rf ~/Sync

# Browser
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install -y brave-browser

# IDE
sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg

# Flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.Eloston.UngoogledChromium
flatpak install -y flathub fr.romainvigier.MetadataCleaner
flatpak install -y flathub md.obsidian.Obsidian

# Arkenfox
git clone --depth 1 https://github.com/arkenfox/user.js.git ~/repository/clone/user.js
firefox &
pid=$!
sleep 5
kill $pid
unset pid
ln -fv ~/repository/clone/user.js/prefsCleaner.sh ~/.mozilla/firefox/*.default-release
ln -fv ~/repository/clone/user.js/updater.sh ~/.mozilla/firefox/*.default-release
ln -fv ~/repository/clone/user.js/user.js ~/.mozilla/firefox/*.default-release
cd ~/.mozilla/firefox/*.default-release || exit
printf '1\n' | ./prefsCleaner.sh
printf 'y\n' | ./updater.sh
printf 'user_pref("privacy.resistFingerprinting.letterboxing", false);\n' > user-overrides.js
printf 'user_pref("extensions.pocket.enabled", false);\n' > user.overrides.js
printf 'user_pref("extensions.pocket.site", "");\n' > user.overrides.js
# GUI task: remove bookmarks
url=https://addons.mozilla.org/en-US/firefox/addon
firefox \
  "$url/add-custom-search-engine/"                            \
  "$url/ublock-origin/"                                       \
  "$url/redirector/"                                          \
  "$url/multi-account-containers/"                            \
  "https://www.jetbrains.com/toolbox-app/download/other.html" \
  &
unset url
mkdir -p ~/.local/.share/JetBrains/Toolbox/scripts

# Containers
podman pull cgr.dev/chainguard/postgres:latest
podman pull cgr.dev/chainguard/nginx:latest
podman pull docker.io/library/alpine:latest
podman pull registry.fedoraproject.org/fedora:latest
# podman images | awk '{print $1}' | grep -v 'none' | xargs -L1 podman pull

# Config shell.
sudo usermod -s /usr/bin/zsh "$(id -nu 1000)"

# Create a snapshot
# sudo btrfs subvolume list /
mkdir -p /mnt/snapshot
sudo btrfs subvolume snapshot '/home/' "/mnt/snapshot/@home_$(date +%Y%m%d_%H%M%S)"
sudo btrfs subvolume snapshot '/'      "/mnt/snapshot/@root_$(date +%Y%m%d_%H%M%S)"

# Remove 2 hour password, i.e. the last two lines of the file.
sudo sed -i '$d' /etc/sudoers.d/README
sudo sed -i '$d' /etc/sudoers.d/README
