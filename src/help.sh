if [[ "$1" == '--help' || "$1" == "help" ]]; then
  echo "

repeter init           ## installs pulumi node_modules & creates the config file.
repeter pulumi up      ## Bring the AWS Infrastrure up using Pulumi.
repeter tunnel up      ## Starts the all the ssh tunnels locally.
repeter tunnel down    ## Stops the ssh tunnels locally, but leaves AWS infra up.
repeter pulumi down    ## Destroys AWS infra, leaves Pulumi stack.
repeter destroy        ## Destroys AWS infra, Pulumi stack, and ~/.repeter/ directory.
repeter https          ## Enables https via letsencrypt. Run after 'repeter pulumi up'.

repeter help           ## outputs this text.
repeter status         ## Outputs pulumi stack status and tails tunnel logs.

"
  exit 0
fi
