DIR=`pwd`

if [ ! -d $DIR/cirrus ] ; then
    echo "cirrus subdirectory not found"
    exit -1
fi
if [ ! -d $DIR/cloudmanager ] ; then
    echo "cloudmanager subdirectory not found"
    exit -1
fi
if [ ! -d $DIR/cloud ] ; then
    echo "cloud subdirectory not found"
    exit -1
fi


function add_bindir_to_path() {
  if ! ( echo $PATH | grep "$1" > /dev/null ) ; then
    export PATH=$1:$PATH
    echo "$1 added to PATH"
  else
    echo "$1 is already on PATH"
  fi
}

#
# add cirrus dir to $PATH
#
add_bindir_to_path $DIR/cirrus

#
# add cloudmanager dir to $PATH
#
add_bindir_to_path $DIR/cloudmanager

#
# set required environment variables
#

export CIRRUS_HOME=$DIR/cirrus
export CIRRUS_KEYS=$DIR/keys
export CIRRUS_AWS_KEYS=$CIRRUS_KEYS/aws.json
export NODE_PATH=$CIRRUS_HOME/cirrus/node_modules

export CLOUDMANAGER_PROVISION_DIR=$DIR/cloudconf
export CLOUDMANAGER_USERS=$DIR/cloudusers/users.json
