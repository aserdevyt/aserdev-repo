# aserdev-repo
my pacman repo cuss aur is cringe

## install

### please use [choatic aur](aur.chaotic.cx/docs)

```
# install the keys

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

# install they keyring and the mirrorlist

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

# put this in /etc/pacman.conf

echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf

# update pacman

sudo pacman -Syu
```

### install the real repo

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/aserdevyt/aserdev-repo/refs/heads/main/install.sh)
```

# contributing 

contribute by giving me pkgbuilds 

i want pkgbuilds for small projects and ill host them in this repo all you need is a [github account](https://github.com/) and [an arch install](https://archlinux.org/) and give me a [pkgbuild](https://wiki.archlinux.org/title/PKGBUILD) for your pkg
