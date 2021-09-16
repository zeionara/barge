#!/bin/bash

function split_string {
    __separator=${2:-" "}
    __splittable_string=$1
    # echo splittable
    # echo $__splittable_string
    if [ "$__separator" != " " ]; then
        __splittable_string=$(echo $__splittable_string | sed "s/ /SPACE/g" | sed "s/$__separator/ /g")
    fi
    __items=(${__splittable_string[@]})
    __n_items=${#__items[@]}
    if [ "$__separator" != " " ]; then
        for (( i=0; i<${__n_items}; i++ )); do
            __items[$i]=$(echo ${__items[$i]} | sed "s/SPACE/ /g")
        done
    fi
    # eval "__splitted_string=($1)"
    # echo $__splitted_string 
    # echo $1
}

function join_string {
    __joined_string=""
    # __items=$1
    # echo ${__items[@]}
    __n_items=${#__items[@]}
    __separator=${1:-" "}
    for (( i=0; i<${__n_items}; i++ )); do
        __item=${__items[i]}
        # echo $__item
        if [ $i -ne 0 ]; then
            __joined_string="$__joined_string$__separator$__item"
        else
            __joined_string="$__item"
        fi
    done
    echo $__joined_string
}

function generate_option_handler {
    option_full_name=$1    
    option_short_name=$2 # TODO: Implement autogeneration
    option_value_holder=$(echo ${option_full_name^^} | tr - _)
handler=$(cat <<- END
    -$option_short_name|--$option_full_name)
        i=\$((i + 1));
        unset $option_value_holder;
        export $option_value_holder="\${command_line_options[\$i]}"
        ;;
END
)
    echo $handler
}

foo_handler=$(generate_option_handler foo-bar f)
baz_handler=$(generate_option_handler baz-qux q)

handlers="case \"\${command_line_options[\$i]}\" in $foo_handler $baz_handler esac"

command_line_options=(--foo-bar one --baz-qux two three)

n_args=${#command_line_options[@]}
for (( i=0; i<${n_args}; i++ )); do
    eval $handlers
done
# echo $command_line_options

# echo $FOO_BAR $BAZ_QUX

options="foo-bar=f baz-qux=q"
# options=((foo-bar, f), (baz-qux, q))
eval "parsed_options=(${options})"

# for option in ${parsed_options[@]}; do
   # echo $option
   # echo ${option[0]} ${option[1]}
# done 

# echo $(split_string "foo bar")
# splittable_string="ffoo bar baz"
# split_string "foo-foo bar-bar baz-baz" "-"
# itemss=$__items
# echo "${itemss[@]}"
# echo "${#__items[@]}"
# eval "__items=($(split_string '$splittable_string'))"
# echo "${__items[@]}"
# echo $(join_string "${splitted_string[@]}") 
option_list="f|foo-bar q|baz-qux c|corge-grault"
split_string "$option_list"
# echo splitted
# echo "${__items[@]}"
parsed_options=()
# j=0
# echo "${#__items[@]}"
for (( i=0; i<${#__items[@]}; i++ )); do
    parsed_options[$i]=${__items[$i]}
done

option_handlers=()
for (( j=0; j<${#parsed_options[@]}; j++ )); do
    # echo $i
    # echo ssssss
    split_string ${parsed_options[$j]} "|"
    # echo $__items
    option_handlers[$j]=$(generate_option_handler ${__items[1]} ${__items[0]})
    # echo ${parsed_options[$i]}
done
# echo $option_handlers

__items=()
for (( i=0; i<${#option_handlers[@]}; i++ )); do
    __items[$i]=${option_handlers[$i]}
done

command_line_options_=${1:-'-f foo -q bar -c qux'}
command_line_options=(${command_line_options_[@]})
# echo $2
# echo ppppp
# echo ${command_line_options[@]}
handlers="case \"\${command_line_options[\$i]}\" in $(join_string) esac"
# echo $handlers
for (( i=0; i<${#command_line_options[@]}; i++ )); do
    # echo $i
    # echo ${command_line_options[$i]}
    eval $handlers
    # echo $CORGE_GRAULT
    # echo $i
done
