@echo off
SETLOCAL enableextensions enableDelayedExpansion

FOR /L %%G IN (1,1,%1) DO (
  set "formattedValue=000000%%G"
  @powershell -Command "get-content options-kubernetes-cluster.json.template | %% { $_ -replace \"TOBEREPLACED\",\"!formattedValue:~-2!\" }" > options-kubernetes-cluster!formattedValue:~-2!.json
)
