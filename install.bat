SET APPNAME=training
REM The public ip address of the ELB fronting your public agent
SET PUBLICIP=
SET AWSACCOUNT=
REM The number of kubernetes clusters to spin up
SET clusters=2
REM The name of the ELB in front of your public agent
SET loadbalancer=cmays-od1-PublicSl-1R60S6LSR2XPS
REM The group ID of the AWS Security Group of the DC/OS public node
SET group=


REM NOT NEEDED WITH CCM Cluster
REM create-and-attach-volumes.bat
# If clusters < 10, then use 01, 02, ...
update-aws-network-configuration.bat ${clusters} ${loadbalancer} ${group}

dcos package install --yes --cli dcos-enterprise-cli

deploy-kubernetes-mke.bat

create-all-k8s-option-files.bat %clusters%
deploy-all-k8s-clusters.bat %clusters%

create-pool
