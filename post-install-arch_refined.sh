#!/bin/bash
# Post-install setup script — run this AFTER base Arch install + first boot into TTY
# Run as your normal user (not root) — it'll call sudo where needed.
# Go step by step if you want to sanity-check each block instead of running it all at once.

set -e  # stop on first error so you're not left half-configured

echo "==> Updating system first"
sudo pacman -Syu --noconfirm

echo "==> Installing KDE (curated set, not full plasma-meta)"
sudo pacman -S --noconfirm \
    plasma-desktop \
    kwin \
    systemsettings \
    powerdevil \
    plasma-nm \
    plasma-pa \
    kscreen \
    dolphin \
    konsole \
    kitty \
    ark \
    gwenview \
    spectacle \
    haruna
# powerdevil = battery/sleep/brightness (important on a laptop)
# plasma-nm = wifi tray applet, plasma-pa = volume tray applet
# kscreen = display/resolution GUI, systemsettings = the settings app itself

echo "==> Installing ly login manager"
sudo pacman -S --noconfirm ly
sudo systemctl enable ly.service
# Note: this disables any other display manager if one snuck in — check with:
# systemctl status display-manager

echo "==> Audio stack (pipewire replacing pulseaudio)"
sudo pacman -S --noconfirm \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    wireplumber

echo "==> Fonts (vanilla Arch ships with basically none — avoid broken web/app text)"
sudo pacman -S --noconfirm \
    noto-fonts \
    noto-fonts-emoji \
    ttf-liberation

echo "==> NetworkManager + Bluetooth (skip bluez lines if you don't need BT)"
sudo pacman -S --noconfirm networkmanager bluez bluez-utils
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth.service

echo "==> Flatpak setup"
sudo pacman -S --noconfirm flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "==> zram (RAM-based swap — skips the Btrfs swap-file headaches)"
sudo pacman -S --noconfirm zram-generator
sudo tee /etc/systemd/zram-generator.conf > /dev/null <<'EOF'
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
EOF
# Takes effect after reboot. Adjust zram-size later if you want more/less.

echo "==> ufw firewall"
sudo pacman -S --noconfirm ufw
sudo systemctl enable ufw
sudo ufw enable

echo "==> base-devel + git (required before building an AUR helper)"
sudo pacman -S --noconfirm --needed base-devel git

echo "==> Building yay (AUR helper)"
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ~

echo "==> Do you want to install third-party apps now?"
sudo pacman -S --noconfirm \
	vim \
	telegram-desktop \
	steam \
	vlc \
	libreoffice-still \
	filelight \
	btop \
	htop \
	kcalc \
	kclock \
	okular \
	7zip

yay -S spotify \
	protonvpn-gui \
	veracrypt \
	obsidian \
	brave-bin


echo "==> Done. Reboot to activate zram and other services, or test ly manually first:"
echo "    sudo systemctl start ly.service"
echo ""
echo "Reminder — things NOT in this script you may still want:"
echo "  - Attack Shark X11 mouse config (check for udev rules or use Piper: sudo pacman -S piper)"
echo "  - After first ly login: check /etc/ly/config.ini — set a nicer theme and default_session"
echo "    (so it highlights your KDE Wayland session by default instead of whatever it picks)"
