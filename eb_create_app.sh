#!/bin/bash

NAME=$1
if [[ -z "${NAME}" ]] ; then
    NAME=ascot
fi

eb init --profile jhu-langmead ${NAME}

