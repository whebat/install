# Install

Installation steps and scripts.

## Post-Installation Script

```bash
wget -qO- https://raw.githubusercontent.com/whebat/install/main/post/fedora.sh | sh
```

## GUI Configuration
```bash
url=https://addons.mozilla.org/en-US/firefox/addon
firefox \
"$url/add-custom-search-engine/"                            \
"$url/ublock-origin/"                                       \
"$url/redirector/"                                          \
"$url/multi-account-containers/"                            \
"https://www.jetbrains.com/toolbox-app/download/other.html" \
&
unset url
```

# Shell References
https://zsh.sourceforge.io/Intro/intro_toc.html

https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.71/autoconf.html#Portable-Shell
https://www.etalabs.net/sh_tricks.html
https://drewdevault.com/2018/02/05/Introduction-to-POSIX-shell.html
https://www.shellcheck.net/
https://github.com/dylanaraps/pure-sh-bible
