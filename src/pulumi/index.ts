// read ./config.json
let config = require('../../config.json')
const PUBLIC_KEY = config.public_key;
const SUBDOMAINS = config.subdomains;
const DNS_HOST_ZONE = config.dns_host_zone;
const HOST_ZONE_ID = config.host_zone_id

var ENDPOINTS = "";
for (var SUB of SUBDOMAINS.split(' ')) {
  ENDPOINTS = SUB + "." + DNS_HOST_ZONE + " " + ENDPOINTS;
}
ENDPOINTS = ENDPOINTS.trim()

import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";
let ejs = require('ejs');

// Security Group
const group = new aws.ec2.SecurityGroup("repeter", {
    ingress: [
        { protocol: "tcp", fromPort: 22, toPort: 22, cidrBlocks: ["0.0.0.0/0"] },
        { protocol: "tcp", fromPort: 80, toPort: 80, cidrBlocks: ["0.0.0.0/0"] }
    ],
    egress: [
        { protocol: "tcp", fromPort: 0, toPort: 65535, cidrBlocks: ["0.0.0.0/0"] }
    ],
});

// EC2
const size = "t2.micro";     // t2.micro is available in the AWS free tier
const ami = aws.getAmi({
    filters: [{
      name: "description",
      values: ['Canonical, Ubuntu, 18.04 LTS, amd64 bionic image build on 2020-01-12'],
      }, {
      name: "root-device-type",
      values: ['ebs']
    }],
    owners: ["099720109477"],
    mostRecent: true,
});

// ec2 keypair: https://www.pulumi.com/docs/reference/pkg/aws/ec2/keypair/
const repeter_ssh_key = new aws.ec2.KeyPair("repeter", {
    publicKey: PUBLIC_KEY
});

// ec2 webserver: https://www.pulumi.com/docs/tutorials/aws/ec2-webserver/
var userdata = "";
ejs.renderFile("user_data.sh.ejs",{endpoints: ENDPOINTS, public_key: PUBLIC_KEY },function(error: string, rendered: string){
  userdata = rendered;
});

const server = new aws.ec2.Instance("repeter", {
    instanceType: size,
    securityGroups: [ group.name ], // reference the security group resource above
    ami: ami.id,
    keyName: repeter_ssh_key.keyName,
    userData: userdata
});

// Assumes hosted zone itself already exists.
const hostedZone = aws.route53.getZone({ name: DNS_HOST_ZONE });

// loop through endpoints (which are subdomain.domain.ltd)
// to create or update Route53 record
const endpoints = ENDPOINTS.split(" ");
for (var i=0; i < endpoints.length; i++) {
  var endpoint = endpoints[i]
  const dns = new aws.route53.Record(endpoint, {
      name: endpoint,
      records: [server.publicIp],
      ttl: 60,
      type: "A",
      zoneId: hostedZone.id
      // zoneId: aws_route53_zone_primary.zoneId,
  });
}

export const publicIp = server.publicIp;
export const publicHostName = server.publicDns;
