if [[ "$1" == '--help' || "$1" == "help" ]]; then
  echo "

repeter init           ## input configuration, then auto runs up and tunnel.
repeter pulumi up      ## Bring the AWS Infrastrure up using Pulumi.
repeter pulumi down    ## Destroys AWS infra, leaves Pulumi stack.
repeter pulumi destroy ## Destroys AWS infra and Pulumi stack.
repeter tunnel up      ## Starts the all the ssh tunnels locally.
repeter tunnel down    ## Stops the ssh tunnels locally, but leaves AWS infra up.
repeter help           ## outputs this text.
repeter status         ## Outputs pulumi stack status and tails tunnel logs.

"
  exit 0
fi
