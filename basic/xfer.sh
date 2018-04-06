HOST=127.0.0.1
PORT=2222
HOST_ROOT="root@$HOST"
ACI_CRYPT_KEYFILE=crypthome.key
SSH_KEYFILE=~/.ssh/aci_rsa

#rm -f $SSH_KEYFILE
#rm -f $SSH_KEYFILE.pub

ssh-keygen -f $SSH_KEYFILE -N "" -C "Arch custom installer key"
ssh-copy-id -i $SSH_KEYFILE.pub -p 2222 $HOST_ROOT


#./_gen-keyfile.sh $ACI_CRYPT_KEYFILE
scp -P "$PORT" ./* "$HOST_ROOT:/root"
ssh -tt -p "$PORT" "$HOST_ROOT" "./install.sh $ACI_CRYPT_KEYFILE"
