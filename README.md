# Bunch of lua utility scripts, useful in almost any lua project
- [`illar.class_name.lua`](illarn/class_name.lua) - get string class name from a lua object
- [`illarn.deep_copy.lua`](illarn/deep_copy.lua)- create a deep copy of a lua table
- [`illarn.logger.lua`](illarn/logger.lua) - simple logger with terminal colors
- [`illarn.pool.lua`](illarn/pool.lua) - object pooling
- [`illarn.stringifier.lua`](illarn/stringifier.lua) - generate a readable representation of any lua object
- [`illarn.vararg_concat.lua`](illarn/vararg_concat.lua) - build a string without a table
- [`illarn.weak_reference.lua`](illarn/weak_reference.lua) - weak reference to a gc'able value with pass-through indexing and calling

All of the scripts were tested on lua 5.4.3 and luajit 2.1.1

## Installation
[Luarocks](https://luarocks.org/modules/illarn/illarn-utils)
```bash
luarocks install illarn-utils
```
