

if [ "$1" = "-f" ]
then
  #echo "Forcing keyfile generation.."
  KEYFILE=$2
  NEXT_ARG=$3
  OPT_FORCE=1
else
  KEYFILE=$1
  NEXT_ARG=$2
  OPT_FORCE=0
fi


if [ "x$KEYFILE" = "x" ]
then
  echo "No keyfile specified."
  exit 1
fi


if [ "x$NEXT_ARG" != "x" ]
then
  echo "Too many arguments."
  exit 2
fi

if [ -f "$KEYFILE" ] && [ "$OPT_FORCE" = "0" ]
then
  echo "$KEYFILE exists, aborting."
  exit 3
fi

echo "Generating key....."
dd if=/dev/random of=$KEYFILE bs=1024 count=20 iflag=fullblock
if [ "$?" != "0" ]
then
  echo "$KEYFILE file write error."
  exit 4
fi

if [ "$OPT_FORCE" = "0" ]
then
  echo "$KEYFILE created."
else
  echo "$KEYFILE overwritten."
fi


exit 0

#if [ -z "$ACI_HOST_NAME" ] || [ -z "$ACI_USER_NAME" ]
#then
  #echo "Incorrect syntax."
  #echo ""
  #./help.sh
  #exit 1
#fi


# ====================================================================
# create keyfile
#echo -e "$COL_GREEN *** Create crypt keyfile *** $COL_RESET"
#dd if=/dev/urandom of=$ACI_CRYPT_KEYFILE bs=1024 count=20
#chmod 400 $ACI_CRYPT_KEYFILE


#here are some Zs, now fuck off pls
