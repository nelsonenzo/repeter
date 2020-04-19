STRIPQ(){
  instring=$1
  echo ${instring//\"/}
}
CONFIG(){
  STRIPQ $(cat $REPETERDIR/config.json | jq ".$1")
}
KILL_SSH_TUNNELS(){
    subdomains=$(cat $REPETERDIR/config.json | jq '.subdomains')
    domain=$(cat $REPETERDIR/config.json | jq '.dns_host_zone')

    for sub in $subdomains; do
      user=$(echo $sub | awk -F '.' '{print $1}')
      pkill -9 -f "ssh.*$(STRIPQ ${user})@$(STRIPQ ${sub}).$(STRIPQ ${domain})"
    done
}
hLineBreakEcho(){ _message=$1;
  echo "" && echo "====++++----repeter----++++===="
  echo $_message
  echo "====++++----repeter----++++====" && echo ""
}
