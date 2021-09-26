#!/bin/bash

function exit_if {
    # This function accepts condition checking which one can determine that script is not in a correct state, the message which describes this state to the user and an optional exit code
    __condition=$1
    __message=$2
    __code=${3:-1}
    
    command="if $__condition; then echo \"$__message\"; exit 1; fi"

    eval $command
}

function exit_if_not_set {
    # This function handles a special case for errors - when environment variables are nor provided by the user; the first argument is the env variable name, the second one is the 
    # message to print on errors and the last one is an optional exit code
    __env_variable=$1
    __message=$2
    __code=${3:-1}

    exit_if "[ -z \"\$$__env_variable\" ]" "$__env_variable env variable is not specified; $__message"
}

function exit_if_not_equals {
    # This function handles a special case for errors - when environment variables are nor provided by the user; the first argument is the env variable name, the second one is the 
    # message to print on errors and the last one is an optional exit code
    __env_variable=$1
    __target_value=$2
    __code=${3:-1}

    exit_if "[ \"\$$__env_variable\" != \"$__target_value\" ]" \
        "$__env_variable env variable accepts value which is different from expected (expected $__target_value, got \$$__env_variable) $__message"
}

