#!/usr/bin/env bash

RADON=$(curl -s -X GET -H "Authorization: Bearer" -H "Content-Type: application/json"  http://192.168.1.152:8123/api/states/sensor.radon | jq -r '.state');
echo $RADON