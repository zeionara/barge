#!/bin/bash

source $BARGE_ROOT/utils/string.sh
source $BARGE_ROOT/utils/files.sh

function run_unitary_named_option_test {
    export BARGE_OPTIONS="[f|foo-bar ...]"
    source $BARGE_ROOT/main.sh -f 'baz'
    
    exit_if_not_equals "FOO_BAR" 'baz'
}


function run_unitary_named_option_test_with_default_value {
    export BARGE_OPTIONS="[f|foo-bar ... = baz]"
    source $BARGE_ROOT/main.sh
    
    exit_if_not_equals "FOO_BAR" 'baz'
}


function run_unitary_named_option_test_with_default_value_consisting_of_two_words {
    export BARGE_OPTIONS="[f|foo-bar ... = 'baz qux']"
    source $BARGE_ROOT/main.sh
    
    exit_if_not_equals "FOO_BAR" 'baz qux'
}


function run_unitary_named_option_test_with_default_value_consisting_of_one_word_given_in_quotes {
    export BARGE_OPTIONS="[f|foo-bar ... = 'baz']"
    source $BARGE_ROOT/main.sh
    
    exit_if_not_equals "FOO_BAR" 'baz'
}

function run_help_option_test_passing_only_description {
    export BARGE_DESCRIPTION='Foo bar'
    export BARGE_OPTIONS='[f|foo-bar ...]'

    replace_option_descriptions_in_main

    compare_output_with_file './main.sh -h' 'assets/test/help-option/only-description.txt'

    return_original_version_of_main
}

function run_help_option_test_passing_description_and_options {
    export BARGE_DESCRIPTION='Foo bar'
    export BARGE_OPTIONS='[f|foo-bar ...]'
    export BARGE_OPTION_DESCRIPTIONS=(\
        'baz' \
        'qux quux' \
        'quuz corge grault' \
    )

    replace_option_descriptions_in_main

    compare_output_with_file "./main.sh -h" 'assets/test/help-option/description-and-options.txt'

    return_original_version_of_main
}
