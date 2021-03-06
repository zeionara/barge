#!/bin/bash

function run_unitary_flag_test {
    export BARGE_OPTIONS="[f|foo-bar]"
    source $BARGE_ROOT/main.sh -f 
    
    exit_if_not_equals "FOO_BAR" '1'
}


function run_unitary_flag_test_with_default_value {
    export BARGE_OPTIONS="[f|foo-bar = baz]"
    source $BARGE_ROOT/main.sh
    
    exit_if_not_equals "FOO_BAR" 'baz'
}


function run_unitary_flag_test_with_default_value_consisting_of_two_words {
    export BARGE_OPTIONS="[f|foo-bar = 'baz qux']"
    source $BARGE_ROOT/main.sh
    
    exit_if_not_equals "FOO_BAR" 'baz qux'
}


function run_unitary_flag_test_with_default_value_consisting_of_one_word_given_in_quotes {
    export BARGE_OPTIONS="[f|foo-bar = 'baz']"
    source $BARGE_ROOT/main.sh
    
    exit_if_not_equals "FOO_BAR" 'baz'
}

function run_unitary_flag_test_with_two_preconfigured_values_with_default_option {
    export BARGE_OPTIONS="[f|foo-bar = baz|zab]"
    source $BARGE_ROOT/main.sh
    
    exit_if_not_equals "FOO_BAR" 'baz'
}

function run_unitary_flag_test_with_two_preconfigured_values_with_provided_option {
    export BARGE_OPTIONS="[f|foo-bar = baz|zab]"
    source $BARGE_ROOT/main.sh -f
    
    exit_if_not_equals "FOO_BAR" 'zab'
}

function run_unitary_flag_test_with_two_preconfigured_values_with_default_option_and_spaces {
    export BARGE_OPTIONS="[f|foo-bar = ' baz|za b']"
    source $BARGE_ROOT/main.sh
    
    exit_if_not_equals "FOO_BAR" ' baz'
}

function run_unitary_flag_test_with_two_preconfigured_values_with_provided_option_and_spaces {
    export BARGE_OPTIONS="[f|foo-bar = ' baz|za b']"
    source $BARGE_ROOT/main.sh -f
    
    exit_if_not_equals "FOO_BAR" 'za b'
}
