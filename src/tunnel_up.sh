
local_port() {
  _domain=$1;
  _domain=$(echo "${_domain//\./_}")
  _domain=$(echo "${_domain//-/_}")
  _domain=$(echo "${_domain//\"/}")
  _local_port=$(cat $REPETERDIR/config.json | jq ".local_ports.$_domain");
  _local_port=${_local_port//\"/}
  echo $_local_port
}

if [[ "$1" == 'tunnel' ]] && [[ "$2" == 'up' ]]; then

  DNS_HOST_ZONE=$(cat $REPETERDIR/config.json | jq '.dns_host_zone') #"something.com"
  SUBS=$(cat $REPETERDIR/config.json | jq '.subdomains') # "one two three"
  LOCAL_PORTS=$(cat $REPETERDIR/config.json | jq '.local_ports')

 for sub in $SUBS; do
   DOMAIN="${sub//\"/}.${DNS_HOST_ZONE//\"/}"

   ## extract the user from user.domain
   USER=$(echo $DOMAIN | awk -F '.' '{print $1}')

   ## fetch the ssh tunnel port configured on the server
   SSH_PORT=$(curl -s $DOMAIN/_port/$DOMAIN)

   ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$DOMAIN" > /dev/null 2>&1

   ssh -o "StrictHostKeyChecking=accept-new" $USER@$DOMAIN exit > /dev/null 2>&1

   mkdir -p logs

   FORWARD_TO_PORT=$(local_port $sub)
   echo $DOMAIN '->' localhost:$FORWARD_TO_PORT
   # FORWARD_TO_PORT=${FORWARD_TO_PORT//\"/}
   ## begin the ssh tunnel
   ssh -N -R :$SSH_PORT:localhost:$FORWARD_TO_PORT $USER@$DOMAIN > $REPETERDIR/logs/$DOMAIN.log 2>&1 &
   # TODO: handle these responses:
   # Warning: remote port forwarding failed for listen port 8001
   # - could mean this is already running in another window.

 done
fi
