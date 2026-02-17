# Bunch of lua utility scripts, useful in almost any lua project
- [`class_name.lua`](class_name.lua) - get string class name from a lua object
- [`deep_copy.lua`](deep_copy.lua)- create a deep copy of a lua table
- [`logger.lua`](logger.lua) - simple logger with terminal colors
- [`pool.lua`](pool.lua) - object pooling
- [`stringifier.lua`](stringifier.lua) - generate a readable representation of any lua object
- [`vararg_concat.lua`](vararg_concat.lua) - build a string without a table
- [`weak_reference.lua`](weak_reference.lua) - weak reference to a gc'able value with pass-through indexing and calling

All of the scripts were tested on lua 5.4.3 and luajit 2.1.1

## Installation
[Luarocks](https://luarocks.org/modules/illarn/illarn-utils)
```bash
luarocks install illarn-tween
```
