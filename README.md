# Barge

Barge - **ba**sh **arg**um**e**nt parser - simple yet powerful tool for parsing arguments in bash scripts.

## Usage

The key script of the project at the time is contained in the file `parse.sh`, which uses the variable `BARGE_OPTIONS`` containing all the available command-line option specifications in the following format:
- `<SHORT_NAME>|<FULL_NAME> ... = <DEFAULT_VALUE>` - for named options, where both names can be applied for the argument recognition. For instance, argument `corge-grault` can be defined as `c|corge-grault` meaning that value for this argument can be set using either format `-c foo` either `--corge-grault foo`. As a result of option list parsing, the option is written into a local env variable - for the example discussed above value `foo` will be put into env variable `CORGE_GRAULT`; if no value is provided by the caller, the respective environment variable will be filled with the default value if it is provided - in other case it will just not be assigned with any value;
- `<FULL_NAME> = <DEFAULT_VALUE>` - for arguments, where the argument name reflects the env variable which will contain the argument parsing result. For instance, if you want to save the first argument passed via cli to your program under name `GARPLY`, you would specify this argument as `garply`; the default-value semantics is similar to that of the named options;
- `<SHORT_NAME>|<FULL_NAME> = <VALUE_IF_SET>|<VALUE_IF_NOT_SET>` - for flags, in which in case the option is presented in a call then appropriate env variable will accept the value of `1`; in the opposite circumstances it will be equal to `0`. If default value is provided without symbol `|` then in case the option is set by the caller, the env variable will accept the given default value. If the default value consists of two parts separated by the character `|`, then if flag is set in the script call, part of default value coming before the separator will be stored as the env variable content; if the flag is not set, the part of string after the vertical line will be set up as the env variable value.

There is one default flag which is predefined and thus forbidden for the custom options specification. The flag is `-h|--help` which makes the program print help message. The printed help message may be customized via env variables `BARGE_DESCRIPTION` and `BARGE_OPTION_DESCRIPTIONS`. The former contains the text which provides an explanaiton of the whole script, and the latter contains a list of strings each of which describes an available command-line argument. Both env variables are optional and in case they are not provided, the default values are generated (concerning `BARGE_OPTION_DESCRIPTIONS` env variable, empty list is used by default because since it's not clear which format of argument description one would prefer). 

Aside from what is said earlier, every option can be put into square brackets (`[]`), which means that passing that option is not necessary in a program call. The options, arguments and flags, which are not declared inside square brackets are considered required and the script will be exited on attempts of invoking the `parse.sh` script without providing values for these parameters. The respective message will be written into the console so to allow user to understand what is wrong in their actions.

For using the script you need to define two environment variables - one for setting up the cloned repo location and another for specifying the cli itself. Besides you are required to import the `parse.sh` script into your project as well. As a result, your file will look like example below.

```sh
#!/bin/bash

export BARGE_ROOT=$HOME/barge
export BARGE_OPTIONS="[f|foo-bar ...] c|corge-grault ... garply [p|plugh-xyyzy]"

space_replacement="<<SPACE>>"

if [ -z $space_replacement ]; then
    eval "source $BARGE_ROOT/parse.sh \"$@\""
else
    input_line=""

    for arg; do
        arg_with_replaced_spaces="$(echo "$arg" | sed -E "s/\s/$space_replacement/g")"
        if [ "$input_line" == "" ]; then
            input_line="$arg_with_replaced_spaces"
        else
            input_line="$input_line $arg_with_replaced_spaces"
        fi
    done

    source $BARGE_ROOT/parse.sh "$input_line" "$space_replacement"
fi

echo "CORGE_GRAULT='$CORGE_GRAULT'"
echo "FOO_BAR='$FOO_BAR'"
echo "GARPLY='$GARPLY'"
echo "PLUGH_XYYZY='$PLUGH_XYYZY'"
```

Notice that in this script there is a considerable amount of code before sourcing the parsing script itself, which performs some preprocessing work on the input arguments. This work is required for allowing user to pass values which may contain spaces. Thus, here we are replacing all the space characters with a special string which is then passed to the `parse.sh` script so it is able to figure out which spaces were replaced. This preprocessing step is not required and you can skip it if you want to - then just pass one argument to the parsing script containing all command line options as in the example below. 

```sh
#!/bin/bash

export BARGE_ROOT=$HOME/barge
export BARGE_OPTIONS="f|foo-bar c|corge-grault garply"
eval "source $BARGE_ROOT/parse.sh \"$@\""

echo "CORGE_GRAULT=$CORGE_GRAULT"
echo "FOO_BAR=$FOO_BAR"
echo "GARPLY=$GARPLY"
```

After all is set and done, you can use your script like this:

```sh
./main.sh -c qux -p quux --foo-bar 'qu ux     '
```

And taking the example given above (the first one), you will obtain the following output:

```sh
CORGE_GRAULT='qux'
FOO_BAR='qu ux     '
GARPLY='quux'
PLUGH_XYYZY='1'
```

For completeness, let's see what happens if we pass the wrong set of attributes to the script - we will omit the `-c` option so updated command will look like the following call:

```sh
./main.sh -p quux --foo-bar `qu ux     `
```

If we try to run this command, we will obtain a comprehensive message and the script will immediately terminate which prevents further execution for avoiding unexpected errors because of missing values:

```sh
CORGE_GRAULT env variable is not specified; required option CORGE_GRAULT is not set, please add the respective value to the call
```

## Testing

To run tests for making sure that everything works fine, execute script `test.sh` located at the repository root. The result of correct tests execution must contain a total number of passed tests.

