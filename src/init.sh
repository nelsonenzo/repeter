#!/bin/bash

if [[ "$1" == 'init' ]]; then
  rm -rf $REPETERDIR

  mkdir -p "$REPETERDIR/src/pulumi"
  mkdir -p "$REPETERDIR/logs"
  mkdir -p "$REPETERDIR/src/cache"
  cp src/init_config.js $REPETERDIR/src/init_config.js

  cp src/pulumi/index.ts $REPETERDIR/src/cache/pulumi_index.ts
  cp src/pulumi/user_data.sh.ejs $REPETERDIR/src/cache/pulumi_user_data.sh.ejs
  read -p "Pulumi stack name
eg > repeter-nelson
> " pulumi_stack

  read -p "
AWS Region for EC2 Instance
eg > us-west-2 or us-east-1
> " region

  ## input prompt domain/root_tld/host_zone_name
  read -p "
Route53 Managed DNS Host Zone Name
eg > staging.yourcompany.com
> " dns_host_zone

  read -p "
Space:Delimited Sub.domain:LocalPort
eg > www.jane:3001 api.jane:4001 auth.jane:5001
> " tunnel_maps
  ## input_prompt public_ssh_key
  read -p "
Public SSH Key
eg > ssh-rsa ABz...3nt== jane@gmail.com
> " public_key
# dns_host_zone="dev.nelsonenzo.com"
# tunnel_maps="www:7003 api:7001 auth:7002"
# public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCTUaboK49EnWjAHyeRFzsfumBfdvcVRrE+MNsHveJgNteMvueVbqiq2y3McIRZdR5zL8Bg4Gfp/Pbp8r6t/gYW1g1Lu0TnzSl47fLjnYUs3yAcVP5xD/ePE9fMDIr1BgP+iarEWYQULp/4WLhIcJmMszUFP+RN9XI4GjH1AAMRGWphnWQ9+rHOfAst1Yp06cECPbZGS0M+69t7gvbwDbBYRpGnEuVbSXVA3Dy7Wb9P3Lzp0aUiUCo5CD/xDodY0+XBX7+82aYbUY0T8vCSbxN61OXjiQXTV07R8rcs5hNxhVJCcgUijp/PQYNCAZjkP3Fde5UlQZGQMat03FCw6Uhllt6DczJ+n7XSh4lcI7ukFxrFqvlzgT6SXctWqwceZo7xUME70HOdXdZOo9yt6LQNk/ddAiWowqXIwEAqOP3+I+eOGU7fYjOc4l99uZpZbHr/vj1N0mt8s8bbTQqfUTSp3CAGqCQR1P/nPCwVYooiLB8iGQifz2ix92Sz2Obvd20+jDyHr3RyvOksBFG245BQIMJ70Gjl9TS1Uo2YoQjbU6mSqaZaxMA6Uq3WAYwg3lskrtHMdDqQTtgXMFYyA7QWyn27x5/Wu4IJkRmgfzs72ebnwrrPeBVen7/wXiFFJRGXDHelEblcUarwgDwQdddLgb+5VbKHIwGTz1chDh3ntw== nelsonh@gmail.com
# "
# pulumi_stack="test-stack"
# region="us-west-2"

  # create ~/.repeter/config.json
  node "$REPETERDIR/src/init_config.js" $dns_host_zone "$tunnel_maps" "$public_key" $pulumi_stack $region
  # TODO: check that config was created ok, exit if not.
  hLineBreakEcho "$HOME/.repeter/config.json"
  cat "$REPETERDIR/config.json"

  # create ~/.repeter/src/pulumi/
  # cd $REPETERDIR/src/pulumi
  dPulumi=$REPETERDIR/src/pulumi
  hLineBreakEcho "Try to create Pulumi project and stack"

  pulumi --cwd=$dPulumi new aws-typescript  \
                            --name=$pulumi_stack \
                            --description="A Repeter Repo" \
                            --stack=$pulumi_stack \
                            -y

  if [[ $? -eq 0 ]]; then
    echo "that worked out"
  else
    echo "something went wrong"
    exit 1
  fi

  hLineBreakEcho "npm install Pulumi dependencies"
  npm install > $REPETERDIR/logs/init_npm_install.log
  cd $REPETERDIR/src/pulumi
  npm install ejs >> $REPETERDIR/logs/init_npm_install.log
  # pulumi stack init --stack=$pulumi_stack --non-interactive
  pulumi --cwd=$dPulumi stack select $pulumi_stack
  pulumi --cwd=$dPulumi config set aws:region $region


  cp $REPETERDIR/src/cache/pulumi_index.ts $REPETERDIR/src/pulumi/index.ts
  cp $REPETERDIR/src/cache/pulumi_user_data.sh.ejs $REPETERDIR/src/pulumi/user_data.sh.ejs

  hLineBreakEcho "Pulumi stack initialized at $REPETERDIR/src/pulumi"

  hLineBreakEcho "next, bring up the infrastructure."
  echo "./repeter pulumi up"

exit 0;

fi
