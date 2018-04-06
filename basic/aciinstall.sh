if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ "x$ACI_HOSTNAME" = "x" ]
then
  echo "No hostname specified."
  exit 1
fi

if [ "x$ACI_USERNAME" = "x" ]
then
  echo "No username specified."
  exit 1
fi

#ACI_FOLDER=/aci

./aciinstall-config.sh
./aciinstall-pre.sh

# change root
cp ./aciinstall-main.sh /mnt
arch-chroot /mnt ./aciinstall-main.sh
rm /mnt/aciinstall-main.sh

./aciinstall-post.sh
