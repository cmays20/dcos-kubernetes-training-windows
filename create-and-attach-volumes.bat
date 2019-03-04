@echo off
CALL maws login %AWSACCOUNT%
SET volumetag=cmays
SET tag=cmays-privateagent
SET region=us-west-2
SET device=/dev/xvdc
SETLOCAL enableextensions enableDelayedExpansion

FOR /F "tokens=* USEBACKQ" %%F IN (`aws --region=%region% ec2 describe-instances ^|  jq-win64 --raw-output ".Reservations[].Instances[] | select((.Tags | length) > 0) | select(.Tags[].Value | test(\"%tag%\")) | select(.State.Name | test(\"running\")) | [.InstanceId, .Placement.AvailabilityZone] | \"\^(.[0]^) \^(.[1]^)\""`) do (
  FOR /F "tokens=1-2 delims= " %%A in ("%%F") do (
    FOR /F "tokens=* USEBACKQ" %%V IN (`aws --region=%region% ec2 create-volume --size=100  --availability-zone=%%B --tag-specifications="ResourceType=volume,Tags=[{Key=Name,Value=%volumetag%}]" ^| jq-win64 --raw-output .VolumeId`) do (SET volume=%%V)
    TIMEOUT 10 /NOBREAK
    (
      aws --region=%region% ec2 attach-volume --device=%device% --instance-id=%%A --volume-id=!volume!
    )
  )
)
