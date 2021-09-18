# Barge

Barge - **ba**sh **arg**um**e**nt parser - simple yet powerful tool for parsing arguments in bash scripts.

## Usage

The key script of the project at the time is contained in the file `parse.sh`, which specifies varible `option_list` containing all the available options in the following format:
- `<SHORT_NAME>|<FULL_NAME> ...` - for named options, where both names can be applied for the argument recognition. For instance, argument `corge-grault` can be defined as `c|corge-grault` meaning that value for this argument can be set using either format `-c foo` either `--corge-grault foo`. As a result of option list parsing, the option is written into a local env variable - for the example discussed above value `foo` will be put into env variable `CORGE_GRAULT`;
- `<FULL_NAME>` - for arguments, where the argument name reflects the env variable which will contain the argument parsing result. For instance, if you want to save the first argument passed via cli to your program under name `GARPLY`, you would specify this argument as `garply`;
- `<SHORT_NAME>|<FULL_NAME>` - for flags, in which in case the option is presented in a call then appropriate env variable will accept the value of `1`; in the opposite circumstances it will be equal to `0`.

Aside from what is said earlier, every option can be put into square brackets (`[]`), which means that passing that option is not necessary in a program call. The options, arguments and flags, which are not declared inside square brackets are considered required and the script will be exited on attempts of invoking the `parse.sh` script without providing values for these parameters. The respective message will be written into the console so to allow user to understand what is wrong in their actions.

For using the script you need to define two environment variables - one for setting up the cloned repo location and another for specifying the cli itself. Besides you are required to import the `parse.sh` script into your project as well. As a result, your file will look like example below.

```sh
#!/bin/bash

export BARGE_ROOT=$HOME/barge
export BARGE_OPTIONS="[f|foo-bar ...] c|corge-grault ... garply [p|plugh-xyyzy]"

input_line=""
space_replacement="SPACE"

for arg; do
    arg_with_replaced_spaces="$(echo "$arg" | sed -E "s/\s/$space_replacement/g")"
    if [ "$input_line" == "" ]; then
        input_line="$arg_with_replaced_spaces"
    else
        input_line="$input_line $arg_with_replaced_spaces"
    fi
done

source $BARGE_ROOT/parse.sh "$input_line" "$space_replacement"

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

If we try to run this command, the user obtains a comprehensive message and the script immediately terminates which prevents further execution for avoiding unexpected errors because of missing values:

```sh
CORGE_GRAULT env variable is not specified; required option CORGE_GRAULT is not set, please add the respective value to the call
```

