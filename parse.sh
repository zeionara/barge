#!/bin/bash

# Cant use an explicit call to the procedure defined in other file because this file has not been imported yet
if [ -z $BARGE_ROOT ]; then
    echo "BARGE_ROOT env variable is not specified; please declare the path to the root folder of the cloned barge repository"
    exit 1 
fi

source $BARGE_ROOT/utils/string.sh
source $BARGE_ROOT/handler-generators.sh
source $BARGE_ROOT/utils/array.sh
source $BARGE_ROOT/utils/errors.sh

exit_if_not_set "BARGE_OPTIONS" "please declare the list of supported arguments in format: '<foo-arg-short-name>|<foo-arg-full-name> <baz-arg-short-name>|<bar-arg-full-name>'" 

# Generate handlers from the option list
split_string "$BARGE_OPTIONS"

# Save the result returned from the splitting function into another array to not to lose it after the next split operation
copy_array __items parsed_options

function unwrap_optional_and_set_flag {
    joined_options="$current_option $next_option"
    if [ -z "$__dropped_trailing_bracket" ]; then
        __dropped_trailing_bracket=0
    fi
    is_optional_execution_result=$(is_optional "$joined_options" $__dropped_trailing_bracket)

    # echo $__dropped_trailing_bracket
    # echo "Check optional $joined_options"
    if [ $is_optional_execution_result -eq 1 ]; then
       __unwrapped_optional=$(drop_brackets "$joined_options")
       split_string "$__unwrapped_optional"

       current_option=${__items[0]}
       # echo "CURR $current_option"
       next_option=${__items[1]}
       is_optional_execution_result=1
    else
       is_optional_execution_result=0
    fi 
}

