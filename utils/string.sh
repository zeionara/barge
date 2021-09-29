#!/bin/bash

function split_string {
    # The first parameter is required (the string which has to be split) and the second is optional (space character is the default delimiter)
    __splittable_string=$1
    __separator=${2:-" "}

    # If separator is not space, then replace spaces with a special string to avoid splitting the array by these symbols
    # If separator is space, then additional actions are not required and the string can be perceived as an array in its original form
    if [ "$__separator" != " " ]; then
        __splittable_string=$(echo $__splittable_string | sed "s/ /SPACE/g" | sed "s/$__separator/ /g")
    fi

    # Interpret string as an array (elements are separated using space)
    __items=(${__splittable_string[@]})

    # If separator is not space, then replace special space substitutions back to normal space characters
    if [ "$__separator" != " " ]; then
        for (( i=0; i<${#__items[@]}; i++ )); do
            __items[$i]=$(echo ${__items[i]} | sed "s/SPACE/ /g")
        done
    fi

    # Function exection result is saved into the __items variable, there is no returned value
}

function join_string {
    # The function takes only one explicit argument - the separator which can be omitted; the items to join are passed via the variable __items
    __separator=${1:-" "}
    __joined_string=""

    for (( i=0; i<${#__items[@]}; i++ )); do
        __item=${__items[i]}

        # Sequentually join all the items except first to the rest of the generated string except the first item 
        if [ $i -ne 0 ]; then
            __joined_string="$__joined_string$__separator$__item"
        else
            __joined_string="$__item"
        fi
    done

    # The generated string is explicitly printed out as a result of function execution
    echo $__joined_string
}

function as_constant_name {
    # The function allows to convert a string from format conveniet for passing value through cli interface to representation which applied for naming constants in bash scripts
    echo $(echo ${1^^} | tr - _)
}

function drop_brackets {
    echo "$(echo "$1" | sed -E 's/\[|\]//g')"
}

function is_optional {
    __input_without_leading_spaces=$(echo "$1" | sed -E 's/^\s+|\s+$//g')
    __lacks_closing_bracket=$2
    if [ ${__input_without_leading_spaces:0:1} = "[" ] && ( [ $__lacks_closing_bracket -eq 1 ] || [ "${__input_without_leading_spaces:$((${#__input_without_leading_spaces} - 1)):1}" = "]" ] ) ; then

        __unwrapped_optional=$(drop_brackets "$1")
        __input_length=${#1}
        __unwrapped_length=${#__unwrapped_optional}
        __length_diff=$((__input_length - __unwrapped_length))

        if [ $__length_diff -eq 2 ] || ( [ $__lacks_closing_bracket -eq 1 ] && [ $__length_diff -eq 1 ] ); then
            echo 1
        elif [ $__length_diff -eq 0 ]; then # This outcome is impossible because earlier we've already checked that there are opening and closing square brackets in the string
            echo 0
        else
            echo "Incorrect brackets configuration"
            exit 1
        fi
   else
       echo 0
   fi
}

function drop_trailing_bracket {
    __input=$1

    if [ "${__input:$((${#__input} - 1)):1}" == "]" ]; then
        echo "${__item:0:$((${#item} - 1))}"
    else
        echo "$__input"
    fi
}

function compare_output_with_file {
    __command=$1 # command to execute
    __file=$2 # command containing reference text for comparison with the provided command output
    __tmp_file=${3:-'assets/test/__tmp.txt'}

    mkdir -p "$(echo $__tmp_file | rev | cut -d/ -f2- | rev)"

    eval "$__command" >> $__tmp_file

    if [ ! -z "$(diff $2 $__tmp_file)" ]; then
        echo "Output is different from expected"
        echo "Expected:"
        cat $2
        echo "Actual:"
        cat $__tmp_file
        rm $__tmp_file
        exit 1
    fi
    
    rm $__tmp_file 
}

