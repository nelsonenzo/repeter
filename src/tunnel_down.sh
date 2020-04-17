if [[ "$1" == 'tunnel' ]] && [[ "$2" == 'down' ]]; then
  KILL_SSH_TUNNELS
  cd $REPETERDIR
  for logfile in $(ls $REPETERDIR/logs); do
    rm $REPETERDIR/logs/$logfile 2>/dev/null
  done
  echo "ssh tunnels off. aws infra still running."
  echo "use './repeter pulumi destroy' to delete all"
fi
