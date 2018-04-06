#ACI_CRYPT_KEYFILE=$1

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"


#####################################
# install additional packages
echo -e "$COL_GREEN *** Install additional packages *** $COL_RESET"
pacman -S --noconfirm sudo openssh openssl iw wpa_supplicant zsh zsh-completions \
  wpa_actiond ifplugd pulseaudio pulseaudio-equalizer arandr feh \
  rofi pavucontrol alsa-utils acpi sysstat scrot  yaourt

# install software dev tools
pacman -S --noconfirm git

# install laptop driver packages
pacman -S --noconfirm xf86-input-synaptics xf86-video-amdgpu intel-ucode

# install X
pacman -S --noconfirm xorg-server xorg-xinit
if [ "x$ACI_DE" = "xkdeplasma" ]
then
  pacman -S --noconfirm plasma kde-applications
fi
if [ "x$ACI_DE" = "xi3" ]
then
  pacman -S --noconfirm i3
fi

# install disk utils and boot loader
pacman -S --noconfirm syslinux gptfdisk f2fs-tools btrfs-progs 

# install web applications
pacman -S --noconfirm vlc chromium keepassx2 virtualbox

# install security applications
pacman -S --noconfirm sshguard nftables nmap openvpn dnscrypt-proxy

# update /etc/pacman.conf
#cat acires-aur >> /etc/pacman.conf
echo "" >> /etc/pacman.conf
echo "[archlinuxfr]" >> /etc/pacman.conf
echo "SigLevel = Never" >> /etc/pacman.conf
echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf

#####################################
# set locale
echo -e "$COL_GREEN *** Set locale, language, timezone *** $COL_RESET"
echo "en_AU.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_AU.UTF-8" > /etc/locale.conf
export LANG=en_AU.UTF-8
ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
hwclock --systohc --utc
echo "KEYMAP=us" > /etc/vconsole.conf

#####################################
# configure boot loader
echo -e "$COL_GREEN *** Configure boot loader - /boot/syslinux/syslinux.cfg *** $COL_RESET"
syslinux-install_update -iam
cp /boot/syslinux/syslinux.cfg /boot/syslinux/syslinux.cfg.b
echo "DEFAULT arch" > /boot/syslinux/syslinux.cfg
echo "LABEL arch" >> /boot/syslinux/syslinux.cfg
echo "  LINUX ../vmlinuz-linux" >> /boot/syslinux/syslinux.cfg
echo "  APPEND root=/dev/sda2 rw" >> /boot/syslinux/syslinux.cfg
echo "  INITRD ../intel-ucode.img,../initramfs-linux.img" >> /boot/syslinux/syslinux.cfg
#echo "DEFAULT arch" > /boot/syslinux/syslinux.cfg.tmp1
#awk '/^LABEL arch$/ {f=1} f==0 {next} /^$/ {exit} {print substr($0, 1)}' /boot/syslinux/syslinux.cfg.b >> /boot/syslinux/syslinux.cfg.tmp1
#awk '"APPEND"{gsub("root=/dev/sda3", "cryptdevice=/dev/sda2:root root=/dev/mapper/root")};{print}' /boot/syslinux/syslinux.cfg.tmp1 > /boot/syslinux/syslinux.cfg.tmp2
#awk '"INITRD"{gsub("../initramfs-linux.img", "../intel-ucode.img,../initramfs-linux.img")};{print}' /boot/syslinux/syslinux.cfg.tmp2 > /boot/syslinux/syslinux.cfg
#rm -f /boot/syslinux/syslinux.cfg.tmp*


#####################################
# config enc
echo -e "$COL_GREEN *** Add encryption hook - /etc/mkinitcpio.conf *** $COL_RESET"
#cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.b
#echo "MODULES=()" > /etc/mkinitcpio.conf
#echo "BINARIES=()" >> /etc/mkinitcpio.conf
#echo "FILES=(/$ACI_CRYPT_KEYFILE)" >> /etc/mkinitcpio.conf
#echo "HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)" >> /etc/mkinitcpio.conf
#awk '"HOOKS="{gsub("block filesystems", "block encrypt filesystems")};{print}' /etc/mkinitcpio.conf.b > /etc/mkinitcpio.conf
mkinitcpio -p linux

#####################################
# encrypt DNS traffic (no need to use 208.67.220.220,208.67.222.222) and put 127.0.0.1 in resolv.conf or NetworkManager
echo "ResolverName cisco" > /etc/dnscrypt-proxy.conf
#echo "ResolverName cisco-familyshield" > /etc/dnscrypt-proxy.conf

#####################################
# disable ssh root AND password login, requiring keys only
echo -e "$COL_GREEN *** Security: remove ssh access to root *** $COL_RESET"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.b
awk '"HOOKS="{gsub("#PermitRootLogin prohibit-password", "PermitRootLogin no")};{print}' /etc/ssh/sshd_config.b > /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

#####################################
# set host name
echo -e "$COL_GREEN *** Set machine host name *** $COL_RESET"
echo "$ACI_HOSTNAME" > /etc/hostname
echo "127.0.0.1   localhost.localdomain   localhost $ACI_HOSTNAME" > /etc/hosts
echo "::1         localhost.localdomain   localhost $ACI_HOSTNAME" >> /etc/hosts

#####################################
# add first user as sudo user
echo -e "$COL_GREEN *** Create first user *** $COL_RESET"
#ACI_USERNAME=user
echo "Creating user $ACI_USERNAME:"
useradd -m -g users -s /bin/zsh $ACI_USERNAME
passwd $ACI_USERNAME
#passwd -e $ACI_USERNAME
echo "$ACI_USERNAME ALL=(ALL) ALL" >> /etc/sudoers
echo 'alias ls="ls --color=always"' >> $ACI_USERHOME/.zshrc
echo 'alias ll="ls -la --color=always"' >> $ACI_USERHOME/.zshrc
echo 'autoload -Uz promptinit' >> $ACI_USERHOME/.zshrc
echo 'promptinit' >> $ACI_USERHOME/.zshrc
echo 'prompt oliver' >> $ACI_USERHOME/.zshrc
chown $ACI_USERNAME:users $ACI_USERHOME/.zshrc

#####################################
# init X
cp /etc/X11/xinit/xinitrc > $ACI_USERHOME/.xinitrc
if [ "x$ACI_DE" = "xkdeplasma" ]
then
  sed "s/exec.*/exec startkde/g" /etc/X11/xinit/xinitrc > $ACI_USERHOME/.xinitrc
fi
if [ "x$ACI_DE" = "xi3" ]
then
  sed "s/exec.*/exec i3/g" /etc/X11/xinit/xinitrc > $ACI_USERHOME/.xinitrc
fi
chown $ACI_USERNAME:users $ACI_USERHOME/.xinitrc
echo 'exec /usr/bin/Xorg -nolisten tcp "$@" vt$XDG_VTNR' > $ACI_USERHOME/.xserverrc
chown $ACI_USERNAME:users $ACI_USERHOME/.xserverrc

#####################################
# set root password and disable terminal access
echo -e "$COL_GREEN *** Disable root terminal access *** $COL_RESET"
#echo -e "$COL_GREEN *** Set root password *** $COL_RESET"
#echo "Set ROOT password:"
#passwd
passwd -l root

#####################################
# enable services
echo -e "$COL_GREEN *** Enabling essential services *** $COL_RESET"
systemctl enable sshd
systemctl enable NetworkManager
systemctl enable nftables
systemctl enable dnscrypt-proxy

