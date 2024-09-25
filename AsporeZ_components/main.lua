--[[
This is where the text goes...
there was a lot of text here once but uhm...
I guess it wasn't good enough text to be here now.
--]]

local love = require 'love'

local serviceModule = require( 'src.serviceModule' )

local terminal = require( 'src.terminal' )

local computer = require 'src.computer'

function love.load()

    serviceModule.load()
    consoleFont = love.graphics.newFont( 'img/setbackt.ttf', 22 )
    love.graphics.setFont( consoleFont )
    
    serviceMonitors = love.graphics.newImage( 'img/fuelCellScreens_WIP.png' )
    fuelCellScreens = love.graphics.newImage( 'img/fuelCellScreens.png' )

    player = {

        x = 800,
        y = 450
    }
end

-- Variables to manage key repeat
local keyHeld = nil
local keyTimer = 0
local keyInterval = 0.1 -- 100ms   

local repeatableKeys = {
    backspace = true,
    -- Add more keys here
}

-- keyboard entry point inputs all text if terminal is active
function love.textinput(key)
    if terminal.active then terminal.input = terminal.input .. key end
end

-- keyboard input entry point
function love.keypressed(key)
    if terminal.active then
        if key == "return" then
            terminal.processCommand( terminal.input, serviceModule )
            terminal.input = ""
        elseif repeatableKeys[key] then
            -- Handle the repeatable key immediately
            if key == "backspace" then
                terminal.input = terminal.input:sub(1, -2)
            end
            -- Set the key as held for repeating
            keyHeld = key
            keyTimer = 0
        elseif key == "escape" then
            terminal.active = false
        end
    elseif key == key then
        terminal.active = true
    end
end

function love.keyreleased(key)
    if key == keyHeld then
        keyHeld = nil
        keyTimer = 0
    end
end

function love.update(dt)

    if terminal.computer then
        terminal.computer:evaluateConditions(serviceModule)
    end

    -- Update fuel cells
    serviceModule.update(dt)
    if terminal.computer then
        terminal.computer:evaluateConditions( serviceModule )
    end

    -- Update displays
    powerDisplay1 = math.floor( serviceModule.fuelCell1.stored )
    powerDisplay2 = math.floor( serviceModule.fuelCell2.stored )
    batteryDisplay = math.ceil( serviceModule.battery.stored )
    batteryPercentageDisplay = math.floor( ( serviceModule.battery.stored / serviceModule.battery.maxStored ) * 100 )

    if keyHeld and repeatableKeys[keyHeld] then
        keyTimer = keyTimer + dt
        if keyTimer >= keyInterval then
            if keyHeld == "backspace" then
                terminal.input = terminal.input:sub(1, -2) -- delete a character
            end
            -- Reset the timer to repeat the key action
            keyTimer = 0
        end
    end

    -- Player movement
    if love.keyboard.isDown( 'right' ) then
        player.x = player.x + 200 * dt
    end

    if love.keyboard.isDown( 'left' ) then
        player.x = player.x - 200 * dt
    end

    if love.keyboard.isDown( 'up' ) then
        player.y = player.y - 200 * dt
    end

    if love.keyboard.isDown( 'down' ) then
        player.y = player.y + 200 * dt
    end

end

-- use this to change the position of this screen
local sMod_X = 0
local sMod_Y = 0

local fuelCellScreens_X = sMod_X + 20
local fuelCellScreens_Y = sMod_Y + 32

local screenA_X = fuelCellScreens_X + 6
local screenA_Y = fuelCellScreens_Y + 3

local screenB_X = fuelCellScreens_X + 6
local screenB_Y = fuelCellScreens_Y + 70

local screenC_X = fuelCellScreens_X + 262
local screenC_Y = fuelCellScreens_Y + 5

local textColor = {
    lightMonokai = { 117/255, 113/255, 94/255 },
    darkMonokai = { 39/255, 40/255, 32/255 },
}

local terminalWidth = 374                      -- Width of the terminal window 
local terminalHeight = 246                     -- Height of the terminal window
local inputScrollOffset = screenC_X            -- Horizontal scroll for terminal input
local outputScrollOffset = screenC_X + 374     -- Horizontal scroll for terminal output
local historyScrollOffsets = {}                -- Horizontal scroll for each command in command history

function love.draw()
    love.graphics.clear( 0, 0, 0 )

    love.graphics.draw( serviceMonitors, sMod_X, sMod_Y )
    love.graphics.draw( fuelCellScreens, fuelCellScreens_X, fuelCellScreens_Y )

    love.graphics.setColor( textColor.darkMonokai )
    -- draw display for both fuel cells
    love.graphics.print( "CELL.A.STATUS."..string.format( "%.2f", powerDisplay1 ).."%", screenA_X, screenA_Y )
    love.graphics.print( "CELL.B.STATUS."..string.format( "%.2f", powerDisplay2 ).."%", screenA_X, screenA_Y + 32 )
    -- draw display for battery
    love.graphics.print( "BATT."..batteryDisplay..".ah", screenB_X, screenB_Y )
    love.graphics.print( "."..batteryPercentageDisplay.."%", screenB_X + 190, screenB_Y )
    -- print temp value
    love.graphics.printf( "A.H2."..string.format( "%.2f", serviceModule.fuelCell1.fuelAmount )..".kg", screenB_X, screenB_Y + 22, 251 )
    love.graphics.printf( "TEMP."..string.format( "%.2f", serviceModule.fuelCell1.temperature )..".K", screenB_X, screenB_Y + 44, 251 )
    love.graphics.printf( "FUEL."..string.format( "%.2f", serviceModule.fuelCell2.fuelAmount )..".kg", screenB_X, screenB_Y + 66, 251 )
    love.graphics.printf( "TEMP."..string.format( "%.2f", serviceModule.fuelCell2.temperature )..".K", screenB_X, screenB_Y + 88, 251 )

    local font = love.graphics.getFont()

    -- Set scissor for the terminal area (only draw within this rectangle)
    love.graphics.setScissor( screenC_X, screenC_Y, terminalWidth, terminalHeight )

    -- Terminal input: scroll if it exceeds terminalWidth
    local inputWidth = font:getWidth( terminal.input )
    if inputWidth > terminalWidth then
        inputScrollOffset = inputWidth - terminalWidth
    else
        inputScrollOffset = 0
    end

    if terminal.active then
        love.graphics.print( ">"..terminal.input, screenC_X - inputScrollOffset, screenC_Y )
    end

    -- Terminal output: scroll if it exceeds terminalWidth
    if terminal.output ~= "" then
        local outputWidth = font:getWidth( ">" .. terminal.output )
        if outputWidth > terminalWidth then
            outputScrollOffset = outputWidth - terminalWidth
        else
            outputScrollOffset = 0
        end
        love.graphics.print( ">" .. terminal.output, screenC_X - outputScrollOffset, screenC_Y + 22 )
    end

    -- Command history: scroll each command separately
    for i, command in ipairs( terminal.commandHistory ) do
        local historyWidth = font:getWidth( ">" .. command )
        if historyWidth > terminalWidth then
            historyScrollOffsets[i] = historyWidth - terminalWidth
        else
            historyScrollOffsets[i] = 0
        end
        love.graphics.print( ">" .. command, screenC_X - ( historyScrollOffsets[i] or 0 ), screenC_Y + 22 * ( i + 1 ) )
    end

    -- Reset scissor (remove clipping area after terminal is drawn)
    love.graphics.setScissor()

    -- reset color
    love.graphics.setColor( 1, 1, 1 )
    love.graphics.rectangle( 'line', player.x, player.y, 200, 150 )
end