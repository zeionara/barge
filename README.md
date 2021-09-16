# Barge

Barge - **ba**sh **arg**um**e**nt parser - simple yet powerful tool for parsing arguments in bash scripts.

## Usage

The key script of the project at the time is contained in the file `parse.sh`, which specifies varible `option_list` containing all the available options in the format `<SHORT_NAME>|<FULL_NAME>` where both names can be applied for the argument recognition. For instance, argument `corge-grault` can be defined as `c|corge-grault` meaning that value for this argument can be set using either format `-c foo` either `--corge-grault foo`. As a result of option list parsing, the option is written into a local env variable - for the example discussed above value `foo` will be put into env variable `CORGE_GRAULT`. For this functionality to work you need to include the script into your program using following statement:

```sh
source ./parse.sh "-c foo"
``` 

Alternatively, if you want to pass through the parser all arguments that are coming to your app, you can insert another statement to the beginning of your code:

```sh
eval "source ./parse.sh \"$@\""
```
 
