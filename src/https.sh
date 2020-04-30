iEnableHttps(){
    _subdomains=$(CONFIG 'subdomains');
    _dhz=$(CONFIG 'dns_host_zone')
    _domains="";
    for sub in $_subdomains; do
        _domains=$(echo $_domains $sub.$_dhz)
    done
    echo $_domains
    
    IFS=' ' # space is set as delimiter
    read -ra ADDR <<< "$_domains"

    ssh ubuntu@"${ADDR[0]}" "sudo certbot --nginx --domains $_domains --agree-tos --email email@dummyplaceholder.com --non-interactive"

}