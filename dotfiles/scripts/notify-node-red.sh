#!/bin/bash

mosquitto_pub -h 192.168.1.152 -u raphael -P 1234 -t "notify/workstation_shutdown" -m true