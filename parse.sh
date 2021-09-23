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
    is_optional_execution_result=$(is_optional "$joined_options")

    if [ $is_optional_execution_result -eq 1 ]; then
       __unwrapped_optional=$(drop_brackets "$joined_options")
       split_string "$__unwrapped_optional"

       current_option=${__items[0]}
       next_option=${__items[1]}
       is_optional_execution_result=1
    else
       is_optional_execution_result=0
    fi 
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

    unwrap_optional_and_set_flag
    
    split_string "$current_option" "|"
    if [ ${#__items[@]} -eq 2 ]; then
        if [ "$next_option" == "..." ]; then
            arg_keeper=$(as_constant_name ${__items[1]})
            unset $arg_keeper
            option_handlers[$j_]=$(generate_option_handler ${__items[1]} ${__items[0]} $arg_keeper)
            j_=$((j_ + 1))
            j=$((j + 1))
        else
            arg_keeper=$(as_constant_name ${__items[1]})
            export $arg_keeper=0
            option_handlers[$j_]=$(generate_flag_handler ${__items[1]} ${__items[0]} $arg_keeper)
            j_=$((j_ + 1))
        fi
        if [ $is_optional_execution_result -eq 0 ]; then
            required_options[$k]=$arg_keeper
            k=$((k + 1))
        fi
    elif [ ${#__items[@]} -eq 1 ]; then
        arg_keeper=$(as_constant_name ${parsed_options[j]})
        append "implicit_arg_keepers" "$arg_keeper"
        unset $arg_keeper
        if [ $is_optional_execution_result -eq 0 ]; then
            required_options[$k]=$arg_keeper
            k=$((k + 1))
        fi
    fi
done

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
    export ${implicit_arg_keepers[i]}="${implicit_arg_value}"
done

# Ensure that all required values were provided
for required_option_keeper in ${required_options[@]}; do
    exit_if_not_set "$required_option_keeper" "required option $required_option_keeper is not set, please add the respective value to the call"
done

