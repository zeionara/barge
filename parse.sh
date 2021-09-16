#!/bin/bash

function generate_option_handler {
    option_full_name=$1    
    option_short_name=$2 # TODO: Implement autogeneration
    option_value_holder=$(echo ${option_full_name^^} | tr - _)
handler=$(cat <<- END
    -$option_short_name|--$option_full_name)
        i=\$((i + 1));
        $option_value_holder="\${command_line_options[\$i]}"
        ;;
END
)
    echo $handler
}

foo_handler=$(generate_option_handler foo-bar f)
baz_handler=$(generate_option_handler baz-qux q)

handlers="case \"\${command_line_options[\$i]}\" in $foo_handler $baz_handler esac"
# handlers="case 1 in *); echo foo; ;; esac"
case foo in foo) echo foo ;; *) echo bar ;; esac
echo $handlers


# ok=$(cat <<- END
#     ok
#     ok
# END
# )

# echo $ok
# echo "$foo_handler" "$baz_handler"

command_line_options=(--foo-bar one --baz-qux two three)

# for i in "${command_line_options[@]}"; do
#     echo $i
# done
n_args=${#command_line_options[@]}
for (( i=0; i<${n_args}; i++ )); do
    # echo $i
    # i=$((i + 1))
    eval $handlers
done
echo $command_line_options

echo $FOO_BAR $BAZ_QUX

options="foo-bar=f baz-qux=q"
# options=((foo-bar, f), (baz-qux, q))
eval "parsed_options=(${options})"

for option in ${parsed_options[@]}; do
   echo $option
   # echo ${option[0]} ${option[1]}
done 
