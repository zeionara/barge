#!/bin/bash

export BARGE_ROOT=$HOME/barge

__suppress_output=1

if [ -z "$BARGE_OPTION_DESCRIPTIONS" ]; then
    export BARGE_OPTION_DESCRIPTIONS=( \
        'foo - a named option' \
        'corge-grault - a named option which must be explicitly set in a call' \
        'garply - an argument with a default value' \
    )
fi

if [ -z "$BARGE_OPTIONS" ]; then
    export BARGE_OPTIONS="[f|foo-bar ... = 'baz qux'] c|corge-grault ... [garply = 'one two three'] [p|plugh-xyyzy = oops|spoo]"
    export BARGE_DESCRIPTION="Demo command-line tool configuration using barge scripts"
    # export BARGE_OPTION_DESCRIPTIONS=()
    # BARGE_OPTION_DESCRIPTIONS[0]='foo - a named option'
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

