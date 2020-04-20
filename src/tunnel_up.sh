
fSubLocalPort() {
  _subdomain=$1;
  _subdomain=$(echo "${_subdomain//\./_}")
  _subdomain=$(echo "${_subdomain//-/_}")
  _subdomain=$(echo "${_subdomain//\"/}")
  _local_port=$(STRIPQ $(cat $HOME/.repeter/config.json | jq ".local_ports.${_subdomain}"))
  # _local_port=$(CONFIG ".local_ports.${_subdomain}")
  _local_port=${_local_port//\"/}
  echo $_local_port
}

if [[ "$1" == 'tunnel' ]] && [[ "$2" == 'up' ]]; then

  # DNS_HOST_ZONE=$(CONFIG ".dns_host_zone")
  DNS_HOST_ZONE=$(STRIPQ $(cat $HOME/.repeter/config.json | jq ".dns_host_zone"))
  SUBS=$(STRIPQ $(cat $HOME/.repeter/config.json | jq ".subdomains"))
  # SUBS=$(CONFIG ".subdomains")
  # LOCAL_PORTS=$(CONFIG ".local_ports")

 for sub in $SUBS; do
   DOMAIN="${sub//\"/}.${DNS_HOST_ZONE//\"/}"

   ## extract the user from user.domain
   USER=$(echo $DOMAIN | awk -F '.' '{print $1}')

   ## fetch the ssh tunnel port configured on the server
   SSH_PORT=$(curl -s $DOMAIN/_port/$DOMAIN)

   ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$DOMAIN" > /dev/null 2>&1

   ssh -o "StrictHostKeyChecking=accept-new" $USER@$DOMAIN exit > /dev/null 2>&1

   mkdir -p logs

   FORWARD_TO_PORT=$(fSubLocalPort $sub)
   echo $DOMAIN '->' localhost:$FORWARD_TO_PORT

   ## begin the ssh tunnel
   ssh -N -R :$SSH_PORT:localhost:$FORWARD_TO_PORT $USER@$DOMAIN > $REPETERDIR/logs/$DOMAIN.log 2>&1 &
   # TODO: handle these responses:
   # Warning: remote port forwarding failed for listen port 8001
   # - could mean this is already running in another window.

 done
fi
