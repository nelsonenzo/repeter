if [[ "$1" == 'status' ]]; then
  dPulumi=$REPETERDIR/src/pulumi
  pulumi --cwd=$dPulumi stack select $(CONFIG "pulumi_stack")
  pulumi --cwd=$dPulumi stack
  cd $REPETERDIR/logs
  for logfile in $(ls $REPETERDIR/logs); do
    echo "#############"
    echo "Logfile Tail: $logfile"
    echo "#############"
    tail $REPETERDIR/logs/$logfile
  done
  exit 0
fi
