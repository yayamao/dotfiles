#!/bin/bash

mpstat | grep "all" | \
  awk '$13 ~ /[[:digit:]]+/ { printf "CPU: "100 - $13"% " }'
free | grep "Mem:" | \
  awk '$7 ~ /[[:digit:]]+/ { printf "MEM: %.2f%%\n", ($3 - $7) / $2 * 100}'
