# AsporeZ Prototype

This is my first prototype and attempt to escape tutorial hell.
Please use this if it sems useful to you, there are a few useful methods being used and interacting to iterate on.
For anyone who wants a starting point or just learn about basic Lua methods implemented in Love2D.

## **CONTENT**

* player class
* player stickman placeholder with quad and animations
* game state class and two methods to switch between them with keyboard and mouse
* OOP button class to handle mouse input methods
* basic menu example that uses all of the stored methods
* a full set of isometric tiles and some props to use

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
