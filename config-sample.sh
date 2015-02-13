if [ $SETUP_SH_RUNNING ] ; then
  export CIRRUS_HOME=$DIR/cirrus
  export CIRRUS_KEYS=$DIR/keys
  export CIRRUS_PEM=path_to_pem_file
  export CIRRUS_AWS_KEYS=path_to_keys_dir
  export NODE_PATH=$CIRRUS_HOME/cirrus/node_modules
  
  export CLOUDMANAGER_PROVISION_DIR=$DIR/cloudconf
  export CLOUDMANAGER_USERS=path_to_users_json_file
else
  echo "You are running the wrong script.  Run setup.sh instead!"
fi
