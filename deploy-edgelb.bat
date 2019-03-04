SET marathon-path=infra/network/dcos-edgelb
SET serviceaccount=infra-network-dcos-edgelb

dcos security org service-accounts keypair private-%serviceaccount%.pem public-%serviceaccount%.pem
dcos security org service-accounts delete %serviceaccount%
dcos security org service-accounts create -p public-%serviceaccount%.pem -d /%marathon-path% %serviceaccount%
dcos security secrets delete /%marathon-path%/private-%serviceaccount%
dcos security secrets create-sa-secret --strict private-%serviceaccount%.pem %serviceaccount% /%marathon-path%/private-%serviceaccount%

dcos security org users grant %serviceaccount% dcos:secrets:default:/%marathon-path%/* full
dcos security org users grant %serviceaccount% dcos:secrets:list:default:/%marathon-path% full
dcos security org users grant %serviceaccount% dcos:adminrouter:service:marathon full
dcos security org users grant %serviceaccount% dcos:adminrouter:package full
dcos security org users grant %serviceaccount% dcos:adminrouter:service:edgelb full
dcos security org users grant %serviceaccount% dcos:service:marathon:marathon:services:/%marathon-path% full
dcos security org users grant %serviceaccount% dcos:mesos:master:endpoint:path:/api/v1 full
dcos security org users grant %serviceaccount% dcos:mesos:master:endpoint:path:/api/v1/scheduler full
dcos security org users grant %serviceaccount% dcos:mesos:master:framework:principal:%serviceaccount% full
dcos security org users grant %serviceaccount% dcos:mesos:master:framework:role full
dcos security org users grant %serviceaccount% dcos:mesos:master:reservation:principal:%serviceaccount% full
dcos security org users grant %serviceaccount% dcos:mesos:master:reservation:role full
dcos security org users grant %serviceaccount% dcos:mesos:master:volume:principal:%serviceaccount% full
dcos security org users grant %serviceaccount% dcos:mesos:master:volume:role full
dcos security org users grant %serviceaccount% dcos:mesos:master:task:user:root full
dcos security org users grant %serviceaccount% dcos:mesos:master:task:app_id full
dcos security org users grant %serviceaccount% dcos:adminrouter:service:%marathon-path%/pools/all full
dcos security org users grant %serviceaccount% dcos:adminrouter:service:%marathon-path%/pools/dklb full

dcos package repo add --index=0 edgelb-aws https://downloads.mesosphere.com/edgelb/v1.3.0/assets/stub-universe-edgelb.json
dcos package repo add --index=0 edgelb-pool-aws https://downloads.mesosphere.com/edgelb-pool/v1.3.0/assets/stub-universe-edgelb-pool.json
dcos package install --yes edgelb --options=options-edgelb.json --package-version=v1.3.0

TIMEOUT 10 /NOBREAK
dcos edgelb create pool-edgelb-all.json
