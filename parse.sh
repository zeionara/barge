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

    # Function exection result is saved into the __items variable
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

