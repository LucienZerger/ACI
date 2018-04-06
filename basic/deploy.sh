#!/bin/bash

      PORT=22
      HOST=$1

echo PORT="$PORT", HOST="$HOST"
HOST_ROOT="root@$HOST"
PUBKEY=$(cat ~/.ssh/id_aci.pub)

# copy your public key, so can ssh without a password later on
ssh -tt -p "$PORT" "$HOST_ROOT" "mkdir -m 700 ~/.ssh; echo $PUBKEY > ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys"

# copy install scripts from ./root folder
scp -P "$PORT" aci* "$HOST_ROOT:/root"

# run the install script remotely
#ssh -tt -p "$PORT" "$HOST_ROOT" "./install.sh"
