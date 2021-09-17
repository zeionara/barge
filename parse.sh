#!/bin/bash

source $BARGE_ROOT/string-utils.sh
source $BARGE_ROOT/handler-generators.sh
source $BARGE_ROOT/array-utils.sh

if [ -z "$BARGE_OPTIONS" ]; then
    echo "BARGE_OPTIONS env variable is not specified, please declare the list of supported arguments in format: '<foo-arg-short-name>|<foo-arg-full-name> <baz-arg-short-name>|<bar-arg-full-name>'"
    exit 1
fi

# Generate handlers from the option list
split_string "$BARGE_OPTIONS"

# Save the result returned from the splitting function into another array to not to lose it after the next split operation
copy_array __items parsed_options

# Generate option handlers and save them into an array
option_handlers=()
for (( j=0; j<${#parsed_options[@]}; j++ )); do
    split_string ${parsed_options[$j]} "|"
    option_handlers[$j]=$(generate_option_handler ${__items[1]} ${__items[0]})
done

# Join option handlers into a sting thus making an executable case block which will parse incoming arguments
copy_array option_handlers __items
handlers="case \"\${command_line_options[\$i]}\" in $(join_string) esac"

# Interpret passed command line arguments as an array of strings separated by space
command_line_options_=${1:-'-f foo -q bar -c qux'}
command_line_options=(${command_line_options_[@]})

# Execute the main loop of the arguments parsing
for (( i=0; i<${#command_line_options[@]}; i++ )); do
    eval $handlers
done

