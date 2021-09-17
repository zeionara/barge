#!/bin/bash

source $BARGE_ROOT/string-utils.sh
source $BARGE_ROOT/handler-generators.sh

# Generate handlers from the option list
option_list="f|foo-bar q|baz-qux c|corge-grault"
split_string "$option_list"

# Save the result returned from the splitting function into another array to not to lose it after the next split operation
parsed_options=()
for (( i=0; i<${#__items[@]}; i++ )); do
    parsed_options[$i]=${__items[i]}
done

# Generate option handlers and save them into an array
option_handlers=()
for (( j=0; j<${#parsed_options[@]}; j++ )); do
    split_string ${parsed_options[$j]} "|"
    option_handlers[$j]=$(generate_option_handler ${__items[1]} ${__items[0]})
done

# Join option handlers into a sting thus making an executable case block which will parse incoming arguments
__items=()
for (( i=0; i<${#option_handlers[@]}; i++ )); do
    __items[$i]=${option_handlers[$i]}
done
handlers="case \"\${command_line_options[\$i]}\" in $(join_string) esac"

# Interpret passed command line arguments as an array of strings separated by space
command_line_options_=${1:-'-f foo -q bar -c qux'}
command_line_options=(${command_line_options_[@]})

# Execute the main loop of the arguments parsing
for (( i=0; i<${#command_line_options[@]}; i++ )); do
    eval $handlers
done

