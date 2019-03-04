rem @echo off
SETLOCAL enableextensions enableDelayedExpansion
set clusters=%1
FOR /F "tokens=* USEBACKQ" %%F IN (`dcos node --json ^| jq-win64 --raw-output ".[] | select((.type | test(\"agent\")) and (.attributes.public_ip != null)) | .id" ^| find /c /v ""`) do (SET publicnodes=%%F)
(
echo {
echo   "apiVersion":"V2",
echo   "name":"all",
echo   "namespace":"infra/network/dcos-edgelb/pools",
echo   "count":%publicnodes%,
echo   "autoCertificate":true,
echo   "haproxy":{
echo      "stats":{
echo         "bindPort":9090
echo      },
echo      "frontends":[
echo         {
echo            "bindPort":8443,
echo            "protocol":"HTTPS",
echo            "certificates":[
echo               "$AUTOCERT"
echo            ],
echo            "linkBackend":{
echo               "map":[
echo                  {
echo                     "hostEq":"infra.storage.portworx.mesos.lab",
echo                     "backend":"infra-storage-portworx"
echo                  },) > pool-edgelb-all.json
FOR /L %%G IN (1,1,%clusters%) DO ((
set "formattedValue=000000%%G"
echo                  {
echo                     "hostEq":"training.prod.k8s.cluster!formattedValue:~-2!.mesos.lab",
echo                     "backend":"training-prod-k8s-cluster!formattedValue:~-2!-backend"
echo                  })>> pool-edgelb-all.json
IF /I "%%G" NEQ "%clusters%" (
echo                  , >> pool-edgelb-all.json)
)
(
echo                 ]
echo            }
echo         }
echo      ],
echo      "backends":[
echo         {
echo            "name":"infra-storage-portworx",
echo            "protocol":"HTTP",
echo            "services":[
echo               {
echo                  "endpoint":{
echo                     "type":"ADDRESS",
echo                     "address":"lighthouse-0-start.infrastorageportworx.autoip.dcos.thisdcos.directory",
echo                     "port":8085
echo                  }
echo               }
echo            ]
echo         },) >> pool-edgelb-all.json
FOR /L %%G IN (1,1,%clusters%) DO ((
set "formattedValue=000000%%G"
echo         {
echo            "name":"training-prod-k8s-cluster!formattedValue:~-2!-backend",
echo            "protocol":"HTTPS",
echo            "services":[
echo               {
echo                  "mesos":{
echo                     "frameworkName":"training/prod/k8s/cluster!formattedValue:~-2!",
echo                     "taskNamePattern":"kube-control-plane"
echo                  },
echo                  "endpoint":{
echo                     "portName":"apiserver"
echo                  }
echo               }
echo            ]
echo         }) >> pool-edgelb-all.json
IF /I "%%G" NEQ "%clusters%" (
echo                  , >> pool-edgelb-all.json)
)
(
echo      ]
echo   }
echo }) >> pool-edgelb-all.json
