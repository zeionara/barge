#!/bin/bash

function copy_array {
    # Takes two arguments - the name of the variable containing elements to be copied and the name of the variable for saving these values
    __from=$1
    __to=$2

    command="$__to=(); for (( __j=0; __j<\${#$__from[@]}; __j++ )); do $__to[\$__j]=\${$__from[__j]}; done"

    # Evaluate the generated command to perform copyinh
    eval $command
}

function append {
    __array_name=$1
    __element=$2

    eval "$__array_name[\${#$__array_name[@]}]='$__element'"
}
