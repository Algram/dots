#!/usr/bin/env bash

RADON=$(curl -s -X GET -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjMGRhODY2NWU3NjQ0N2FkOWMwMzE5NjlmOWNiMjgzMSIsImlhdCI6MTYzNTYwODA3MiwiZXhwIjoxOTUwOTY4MDcyfQ.wLTe_IHwlp1C8-_2ZWsPHCgIQXKVoZ4gdLmx2rLybJc" -H "Content-Type: application/json"  http://192.168.1.152:8123/api/states/sensor.radon | jq -r '.state');
echo $RADON