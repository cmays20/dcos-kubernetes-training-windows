@echo off
SETLOCAL enableextensions enableDelayedExpansion

FOR /L %%G IN (1,1,%1) DO (
  set "formattedValue=000000%%G"
  call deploy-kubernetes-cluster.bat !formattedValue:~-2!
)
