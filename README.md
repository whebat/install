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

## Functions
https://git.obarun.org/pkg/obextra/obarun-zsh/-/blob/master/version/0.5-2/zshrc
https://github.com/bminor/musl/blob/master/configure

## POSIX
https://www.shellcheck.net/
https://drewdevault.com/2018/02/05/Introduction-to-POSIX-shell.html
https://www.etalabs.net/sh_tricks.html
https://github.com/dylanaraps/pure-sh-bible
https://shellhaters.org/

## Specifications
https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.71/autoconf.html#Portable-Shell
https://zsh.sourceforge.io/Intro/intro_toc.html

