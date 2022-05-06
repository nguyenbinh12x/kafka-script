#!/bin/bash

set -e

echo "... Restart any kafka-connector tasks if they are FAILD ..."
curl -s "http://localhost:8083/connectors" | \
  jq '.[]' | \
  xargs -I{connector_name} curl -s "http://localhost:8083/connectors/"{connector_name}"/status" | \
  jq -c -M '[select(.tasks[].state=="FAILED") | .name,"§±§",.tasks[].id]' | \
  grep -v "\[\]"| \
  sed -e 's/^\[\"//g'| sed -e 's/\",\"§±§\",/\/tasks\//g'|sed -e 's/\]$//g'| \
  xargs -I{connector_and_task} curl -v -X POST "http://localhost:8083/connectors/"{connector_and_task}"/restart"

echo "... Checking kafka-connector's status -> Done ..."