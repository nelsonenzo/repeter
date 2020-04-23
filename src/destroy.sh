if [[ "$1" == 'destroy' ]]; then
  KILL_SSH_TUNNELS
  dPulumi=$REPETERDIR/src/pulumi
  pulumi --cwd $dPulumi destroy --stack $(CONFIG "pulumi_stack") --non-interactive --yes
  # This command removes a stack and its configuration state.
  # Please refer to the destroy command for removing a resources, as this is a distinct operation.
  # After this command completes, the stack will no longer be available for updates.
  # https://www.pulumi.com/docs/reference/cli/pulumi_stack_rm/
  pulumi --cwd $dPulumi stack rm $(CONFIG "pulumi_stack")  --non-interactive --yes
  
  if [[ $? -eq 0 ]]; then
    rm -rf $REPETERDIR
  else
    echo "something went wrong in removing or destroying pulumi stack in ~/.repeter/pulumi"
    exit 1;
  fi
  
  if [[ $? -eq 0 ]]; then
    echo "~/.repeter directory, pulumi stack and aws infra poof. gone."
    echo "you will need to run init again"
    echo "./repeter init"
  else
    echo "something went wrong"
    exit 1
  fi

  exit 0
fi
