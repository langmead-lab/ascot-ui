#!/bin/sh

d=$(dirname $0)

docker build --tag $(cat ${d}/image.txt) $* .
