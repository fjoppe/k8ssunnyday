#!/bin/bash

#   This script will print a few url's to stdout, which you can copy/paste in your browser
#   Note, after deployment, it can take a few minutes before the application has warmed up
#   The ALB load balancer must be in State "Active" before these links work


baseurl=`aws elbv2 describe-load-balancers --query LoadBalancers[*].DNSName --output text`

echo Make sure the ALB has been provisioned before opening these links in your browser
echo Open these in a browser:
echo http://$baseurl/BRA
echo http://$baseurl/GUY
