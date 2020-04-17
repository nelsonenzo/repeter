if [[ "$1" == 'pulumi' ]] && [[ "$2" == 'destroy' ]]; then
  KILL_SSH_TUNNELS
  cd $REPETERDIR
  for logfile in $(ls $REPETERDIR/logs); do
    rm $REPETERDIR/logs/$logfile 2>/dev/null
  done
  cd $REPETERDIR/src/pulumi
  pulumi destroy --non-interactive
  pulumi stack rm $(CONFIG "pulumi_stack") --non-interactive
  cd $REPETERDIR
  exit 0
fi
