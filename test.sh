#!/bin/bash

export BARGE_ROOT=$HOME/barge

source $BARGE_ROOT/test/named_option.sh
source $BARGE_ROOT/test/argument.sh
source $BARGE_ROOT/test/flag.sh

n_passed_tests=0
n_executed_tests=0

function count_tests_decorator {
    n_executed_tests=$((n_executed_tests + 1))

    eval "$1"

    n_passed_tests=$((n_passed_tests + 1))
}


count_tests_decorator "run_unitary_named_option_test"
count_tests_decorator "run_unitary_named_option_test_with_default_value"
count_tests_decorator "run_unitary_named_option_test_with_default_value_consisting_of_two_words"
count_tests_decorator "run_unitary_named_option_test_with_default_value_consisting_of_one_word_given_in_quotes"

count_tests_decorator "run_unitary_argument_option_test"
count_tests_decorator "run_unitary_argument_test_with_default_value"
count_tests_decorator "run_unitary_argument_test_with_default_value_consisting_of_two_words"
count_tests_decorator "run_unitary_argument_test_with_default_value_consisting_of_one_word_given_in_quotes"

count_tests_decorator "run_unitary_flag_test"
count_tests_decorator "run_unitary_flag_test_with_default_value"
count_tests_decorator "run_unitary_flag_test_with_default_value_consisting_of_two_words"
count_tests_decorator "run_unitary_flag_test_with_default_value_consisting_of_one_word_given_in_quotes"

echo "Passed $n_passed_tests/$n_executed_tests tests"

