# Repeter
## What is this?
Proxy traffic from a custom DNS domain to your localhost.

`www.nelson.dev.nelsonenzo.com` -> `localhost:4000`

The domain becomes accessible from the public interwebs, which is usefull for:
- developing authentication flows, like Sign in with Google, from your localhost.
- If your a developer, show off your dev work to  your boss.
- If your qa, show the developers what is off when run on your machine.

Traffic is proxied via nginx run on an t2.micro ec2, and it connects to your localhost via a
good old vashioned ssh tunnel.

The AWS infra - dns, ssh keys, ec2 instances, and route53 is all automated using Pulumi.

Pulumi is like terraform, but cooler.

## Demo
[Click for a Demo Gif, it's 8MB](https://public-repeter.s3-us-west-2.amazonaws.com/demo1.gif)

## Requirements
- AWS IAM Keys that can manage ec2, ec2 keys, security groups, and Route53
- Pulumi > 2.1 https://www.pulumi.com/docs/get-started/aws/install-pulumi/
- node.js https://nodejs.org
- jq https://stedolan.github.io/jq/
- bash (untested with zsh shell, you have been warned)

## Install
```
git clone git@github.com:nelsonenzo/repeter.git
cd repeter
chmod +x repeter

## ln makes it easier to run, but only from this directory.
## alternately, just call it with ./repeter [options]
ln -nfs "$PWD"/repeter $HOME/.local/bin/repeter
```
## Initialize
```
./repeter init
```
Which will:
- prompt you for config inputs and create config.json
- You can `cat config.example.json` if it helps you with the inputs.
- subdomains is the trickiest input. it's a space delimited list of subdomain:port
`sub:localport sub2:localport2`
- You can keep it simple and only forward one domain `sub:localport` to start.

## All Commands
```
./repeter init           ## input configuration, then auto runs up and tunnel.
./repeter pulumi up      ## Bring the AWS Infrastrure up using Pulumi.
./repeter tunnel up      ## Starts the all the ssh tunnels locally.
./repeter tunnel down    ## Stops the ssh tunnels locally, but leaves AWS infra up.
./repeter pulumi down    ## Destroys AWS infra, leaves Pulumi stack.
./repeter destroy        ## Destroys AWS infra and Pulumi stack.
./repeter help           ## outputs this text.
./repeter status         ## Outputs pulumi stack status and tails tunnel logs.
./repeter https          ## Enables https via letsencrypt. Run after "repeter pulumi up".
```

## Typical Usage
This is how I typically use it in real life.
```
## I run this just one time
repeter init
> repeter-nelson
> us-west-2
> dev.nelsonenzo.com
> www.nelson:3000 api.nelson:8000
> my-ssh-PUBLIC-key-text

## bring up the aws infrastructure
repeter pulumi up

## start the local tunnel
repeter tunnel up

## That will bring everything up.
## If I have services running at localhost:3000 and localhost:8000,
## they can be accessed publicly on:
curl www.nelson.dev.nelsonenzo.com
curl api.nelson.dev.nelsonenzo.com

## I turn down the tunnel when I don't want localhost exposed to the interwebs.
repeter tunnel down

## I edit the config file to change:
## local_ports, subdomains, root domain, aws region, or public_key
vi ~/.repeter/config.json

## I apply the changes and restart the tunnels.
repeter pulumi up
repeter tunnel up

## I delete the infrastructure when I don't want to pay for the micro instance.
repeter pulumi down

## Come back the next morning and bring it up again
repeter pulumi up
repeter tunnel up
```

After it's initialized, you don't need to run that again as long as `./config.json` is properly formatted, even after a `repeter destroy`.

Run `repeter aws down`, then edit the local ports it maps to.

You can edit the config file local_ports and then use `repeter pulumi up`
and it will pick up your changes.

If you change your subdomains, make sure to edit both the `subdomains` and `local_ports key values` accordingly.  The `key values` is the `subdomain with '.' and '-' replaced with an underscore _`  e.g. `auth.nelson-dev` -> `auth_nelson_dev`

## FAQ's
Q: What advantages does this have over other sass offerings, free and paid?
- more performative, especially when run in an AWS zone near where you sit.
- fully customizeable DNS, using a record owned and managed by you.
- you control the nginx config that does the proxy'ing if you need it to do something special.
- traffic does not get served through a 3rd party's infrastructure.
- turn the t2.micro up and down as you need it, no need to pay for infra when it's not in use.

Q: Does it support SSL?
- Yes! After `./repeter pulumi up`, run `./repeter https`. Give it about a minute for letsencrypt to resolve.

Q: Does it support other cloud providers?
- No, not yet.

Q: Where is the nginx config?
- `src/pulumi/user_data.sh.ejs`
- look for the `server{ }` block.

Q: Why is spelled `repeter` instead of `repeater`?
- I like the French spelling better.

Q: Why does it use Pulumi instead of Terraform?
- I needed to learn Pulumi for work.  It will likely be ported to Terraform in the next couple months.

## Alpha Release
This code was assembled "hackathon style" over a few days, aka it's ugly. Going between bash and node.js did not help any.  A re-write to purely node.js is likely in this repo's future.  Please report bugs, request for help, and feature requests via github.

## Security
Alpha.  SSH tunnels are quite secure, but at the time of this alpha release, there was not much thought to restricting the ssh user on the ec2 that is created.  Only allow developers you trust to have ssh'ed into your aws environment to do so.

## Troubleshooting
If you see a message like this, wait for dns to resolve and try `./repeter tunnel up` in a couple minutes.
```
auth@auth.config.repeter.nelsonenzo.com: Permission denied (publickey).
Bad remote forwarding specification ':<html>
```
**Check if DNS resolves**

`dig -t A api.nelson.repeter.nelsonenzo.com`

You should get back an A record that matches the ip `repeter pulumi up` spits out at the end.

**Check config.json file**
```
cat ~/.repeter/config.json
```
It should look like this:
```
{
  "dns_host_zone": "repeter.nelsonenzo.com",
  "subdomains": "auth.nelson api.nelson www.nelson",
  "local_ports": {
    "auth_nelson": "4000",
    "api_nelson": "9000",
    "www_nelson": "8000"
  },
  "public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCTUaboK49EnWjAHyeRFzsfumBfdvcVRrE+MNsHveJgNteMvueVbqiq2y3McIRZdR5zL8Bg4Gfp/Pbp8r6t/gYW1g1Lu0TnzSl47fLjnYUs3yAcVP5xD/ePE9fMDIr1BgP+iarEWYQULp/4WLhIcJmMszUFP+RN9XI4GjH1AAMRGWphnWQ9+rHOfAst1Yp06cECPbZGS0M+69t7gvbwDbBYRpGnEuVbSXVA3Dy7Wb9P3Lzp0aUiUCo5CD/xDodY0+XBX7+82aYbUY0T8vCSbxN61OXjiQXTV07R8rcs5hNxhVJCcgUijp/PQYNCAZjkP3Fde5UlQZGQMat03FCw6Uhllt6DczJ+n7XSh4lcI7ukFxrFqvlzgT6SXctWqwceZo7xUME70HOdXdZOo9yt6LQNk/ddAiWowqXIwEAqOP3+I+eOGU7fYjOc4l99uZpZbHr/vj1N0mt8s8bbTQqfUTSp3CAGqCQR1P/nPCwVYooiLB8iGQifz2ix92Sz2Obvd20+jDyHr3RyvOksBFG245BQIMJ70Gjl9TS1Uo2YoQjbU6mSqaZaxMA6Uq3WAYwg3lskrtHMdDqQTtgXMFYyA7QWyn27x5/Wu4IJkRmgfzs72ebnwrrPeBVen7/wXiFFJRGXDHelEblcUarwgDwQdddLgb+5VbKHIwGTz1chDh3ntw== nelsonh@gmail.com"
}
```
- local_ports is a json object of subdomain with '.' and '-' characters replaced with '\_' as keys
- public_key should be your actual public key, not a file reference.  Be sure you have added your private key to the running ssh-agent via `ssh-agent add ~/.ssh/private_key.pem`. Use `ssh-agent -l` to verify.

**Check status of Pulumi stack and ssh tunnel logs**
```
repeter status
```
This runs `pulumi stack status` and tails the logs file in ./logs/*
## License
idk, MIT, I guess.
