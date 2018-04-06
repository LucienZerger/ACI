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

# ====================================================================
# set keyboard layout
echo -e "$COL_GREEN *** Set keyboard layout *** $COL_RESET"
loadkeys us

# ====================================================================
# update the system clock
echo -e "$COL_GREEN *** Update the system clock *** $COL_RESET"
timedatectl set-ntp true

# ====================================================================
# load dm_crypt kernal module
#echo -e "$COL_GREEN *** Load dependency modules *** $COL_RESET"
#modprobe dm_crypt

# ====================================================================
# create keyfile
#echo -e "$COL_GREEN *** Create crypt keyfile *** $COL_RESET"
#2dd if=/dev/urandom of=$ACI_CRYPT_KEYFILE bs=1024 count=20
#chmod 400 $ACI_CRYPT_KEYFILE

# ====================================================================
# create partitions
echo -e "$COL_GREEN *** Create partitions *** $COL_RESET"
parted -s /dev/sda mklabel gpt
parted -s -a optimal /dev/sda mkpart primary 0% 257MiB name 1 boot
#parted -s -a optimal /dev/sda mkpart primary 257MiB 100% name 2 root
parted -s -a optimal /dev/sda mkpart primary 257MiB 100% name 2 root
#parted -s -a optimal /dev/sda mkpart primary 10% 100% name 3 home

# ====================================================================
# set encryption
# **** IDEA: passphrase unlocks root, root and BACKUP location contains keyfile for home
if [ "x$ACI_CRYPTPART" = "xtrue" ]
then
  cryptsetup -s 512 -i 5000 luksFormat /dev/sda2
  cryptsetup luksOpen /dev/sda2 root
fi
#echo -e "$COL_GREEN *** Open encrypted partitions *** $COL_RESET"
#cryptsetup -s 512 -i 5000 luksFormat /dev/sda2
#cryptsetup luksAddKey /dev/sda2 $ACI_CRYPT_KEYFILE
#cryptsetup -s 512 -i 5000 --key-file $ACI_CRYPT_KEYFILE luksFormat /dev/sda2
#cryptsetup -s 512 -i 5000 --key-file $ACI_CRYPT_KEYFILE luksFormat /dev/sda3
#cryptsetup --key-file $ACI_CRYPT_KEYFILE luksOpen /dev/sda2 root
#cryptsetup luksOpen /dev/sda2 root
#cryptsetup --key-file $ACI_CRYPT_KEYFILE luksOpen /dev/sda3 home

#cryptsetup -s 512 -i 5000 luksFormat /dev/sda2
#cryptsetup -s 512 -i 5000 luksFormat /dev/sda3
#cryptsetup luksOpen /dev/sda3 home

# ====================================================================
# format partitions
echo -e "$COL_GREEN *** Format partitions *** $COL_RESET"
mkfs.btrfs --quiet -f --label boot /dev/sda1
#mkfs.btrfs -L boot /dev/mapper/boot
if [ "x$ACI_CRYPTPART" = "xtrue" ]
then
  mkfs.f2fs -l root /dev/mapper/root
else
  mkfs.f2fs -l root /dev/sda2
fi
#mkfs.f2fs -l home /dev/mapper/home

# ====================================================================
# mount partitions
echo -e "$COL_GREEN *** Mount partitions *** $COL_RESET"
if [ "x$ACI_CRYPTPART" = "xtrue" ]
then
  mount /dev/mapper/root /mnt
else
  mount /dev/sda2 /mnt
fi
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot

# set mirrors
echo -e "$COL_GREEN *** Set package mirrors *** $COL_RESET"
curl -o /etc/pacman.d/mirrorlist.all https://www.archlinux.org/mirrorlist/all/
awk '/^## Australia$/ {f=1} f==0 {next} /^$/ {exit} {print substr($0, 2)}' /etc/pacman.d/mirrorlist.all > /etc/pacman.d/mirrorlist.australia
mkdir -p /mnt/etc/pacman.d
rankmirrors -n 4 /etc/pacman.d/mirrorlist.australia > /mnt/etc/pacman.d/mirrorlist
cp /mnt/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist
#rankmirrors -n 4 ./_res-mirrors-australia > /mnt/etc/pacman.d/mirrorlist

# install base packages
echo -e "$COL_GREEN *** Install base and development packages *** $COL_RESET"
pacstrap /mnt base base-devel

# generate /etc/fstab using UUIDs
echo -e "$COL_GREEN *** Generate /etc/fstab *** $COL_RESET"
genfstab -p -U /mnt > /mnt/etc/fstab

# copy crypt keyfile to mounted root
#cp $ACI_CRYPT_KEYFILE /mnt/$ACI_CRYPT_KEYFILE
#chmod 400 /mnt/$ACI_CRYPT_KEYFILE
