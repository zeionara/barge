#!/bin/bash

function generate_option_handler {
    # This function takes two parameters - then full name of the handled argument and the short name
    option_full_name=$1    
    option_short_name=$2 # TODO: Implement autogeneration

    # Generate variable name for the evironment variable hodling the parsed value and unset it
    option_value_holder=$(echo ${option_full_name^^} | tr - _)
    unset $option_value_holder

    # Generate option handler which can be used in the body of a case block (this chunk of code must not be reindented to avoid errors)
handler=$(cat <<- END
    -$option_short_name|--$option_full_name)
        i=\$((i + 1));
        export $option_value_holder="\${command_line_options[\$i]}"
        ;;
END
)

    # The generated handler is explicitly written as a result of the function execution
    echo $handler
}

