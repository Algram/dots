#!/usr/bin/env bash

CO2=$(curl -s -X GET -H "Authorization: Bearer" -H "Content-Type: application/json"  http://192.168.1.152:8123/api/states/sensor.mh_z19_co2_value | jq -r '.state');
echo $CO2