# aserdev-repo  
my pacman repo cuz AUR is cringe 💀  

---

## 🚀 Install  

### step 1: use [Chaotic AUR](https://aur.chaotic.cx/docs)  
They got everything, tbh.  

```sh
# add signing key
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
# install the keyring,mirrorlist
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# add chaotic aur repo
echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist'   | sudo tee -a /etc/pacman.conf

# update
sudo pacman -Syu
```

### step 2: Install my repo directly (the real deal™)  
```sh
bash <(curl -fsSL https://raw.githubusercontent.com/aserdevyt/aserdev-repo/refs/heads/main/install.sh)
```

---

## 🤝 Contributing  

- Send me **PKGBUILDs**  
- I mainly want **small projects** (no giant deps pls 🙏)  
- Requirements:  
  - [GitHub account](https://github.com/)  
  - [Arch install](https://archlinux.org/)  
  - Knowledge of [PKGBUILDs](https://wiki.archlinux.org/title/PKGBUILD)  

I’ll host it here, signed & ready.  

---

## 📦 Why?  
Because the AUR is cool but sometimes it’s a mess. This repo = less cringe, more chill.  
