#!/bin/bash

export BARGE_ROOT=$HOME/barge
export BARGE_OPTIONS="f|foo-bar ... c|corge-grault ... garply p|plugh-xyyzy"
eval "source $BARGE_ROOT/parse.sh \"$@\""

echo "CORGE_GRAULT=$CORGE_GRAULT"
echo "FOO_BAR=$FOO_BAR"
echo "GARPLY=$GARPLY"
echo "PLUGH_XYYZY=$PLUGH_XYYZY"

