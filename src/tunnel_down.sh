if [[ "$1" == 'tunnel' ]] && [[ "$2" == 'down' ]]; then
  KILL_SSH_TUNNELS
  cd $REPETERDIR
  for logfile in $(ls $REPETERDIR/logs); do
    rm $REPETERDIR/logs/$logfile 2>/dev/null
  done
  echo "local ssh tunnels turned off, aws infrastructure still running."
  echo "use './repeter aws destroy' to delete aws infra and pulumi stack"
fi
