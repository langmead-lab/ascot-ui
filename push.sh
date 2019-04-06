#!/bin/bash

d=$(dirname $0)

docker push $(cat ${d}/image.txt)
