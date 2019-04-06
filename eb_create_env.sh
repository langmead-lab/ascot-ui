#!/bin/bash

eb create --profile jhu-langmead test \
    -c ascot-test \
    --instance_type t3.micro
