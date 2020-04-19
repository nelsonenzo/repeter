#!/bin/bash

if [[ "$1" == 'init' ]]; then
  cd $REPETERDIR/src/pulumi
  npm install

  hLineBreakEcho "pulumi npm install complete"
  hLineBreakEcho "4 questions for configuration:"

  read -p "Pulumi stack name
eg > repeter-nelson
> " pulumi_stack

  read -p "
AWS Region for EC2 Instance
eg > us-west-2 or us-east-1
>" region

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

  node $REPETERDIR/src/init_config.js $dns_host_zone "$tunnel_maps" "$public_key" $pulumi_stack $region
  hLineBreakEcho "./config.json file created"

  ## Initialize pulumi stack
  pulumi stack init --stack=$pulumi_stack --non-interactive
  pulumi stack select $pulumi_stack
  pulumi config set aws:region $region

  hLineBreakEcho "Pulumi stack initialized locally "

  cd $REPETERDIR
  hLineBreakEcho "next, bring up the infrastructure."
  echo "./repeter pulumi up"

exit 0;

fi
