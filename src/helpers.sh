STRIPQ(){
  instring=$1
  echo ${instring//\"/}
}
CONFIG(){
  STRIPQ $(cat $HOME/.repeter/config.json | jq ".$1")
}
KILL_SSH_TUNNELS(){
    subdomains=$(CONFIG "subdomains")
    domain=$(CONFIG "dns_host_zone")

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
