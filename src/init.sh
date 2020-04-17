#!/bin/bash

if [[ "$1" == 'init' ]]; then
  cd $REPETERDIR/src/pulumi
  npm install
  echo "npm packages for pulumi installed" && echo ''
  read -p "Pelumi stack name.`echo $'\n '`e.g. repeter-nelson `echo $'\n '`" pulumi_stack
  read -p "AWS Region for EC2 Instance `echo $'\n '`" region
  ## Initialize pulumi stack repeter
  pulumi stack --stack=$pulumi_stack
  pulumi stack select $pulumi_stack
  pulumi config set aws:region $region
  cd $REPETERDIR

  ## input prompt domain/root_tld/host_zone_name
  read -p "DNS Host Zone Name i.e. staging.yourcompany.com `echo $'\n> '`" dns_host_zone
  ## input prompt sub.namespace:local_port sub2.namespace:local_port sub3.namespace:local_port
  read -p "Subdomain:LocalPort i.e. www.nelson:3000 api.nelson:8000 `echo $'\n> '`" tunnel_maps
  ## input_prompt public_ssh_key
  read -p "Public SSH Key `echo $'\n> '`" public_key

  node $REPETERDIR/src/init_config.js $dns_host_zone "$tunnel_maps" "$public_key" $pulumi_stack $region

  echo '' && echo ''
  echo "next, bring up the aws infra and the local tunnels"
  echo "./repeter pulumi up"
  echo "./repeter tunnel up"

exit 0;

fi
