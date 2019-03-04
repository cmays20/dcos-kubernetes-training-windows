rem @echo off
SETLOCAL enableextensions enableDelayedExpansion
SET clusters=%1
SET loadbalancer=%2
SET group=%3
CALL maws login %AWSACCOUNT%
SET region=us-west-2

aws --region=%region% elb create-load-balancer-listeners --load-balancer-name=%loadbalancer% --listeners Protocol=TCP,LoadBalancerPort=8443,InstanceProtocol=TCP,InstancePort=8443
FOR /L %%G IN (1,1,%clusters%) DO (
  set "formattedValue=000000%%G"
  aws --region=%region% elb create-load-balancer-listeners --load-balancer-name=%loadbalancer% --listeners Protocol=TCP,LoadBalancerPort=80!formattedValue:~-2!,InstanceProtocol=TCP,InstancePort=80!formattedValue:~-2!
)
SET "clusterFormatted=000000%%G"
aws --region=%region% ec2 authorize-security-group-ingress --group-id=%group% --protocol=tcp --port=8001-80!formattedValue:~-2! --cidr=0.0.0.0/0
aws --region=%region% ec2 authorize-security-group-ingress --group-id=%group% --protocol=tcp --port=9001-90!formattedValue:~-2! --cidr=0.0.0.0/0
aws --region=%region% ec2 authorize-security-group-ingress --group-id=%group% --protocol=tcp --port=10001-100!formattedValue:~-2! --cidr=0.0.0.0/0
