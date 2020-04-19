
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
  hLineBreakEcho "next, bring up the local tunnels"
  echo "./repeter tunnel up" && echo ''

  exit 0
fi
