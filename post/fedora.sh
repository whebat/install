#!/bin/sh

# wget -qO- https://raw.githubusercontent.com/whebat/install/main/post/fedora.sh | sh

echo () { printf %s\\n "$*" ; }
fail () { echo "$*" ; exit 1 ; }
username="$(id -nu 1000)"

if [ "$(id -u)" -eq 0 ]; then
printf "%s\n" "Please run as an unprivileged user."
fail "$@"
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

# Scaffold
# Directories should be empty by default.
rmdir -v    \
~/Desktop   \
~/Downloads \
~/Templates \
~/Public    \
~/Documents \
~/Music     \
~/Pictures  \
~/Videos
rm -fv          \
~/.bash_profile \
~/.bash_logout  \
~/.bashrc       \
~/.config/user-dirs.dirs
test -f ~/.bash_history && rm -fv ~/.bash_history
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
~/.config/zsh \
~/.local/share \
~/.local/state \
~/repository/clone \
~/repository/git \
~/repository/local

# Git
touch ~/.config/git/config
git config --global alias.undo 'reset --hard'
git config --global alias.unadd 'restore --staged'
git config --global color.status.changed "red normal bold"
git config --global color.status.untracked "magenta normal bold"
git config --global color.status.added "green normal bold"
git config --global core.autocrlf 'input'
git config --global core.editor 'nano'
git config --global init.defaultBranch 'main'
git config --global user.name "$username"
git config --global user.email "$username@$(hostname).net"

# Packages: Add Repositories
# Browser
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
# IDE
sudo tee -a /etc/yum.repos.d/vscodium.repo << 'EOF'
[gitlab.com_paulcarroty_vscodium_repo]
name=gitlab.com_paulcarroty_vscodium_repo
baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
metadata_expire=1h
EOF

# Packages: Removal
sudo tee -a /etc/dnf/dnf.conf << EOF
exclude_from_weak=gnome-tour
exclude_from_weak=rhythmbox
EOF
sudo dnf remove  -y gnome-tour rhythmbox

# Packages: Install
sudo dnf install -y gnome-tweaks # Show seconds in clock.
sudo dnf install -y \
fira-code-fonts     \
neofetch            \
zsh                 \
htop                \
fzf                 \
qrencode            \
calcurse            \
syncthing codium brave-browser
systemctl --"$username" enable --now syncthing.service # 8384

# Config shell.
sudo usermod -s /usr/bin/zsh "$username"
unset username
cd ~/.config/zsh || fail "$@"
wget https://raw.githubusercontent.com/whebat/install/main/.zshrc
wget https://raw.githubusercontent.com/whebat/install/main/.zprofile
git clone --depth=1 https://github.com/romkatv/gitstatus.git ~/repository/clone/gitstatus
sudo printf '\n%s\n' 'source ~/.config/zsh/.zprofile' >> /etc/zshenv

# Flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --enable flathub
flatpak install -y flathub com.github.Eloston.UngoogledChromium
flatpak install -y flathub fr.romainvigier.MetadataCleaner
flatpak install -y flathub md.obsidian.Obsidian
flatpak install -y fedora # app/org.keepassxc.KeePassXC/x86_64/stable

# Arkenfox
git clone --depth=1 https://github.com/arkenfox/user.js.git ~/repository/clone/user.js
firefox &
pid=$!
sleep 5
kill $pid
unset pid
ln -fv ~/repository/clone/user.js/prefsCleaner.sh ~/.mozilla/firefox/*.default-release
ln -fv ~/repository/clone/user.js/updater.sh ~/.mozilla/firefox/*.default-release
ln -fv ~/repository/clone/user.js/user.js ~/.mozilla/firefox/*.default-release
cd ~/.mozilla/firefox/*.default-release || fail "$@"
printf '1\n' | ./prefsCleaner.sh
printf 'y\n' | ./updater.sh
printf 'user_pref("privacy.resistFingerprinting.letterboxing", false);\n' > user-overrides.js
printf 'user_pref("extensions.pocket.enabled", false);\n' >> user-overrides.js
printf 'user_pref("extensions.pocket.site", "");\n' >> user-overrides.js
mkdir -p ~/.local/.share/JetBrains/Toolbox/scripts

# Containers
podman pull cgr.dev/chainguard/postgres:latest
podman pull cgr.dev/chainguard/nginx:latest
podman pull docker.io/library/alpine:latest
podman pull registry.fedoraproject.org/fedora:latest
# podman images | awk '{print $1}' | grep -v 'none' | xargs -L1 podman pull

# Create a snapshot
# sudo btrfs subvolume list /
# mkdir -p /mnt/snapshot
# sudo btrfs subvolume snapshot '/home/' "/mnt/snapshot/@home_$(date +%Y%m%d_%H%M%S)"
# sudo btrfs subvolume snapshot '/'      "/mnt/snapshot/@root_$(date +%Y%m%d_%H%M%S)"

# Cleanup
test -d ~/Sync && rm -rf ~/Sync

# Remove 2 hour password, i.e. the last two lines of the file.
sudo sed -i '$d' /etc/sudoers.d/README
sudo sed -i '$d' /etc/sudoers.d/README
