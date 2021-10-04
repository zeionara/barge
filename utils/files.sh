#!/bin/bash

function replace_option_descriptions_in_main {
    if test -f "_main.sh"; then
        rm _main.sh
    fi

    cp main.sh _main.sh
    descriptions_beginning_line_number=$(grep 'BARGE_OPTION_DESCRIPTIONS=( \\' -n main.sh | cut -d: -f1)
    descriptions_ending_line_number=$(tail -n "+$((descriptions_beginning_line_number + 1))" main.sh | grep ')' -n | head -n 1 | cut -d: -f1)
    descriptions_ending_line_number=$((descriptions_beginning_line_number + descriptions_ending_line_number))
    # echo $descriptions_ending_line_number
    # echo $descriptions_ending_line_number
    cat _main.sh | head -n $descriptions_beginning_line_number > main.sh
    
    for (( i=0; i<${#BARGE_OPTION_DESCRIPTIONS[@]}; i++ )); do
        description=${BARGE_OPTION_DESCRIPTIONS[$i]}
        echo "        '$description' \\" >> main.sh
    done
    tail -n "+$descriptions_ending_line_number" _main.sh >> main.sh
} 

function return_original_version_of_main {
    rm main.sh
    mv _main.sh main.sh
}
 
