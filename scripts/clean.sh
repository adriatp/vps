#!/bin/bash

echo "This will delete all containers, volumes, and networks (except default ones)."
read -p "Confirm? (y/Y to continue): " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
  docker rm -f $(docker ps -aq) 2>/dev/null
  docker volume rm -f $(docker volume ls -q) 2>/dev/null
  docker network rm $(docker network ls -q | grep -vE '^(bridge|host|none)$') 2>/dev/null
  echo "Done."
else
  echo "Cancelled."
fi
