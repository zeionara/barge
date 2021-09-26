#!/bin/bash

function run_unitary_argument_option_test {
    export BARGE_OPTIONS="[foo-bar]"
    source $BARGE_ROOT/main.sh 'baz'
    
    exit_if_not_equals "FOO_BAR" 'baz'
}


function run_unitary_argument_test_with_default_value {
    export BARGE_OPTIONS="[foo-bar = baz]"
    source $BARGE_ROOT/main.sh
    
    exit_if_not_equals "FOO_BAR" 'baz'
}


function run_unitary_argument_test_with_default_value_consisting_of_two_words {
    export BARGE_OPTIONS="[foo-bar = 'baz qux']"
    source $BARGE_ROOT/main.sh
    
    exit_if_not_equals "FOO_BAR" 'baz qux'
}


function run_unitary_argument_test_with_default_value_consisting_of_one_word_given_in_quotes {
    export BARGE_OPTIONS="[foo-bar = 'baz']"
    source $BARGE_ROOT/main.sh
    
    exit_if_not_equals "FOO_BAR" 'baz'
}

