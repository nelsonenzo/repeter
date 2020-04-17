fs = require('fs');

var myArgs = process.argv.slice(2);

let dns_host_zone = myArgs[0].trim()
let tunnel_maps = myArgs[1].trim()
let public_key = myArgs[2].trim()
let pulumi_stack = myArgs[3].trim()
let aws_region = myArgs[4].trim()

// {"auth_fresh":"4000","api_fresh":"9000","www_fresh":"8000"}
var local_ports = {}
// "auth_fresh api_fresh www_fresh"
var subdomains = ""
const tunnels = tunnel_maps.split(" ");
for (var i=0; i < tunnels.length; i++) {
  // auth.nelson:4000
  let route = tunnels[i]
  let combo = route.split(':')
  let sub = combo[0]
  let port = combo[1]
  subdomains = subdomains + sub + " "
  let key = sub.replace(".","_").replace("-","_")
  local_ports[key] = port
}
subdomains = subdomains.trim(' ')

let config = {
   dns_host_zone: dns_host_zone,
   subdomains: subdomains,
   local_ports: local_ports,
   public_key: public_key,
   pulumi_stack: pulumi_stack,
   aws_region: aws_region
}

// fs.writeFile('testconfig.json', config)
fs.writeFile('config.json', JSON.stringify(config, undefined, 2), (err) => {
  if (err) return console.log(err);
  // console.log(data)
});
