## AsporeZ Prototype

This is my first prototype and attempt to escape tutorial hell.

### Starter Tip

**_this is how a main.lua file is built with Love2D:_**

```Lua
local love = require 'love' -- my number one reason to have chosen Love2D

function love.load()
end

function love.update(dt)
end

function love.draw()
end
```
a modular function or an OOP oriented class works the same but change "love" for the class name and export it to your main file like this:

```Lua
local love = require 'love' -- my number one reason to have chosen Love2D

function love.load()
  class.load()
end

function love.update(dt)
  class.update(dt)
end

function love.draw()
  class.draw()
end
```