function fetch_default_argument {
    __array_name=$2
    eval "__array_length=\${#$__array_name[@]}"
    __default_argument=""

    __passed_first_item='' 
    __dropped_trailing_bracket=''
    __n_joined_strings=0
    for (( __j=$1; __j<$__array_length; __j++ )); do
        eval "__item=\${$__array_name[$__j]}"
        # echo "FETCHING $__item"
        __n_joined_strings=$((__n_joined_strings + 1))
        
        if [ "${__item:0:1}" == "'" ]; then
            if [ -z $__passed_first_item ]; then
                __passed_first_item='yes'
            fi
            # echo "multipart"
            __item_without_trailing_bracket="$(drop_trailing_bracket $__item)"
            if [ $__item != $__item_without_trailing_bracket ]; then
                __dropped_trailing_bracket=1
            fi
            __default_argument="$__item_without_trailing_bracket"
        elif [ -z $__passed_first_item ]; then
            # echo "non-multipart"
            __item_without_trailing_bracket="$(drop_trailing_bracket $__item)"
            if [ $__item != $__item_without_trailing_bracket ]; then
                __dropped_trailing_bracket=1
            fi
            __default_argument="$__item_without_trailing_bracket"
            break
        else
            # if [ "${__item:$((${#__item} - 1)):1}" == "]" ]; then
            #     __default_argument="$__default_argument ${__item:0:$((${#item} - 1))}"
            # else
            #     __default_argument="$__default_argument $__item"
            # fi
            __item_without_trailing_bracket="$(drop_trailing_bracket $__item)"
            if [ $__item != $__item_without_trailing_bracket ]; then
                __dropped_trailing_bracket=1
            fi
            __default_argument="$__default_argument $__item_without_trailing_bracket"
        fi

        if [ ${__default_argument:$((${#__default_argument} - 1)):1} == "'" ]; then
            break
        fi
    done
    # echo $__default_argument
}

# Generate option handlers and save them into an array
option_handlers=()
implicit_arg_keepers=()
j_=0 # Index for current option handler
required_options=()
k=0 # Index for current required option keeper (env variable name which later can be checked for emptiness)
for (( j=0; j<${#parsed_options[@]}; j++ )); do
    current_option=${parsed_options[j]}
    next_option=${parsed_options[$((j + 1))]}
    following_option=${parsed_options[$((j + 2))]}
    __default_argument=''
    # echo $current_option

    # echo ">$following_option<"
    if [ "${next_option:0:1}" != "[" ] && [ "$following_option" == "=" ]; then
        fetch_default_argument $((j + 3)) 'parsed_options'
        # echo "next before = $next_option"
        # echo "default argument = $__default_argument"
    fi

    if [ "$next_option" == "=" ]; then
        fetch_default_argument $((j + 2)) 'parsed_options'
        # echo "default argument = $__default_argument"
    fi

    # echo $current_option $next_option
    # echo $following_option
    # echo $__n_joined_strings
    # echo $__dropped_trailing_bracket

    unwrap_optional_and_set_flag
    # echo $is_optional_execution_result
    # exit 1
    
    # echo "SPLT $current_option"
    split_string "$current_option" "|"
    if [ ${#__items[@]} -eq 2 ]; then
        if [ "$next_option" == "..." ]; then
            arg_keeper=$(as_constant_name ${__items[1]})
            if [ ! -z "$__default_argument" ]; then
                eval "export $arg_keeper=$__default_argument"
            else
                unset $arg_keeper
            fi
            # echo $FOO_BAR
            # echo $__default_argument
            option_handlers[$j_]=$(generate_option_handler ${__items[1]} ${__items[0]} $arg_keeper)
            j_=$((j_ + 1))
            j=$((j + 1))
        else
            arg_keeper=$(as_constant_name ${__items[1]})
            # echo $__default_argument
            if [ ! -z "$__default_argument" ]; then
                eval "export $arg_keeper=$__default_argument"
            else
                export $arg_keeper=0
                # unset $arg_keeper
            fi
            # export $arg_keeper=0
            option_handlers[$j_]=$(generate_flag_handler ${__items[1]} ${__items[0]} $arg_keeper)
            j_=$((j_ + 1))
        fi
        if [ $is_optional_execution_result -eq 0 ]; then
            required_options[$k]=$arg_keeper
            k=$((k + 1))
        fi
    elif [ ${#__items[@]} -eq 1 ]; then
        arg_keeper=$(as_constant_name $current_option)
        # echo "DEF $__default_argument"
        append "implicit_arg_keepers" "$arg_keeper"
        if [ ! -z "$__default_argument" ]; then
            eval "export $arg_keeper=$__default_argument"
        else
            unset $arg_keeper
        fi
        # echo $GARPLY
        # unset $arg_keeper
        if [ $is_optional_execution_result -eq 0 ]; then
            required_options[$k]=$arg_keeper
            k=$((k + 1))
        fi
    fi

    if [ "${next_option:0:1}" != "[" ] && [ "$following_option" == "=" ]; then
        j=$((j + $__n_joined_strings + 1))
    fi

    if [ "$next_option" == "=" ]; then
        j=$((j + $__n_joined_strings + 1))
    fi
done
# echo "GPL=$GARPLY"
# Join option handlers into a sting thus making an executable case block which will parse incoming arguments
copy_array option_handlers __items
handlers="case \"\${command_line_options[i]}\" in $(join_string) *) append \"implicit_args\" \"\${command_line_options[i]}\" ;; esac"

# Interpret passed command line arguments as an array of strings separated by space
command_line_options_=$1
space_replacement=$2
command_line_options=(${command_line_options_[@]})
if [ ! -z $space_replacement ]; then
    for (( i=0; i<${#command_line_options[@]}; i++ )); do
        command_line_options[$i]="$(echo "${command_line_options[i]}" | sed "s/$space_replacement/ /g")"
    done
fi

# Execute the main loop of the arguments parsing
implicit_args=() 
for (( i=0; i<${#command_line_options[@]}; i++ )); do
    eval $handlers
done

# Assign implicit arg values to appropriate variables
for (( i=0; i<${#implicit_arg_keepers[@]}; i++ )); do
    implicit_arg_value="${implicit_args[i]}"
    exit_if "[ \"${implicit_arg_value:0:1}\" == "-" ]" "Unknown option $implicit_arg_value"
    if [ ! -z "$implicit_arg_value" ]; then
        # echo "============================="
        export ${implicit_arg_keepers[i]}="${implicit_arg_value}"
    fi
done
# echo "GAPL=$GARPLY"

# Ensure that all required values were provided
for required_option_keeper in ${required_options[@]}; do
    exit_if_not_set "$required_option_keeper" "required option $required_option_keeper is not set, please add the respective value to the call"
done

