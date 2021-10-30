#!/usr/bin/env bash

CO2=$(curl -s -X GET -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI4NDVjZWMzNzY3MzY0OGVmOTAzODA3YTQ3NmNlN2M1NCIsImlhdCI6MTYzNDkzNDQwOSwiZXhwIjoxOTUwMjk0NDA5fQ.NyDwEO4aUEtpROlzM9ur_Y8iH6_ECEcRWMsytvgBYsA" -H "Content-Type: application/json"  http://192.168.1.152:8123/api/states/sensor.mh_z19_co2_value | jq -r '.state');
echo $CO2