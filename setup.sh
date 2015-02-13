DIR=`pwd`

if [ ! -d $DIR/cirrus ] ; then
    echo "cirrus subdirectory not found"
    exit -1
fi
if [ ! -d $DIR/cloudmanager ] ; then
    echo "cloudmanager subdirectory not found"
    exit -1
fi
if [ ! -d $DIR/cloudconf ] ; then
    echo "cloudconf subdirectory not found"
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

export SETUP_SH_RUNNING=1
. config.sh
unset SETUP_SH_RUNNING
