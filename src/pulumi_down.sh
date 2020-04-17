if [[ "$1" == 'aws' ]] && [[ "$2" == 'down' ]]; then
  KILL_SSH_TUNNELS
  cd $REPETERDIR/src/pulumi
  pulumi destroy --non-interactive
  cd $REPETERDIR
  exit 0
fi
