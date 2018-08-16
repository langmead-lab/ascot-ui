#!/bin/sh

docker exec -ti ascot-ui /bin/bash -c "cat /var/log/shiny-server/ascot-ui-shiny*.log"
