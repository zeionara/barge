# Barge

Barge - **ba**sh **arg**um**e**nt parser - simple yet powerful tool for parsing arguments in bash scripts.

## Usage

The key script of the project at the time is contained in the file `parse.sh`, which specifies varible `option_list` containing all the available options in the following format:
- `<SHORT_NAME>|<FULL_NAME>` - for named options, where both names can be applied for the argument recognition. For instance, argument `corge-grault` can be defined as `c|corge-grault` meaning that value for this argument can be set using either format `-c foo` either `--corge-grault foo`. As a result of option list parsing, the option is written into a local env variable - for the example discussed above value `foo` will be put into env variable `CORGE_GRAULT`;
- `<FULL_NAME>` - for arguments, where the argument name reflects the env variable which will contain the argument parsing result. For instance, if you want to save the first argument passed via cli to your program under name `GARPLY`, you would specify this argument as `garply`.

For using the script you need to define two environment variables - one for setting up the cloned repo location and another for specifying the cli itself. Aside from that you are required to import the `parse.sh` script into your project as well. As a result, your file will look like example below.

```sh
#!/bin/bash

export BARGE_ROOT=$HOME/barge
export BARGE_OPTIONS="f|foo-bar c|corge-grault garply"
eval "source $BARGE_ROOT/parse.sh \"$@\""

echo "CORGE_GRAULT=$CORGE_GRAULT"
echo "FOO_BAR=$FOO_BAR"
echo "GARPLY=$GARPLY"
```

After all is set and done, you can use your script like this (passing values containing spaces is not supported at the moment, even with quotes):

```sh
./main.sh -c qux quux --foo-bar quuz
```

And considering the example under consideration, you will obtain the following output.

```sh
CORGE_GRAULT=qux
FOO_BAR=quuz
GARPLY=quux
```

