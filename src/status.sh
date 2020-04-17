if [[ "$1" == 'status' ]]; then
  cd $REPETERDIR/src/pulumi
  pulumi stack select $(CONFIG "pulumi_stack")
  pulumi stack
  cd $REPETERDIR/logs
  for logfile in $(ls); do
    tail $logfile
  done
  cd $REPETERDIR
  exit 0
fi
