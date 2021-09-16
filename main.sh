#!/bin/bash

# while [[ $# -gt 0 ]]; do
#     echo $1
#     shift
# done

eval "source ./parse.sh \"$@\""
echo $CORGE_GRAULT
# echo hello world
