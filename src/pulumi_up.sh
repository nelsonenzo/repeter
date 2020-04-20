
if [[ "$1" == 'pulumi' ]] && [[ "$2" == 'up' ]]; then
  KILL_SSH_TUNNELS
  dPulumi=$REPETERDIR/src/pulumi
  _pulumi_stack=$(CONFIG "pulumi_stack")
  _aws_region=$(CONFIG "aws_region")

  # pulumi --cwd=$dPulumi stack init $_pulumi_stack > /dev/null 2>&1
  pulumi --cwd=$dPulumi stack ls | grep $_pulumi_stack
  if [[ $? -eq 0 ]]; then
    # pulumi --cwd=$dPulumi stack select $_pulumi_stack
    pulumi --cwd=$dPulumi up --stack $_pulumi_stack --non-interactive -y
  else
    echo "stack doesn't appear to be setup."
    echo "try ./repeter init"
  fi

  if [[ $? -eq 0 ]]; then
    hLineBreakEcho "next, bring up the local tunnels"
    echo "./repeter tunnel up" && echo ''
  else
    echo "something went wrong"
  fi
  exit 0
fi
