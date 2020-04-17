
if [[ "$1" == 'pulumi' ]] && [[ "$2" == 'up' ]]; then
  KILL_SSH_TUNNELS
  cd $REPETERDIR/src/pulumi
  _pulumi_stack=$(CONFIG "pulumi_stack")
  _aws_region=$(CONFIG "aws_region")
  pulumi stack init $_pulumi_stack > /dev/null 2>&1
  pulumi stack select $_pulumi_stack
  pulumi config set aws:region $_aws_region
  pulumi up --non-interactive
  cd $REPETERDIR
  echo "bring up your local tunnels with"
  echo "./repeter tunnel up"
  exit 0
fi
