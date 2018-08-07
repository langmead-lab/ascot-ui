#!/bin/sh

docker run --name ascot-ui --rm -p 3838:3838 -d $* ascot-ui
./wait-for-it.sh localhost:3838 -- sleep 2 && open http://localhost:3838/ascot-ui
