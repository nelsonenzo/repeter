#!/bin/bash
fPublicKeyFromFile(){
  _key_file=$1
  #gsub ~ with $HOME
  _key_file=${_key_file/\~/$HOME/}
  #check for file
  if test -f "$_key_file"; then
    echo $(cat $_key_file);
    exit 0;
  else
    echo "$_key_file does not exist"
    exit 1;
  fi

}
if [[ "$1" == 'init' ]]; then

  mkdir -p "$REPETERDIR/src/pulumi"
  mkdir -p "$REPETERDIR/logs"
  mkdir -p "$REPETERDIR/src/cache"
  cp src/init_config.js $REPETERDIR/src/init_config.js

  cp src/pulumi/index.ts $REPETERDIR/src/cache/pulumi_index.ts
  cp src/pulumi/user_data.sh.ejs $REPETERDIR/src/cache/pulumi_user_data.sh.ejs
  ## input_prompt public_ssh_key
  read -p "
PUBLIC ssh key file location
eg > ~.ssh/nelson-ssh.pub
> " public_key_file

  public_key=$(fPublicKeyFromFile $public_key_file)
  if [[ $? -eq 1 ]]; then
    echo "Public Key File $public_key_file does not exist."
    echo "format:  ~/.ssh/yourPUBLICkey.key"
    echo "try again: ./repeter init"
    exit 1;
  fi

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
