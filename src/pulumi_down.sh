if [[ "$1" == 'pulumi' ]] && [[ "$2" == 'down' ]]; then
  KILL_SSH_TUNNELS
  dPulumi=$REPETERDIR/src/pulumi
  # Destroy an existing stack and its resources
  # https://www.pulumi.com/docs/reference/cli/pulumi_destroy/
  pulumi --cwd $dPulumi destroy --stack $(CONFIG "pulumi_stack") --non-interactive
  cd $REPETERDIR
  exit 0
fi
