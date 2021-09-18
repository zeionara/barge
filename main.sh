#!/bin/bash

export BARGE_ROOT=$HOME/barge
export BARGE_OPTIONS="[f|foo-bar ...] c|corge-grault ... garply [p|plugh-xyyzy]"

input_line=""
space_replacement="SPACE"

for arg; do
    arg_with_replaced_spaces="$(echo "$arg" | sed -E "s/\s/$space_replacement/g")"
    if [ "$input_line" == "" ]; then
        input_line="$arg_with_replaced_spaces"
    else
        input_line="$input_line $arg_with_replaced_spaces"
    fi
done

source $BARGE_ROOT/parse.sh "$input_line" "$space_replacement"

echo "CORGE_GRAULT='$CORGE_GRAULT'"
echo "FOO_BAR='$FOO_BAR'"
echo "GARPLY='$GARPLY'"
echo "PLUGH_XYYZY='$PLUGH_XYYZY'"

