local love = require "love"
local button = require "data/src/button"

local cursor = {
    radius = 10,
    x = 15,
    y = 15
}

local game = { -- use "game.state['state']" in the code to switch functionality between game states. add any new game state here
    state = {
        menu = true,
        settings = false, -- does nothing
        paused = false, -- does nothing
        inventory = false, -- does nothing
        utility = false, -- does nothing
        character = false, -- does nothing
        running = false,
        ended = false,
    }
}

local buttons ={
    menu_state = {}
}

local function startNewGame() -- determines what happens when the Play Game button is pressed
    game.state[ 'menu' ] = false
    game.state[ 'running' ] = true
end

function love.load()
    camera = require( 'lib/camera' ) -- call for camera plugin.
    camObj = camera() -- create camera object.

    anim8 = require 'lib/anim8' -- call for anim8 plugin
    love.graphics.setDefaultFilter( "nearest", "nearest" ) -- set graphics module to scale pixels without vsync.

    sti = require 'lib/sti' -- call the Simple Tiled Implementatiomn plugin to draw maps made with Tiled.
    gameMap = sti( 'data/maps/100x100island.lua' ) -- call in the map file.

    buttons.menu_state.play_game = button( "Play Game", startNewGame, nil, 120, 40 ) -- calls in startNewGame function.
    buttons.menu_state.settings = button( "Settings", nil, nil, 120, 40 )
    buttons.menu_state.exit_game = button( "Exit", love.event.quit, nil, 120, 40 ) -- calls for program to stop.

    player = {} -- player table.
    player.x = 3200
    player.y = 1600
    player.speed = 3
    player.spriteSheet = love.graphics.newImage( 'data/sprites/entities/playerSheet.png' )
    player.grid = anim8.newGrid( 12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )

    player.animations = {} -- animations table.
    player.animations.down = anim8.newAnimation( player.grid( '1-4', 1 ), 0.25 )
    player.animations.left = anim8.newAnimation( player.grid( '1-4', 2 ), 0.25 )
    player.animations.right = anim8.newAnimation( player.grid( '1-4', 3 ), 0.25 )
    player.animations.up = anim8.newAnimation( player.grid( '1-4', 4 ), 0.25 )

    player.anim = player.animations.down

    splash = love.graphics.newImage( 'data/sprites/splash/splash00.png' ) -- default background splash, not being used

    function love.mousepressed(x, y, button, istouch, presses) -- registers any mouse button as long as the cursor is hovering a button.
        if not game.state[ 'running' ] then
            if button == 1 then
                if game.state[ 'menu' ] then -- registers mouse while in menu state
                    for index in pairs( buttons.menu_state ) do
                        buttons.menu_state[ index ]:checkPressed( x, y, cursor.radius )
                    end
                end
            end
            
        end
    
    end
end

function love.update(dt)
    cursor.x, cursor.y = love.mouse.getPosition() -- register the location of mouse cursor
    love.mouse.setVisible( false ) -- set visibility of mouse cursor

    local isMoving = false -- starts player movement sequence.

    if love.keyboard.isDown( "escape" ) then -- changes game state to menu if escape is pressed.
        game.state[ 'menu' ] = true
        game.state[ 'running' ] = false
    end

    if love.keyboard.isDown( "right" ) then  -- I have to move this to its own file, for now this is the input handler.
        player.x = player.x + player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    if love.keyboard.isDown( "left" ) then
        player.x = player.x - player.speed
        player.anim = player.animations.left
        isMoving = true
    end

    if love.keyboard.isDown( "up" ) then
        player.y = player.y - player.speed
        player.anim = player.animations.up
        isMoving = true
    end

    if love.keyboard.isDown( "down" ) then
        player.y = player.y + player.speed
        player.anim = player.animations.down
        isMoving = true
    end

    if isMoving == false then
        player.anim:gotoFrame( 2 ) -- not totally certain of what I did there, I think it loops to the stored local variable.
    end

    player.anim:update(dt) -- call in the animation to update once input handlers and through

    camObj:lookAt( player.x, player.y ) -- keep camera centered on player

end

function love.draw()    
    love.graphics.printf( "FPS: " .. love.timer.getFPS(), love.graphics.newFont( 16 ), 10, love.graphics.getHeight() - 30, love.graphics.getWidth() ) --prints FPS count in top left corner
    
    if game.state[ "running" ] then
        camObj:attach() -- call for camera to follow player, below is the body of the main scene that will follow the camera.
            gameMap:drawLayer( gameMap.layers[ 'groundHeight0' ] ) -- draw layers from STI/Tiled map, use this to add new layers.
            gameMap:drawLayer( gameMap.layers[ 'groundHeight1' ] )
            player.anim:draw( player.spriteSheet, player.x, player.y, nil, 3, nil, 6, 9 ) -- center on player's grid (last 2 digits adjusts position on the player's grid)
        camObj:detach()
    elseif game.state[ "menu" ] then
        buttons.menu_state.play_game:draw( 20, 20, 20, 10 ) -- draw the button stored above load. Use this to draw new buttons.
        buttons.menu_state.settings:draw( 20, 70, 20, 10 )
        buttons.menu_state.exit_game:draw( 20, 120, 20, 10 )
    end

    if not game.state[ "running" ] then
        love.graphics.circle( "fill", cursor.x, cursor.y, cursor.radius ) -- Draw the mouse cursor while game state is not running, on one of the menus.
    end
end