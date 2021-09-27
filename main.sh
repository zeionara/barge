#!/bin/bash

export BARGE_ROOT=$HOME/barge

__suppress_output=1
if [ -z "$BARGE_OPTIONS" ]; then
    export BARGE_OPTIONS="[f|foo-bar ... = 'baz qux'] c|corge-grault ... [garply = 'one two three'] [p|plugh-xyyzy = oops|spoo]"
    __suppress_output=0
fi

space_replacement="<<SPACE>>"

if [ -z $space_replacement ]; then
    eval "source $BARGE_ROOT/parse.sh \"$@\""
else
    input_line=""

    for arg; do
        arg_with_replaced_spaces="$(echo "$arg" | sed -E "s/\s/$space_replacement/g")"
        if [ "$input_line" == "" ]; then
            input_line="$arg_with_replaced_spaces"
        else
            input_line="$input_line $arg_with_replaced_spaces"
        fi
    done

    source $BARGE_ROOT/parse.sh "$input_line" "$space_replacement"
fi

if [ $__suppress_output -eq 0 ]; then
    echo "CORGE_GRAULT='$CORGE_GRAULT'"
    echo "FOO_BAR='$FOO_BAR'"
    echo "GARPLY='$GARPLY'"
    echo "PLUGH_XYYZY='$PLUGH_XYYZY'"
fi

