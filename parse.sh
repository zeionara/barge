#!/bin/bash

# Cant use an explicit call to the procedure defined in other file because this file has not been imported yet
if [ -z $BARGE_ROOT ]; then
    echo "BARGE_ROOT env variable is not specified; please declare the path to the root folder of the cloned barge repository"
    exit 1 
fi

source $BARGE_ROOT/string-utils.sh
source $BARGE_ROOT/handler-generators.sh
source $BARGE_ROOT/array-utils.sh
source $BARGE_ROOT/error-utils.sh

exit_if_not_set "BARGE_OPTIONS" "please declare the list of supported arguments in format: '<foo-arg-short-name>|<foo-arg-full-name> <baz-arg-short-name>|<bar-arg-full-name>'" 

# foo=()

# append "foo" "foo"
# append "foo" "bar"

# echo ${foo[@]}

# Generate handlers from the option list
split_string "$BARGE_OPTIONS"

# Save the result returned from the splitting function into another array to not to lose it after the next split operation
copy_array __items parsed_options

# Generate option handlers and save them into an array
option_handlers=()
implicit_arg_keepers=()
j_=0
FOO_BAR=2
for (( j=0; j<${#parsed_options[@]}; j++ )); do
    current_option=${parsed_options[j]}
    next_option=${parsed_options[$((j + 1))]}

    # if [ "$next_option" == "garply" ] && [ ${#__items[@]} -eq 2 ]; then
    #     echo hey, it is garply!
    # fi
    # echo $next_option
    split_string "$current_option" "|"
    # if [ ${#__items[@]} -eq 2 ]; then
    if [ ${#__items[@]} -eq 2 ]; then
        if [ "$next_option" == "..." ]; then
            # echo $current_option $next_option
            arg_keeper=$(as_constant_name ${__items[1]})
            unset $arg_keeper
            option_handlers[$j_]=$(generate_option_handler ${__items[1]} ${__items[0]} $arg_keeper)
            j_=$((j_ + 1))
            j=$((j + 1))
        else
            # echo "handling flag"
            # PLUGH_XYYZY=12
            arg_keeper=$(as_constant_name ${__items[1]})
            export $arg_keeper=0
            option_handlers[$j_]=$(generate_flag_handler ${__items[1]} ${__items[0]} $arg_keeper)
            # echo $PLUGH_XYYZY
            j_=$((j_ + 1))
        fi
    elif [ ${#__items[@]} -eq 1 ]; then
        arg_keeper=$(as_constant_name ${parsed_options[j]}) # $(echo ${parsed_options[j]^^} | tr - _)
        append "implicit_arg_keepers" "$arg_keeper"
        unset $arg_keeper
        # echo ${implicit_arg_keepers[@]}
    fi
done

# Join option handlers into a sting thus making an executable case block which will parse incoming arguments
copy_array option_handlers __items
handlers="case \"\${command_line_options[i]}\" in $(join_string) *) append \"implicit_args\" \"\${command_line_options[i]}\" ;; esac"
# echo $handlers

# Interpret passed command line arguments as an array of strings separated by space
command_line_options_=${1:-'-f foo -q bar -c qux'}
command_line_options=(${command_line_options_[@]})

# Execute the main loop of the arguments parsing
implicit_args=() 
for (( i=0; i<${#command_line_options[@]}; i++ )); do
    eval $handlers
done
# echo ${implicit_args[@]}

# Assign implicit arg values to appropriate variables
for (( i=0; i<${#implicit_arg_keepers[@]}; i++ )); do
    eval "export ${implicit_arg_keepers[i]}=\"${implicit_args[i]}\""
done

