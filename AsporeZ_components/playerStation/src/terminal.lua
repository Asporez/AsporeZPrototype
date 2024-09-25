
local terminal = {
    input = "",
    output = "",
    active = false,
    commandHistory = {},
    aliases = {},
    computer = nil -- no computer is loaded initially
}

-- logic to load the computer module
function terminal.loadComputerModule()
    if not terminal.computer then
        local computer = require( 'src/computer' )
        terminal.computer = computer.new()
        terminal.output = "Computer module loaded."
    end
end

-- logic to unload computer module (clear conditions and remove reference)
function terminal.unloadComputerModule()
    if terminal.computer then
        terminal.computer:clearConditions()
        terminal.computer = nil
        terminal.output = "@cmp.error0x1" -- error code for generic unload
    end
end

terminal.commandList = {       
    "start.cell1",
    "stop.cell1",
    "start.cell2",
    "stop.cell2"
}

function terminal.addAlias(aliasName, command)
    terminal.aliases[aliasName] = command
    terminal.output = "Alias '"..aliasName.."' added for command: "..command
end

function terminal.listAliases()
    terminal.output = "Aliases Stored:\n"
    for aliasName, command in pairs(terminal.aliases) do
        terminal.output = terminal.output..aliasName.."->"..command.."\n"
    end
end

function terminal.processSingleCommand(command, serviceModule)
    local trimmedInput = command:match("^%s*(.-)%s*$")

    if terminal.aliases[command] then
        command = terminal.aliases[command]
    end

    if command == "start.cellA" then
     serviceModule.fuelCell1.running = true
        terminal.output = "Fuel Cell A Online."
    elseif command == "stop.cellA" then
     serviceModule.fuelCell1.running = false
        terminal.output = "Fuel Cell A Offline."
    elseif command == "start.cellB" then
     serviceModule.fuelCell2.running = true
        terminal.output = "Fuel Cell B Online."
    elseif command == "stop.cellB" then
     serviceModule.fuelCell2.running = false
        terminal.output = "Fuel Cell B Offline."
    

    -- logic for terminal input to load/unload computer module
    elseif command == "load@cmp" then
        terminal.loadComputerModule()
    elseif command == "unload@cmp" then
        terminal.unloadComputerModule()

    -- commands that work when computer module is loaded.
    elseif terminal.computer then
        if string.match( command, "start.cellA@cmp.temp.(%d+)" ) then
            local tempThreshold = tonumber( string.match( command, "start.cellA@cmp.temp.(%d+)" ) )
            terminal.computer:addCondition( 'fuelCell1', 'startCondition', function()
                return serviceModule.fuelCell1.temperature >= tempThreshold
            end )
            terminal.output = "FC.A Will start when temperature >="..tempThreshold

        elseif string.match( command, "stop.cellA@cmp.temp.(%d+)" ) then
            local tempThreshold = tonumber( string.match( command, "stop.cellA@cmp.temp.(%d+)" ) )
            terminal.computer:addCondition( 'fuelCell1', 'stopCondition', function()
                return serviceModule.fuelCell1.temperature <= tempThreshold
            end )
            terminal.output = "FC.A Will stop when temperature <="..tempThreshold
        
        elseif string.match( command, "start.cellB@cmp.temp.(%d+)" ) then
            local tempThreshold = tonumber( string.match( command, "start.cellB@cmp.temp.(%d+)" ) )
            terminal.computer:addCondition( 'fuelCell2', 'startCondition', function()
                return serviceModule.fuelCell2.temperature >= tempThreshold
            end )
            terminal.output = "FC.B Will start when temperature >="..tempThreshold

        elseif string.match( command, "stop.cellB@cmp.temp.(%d+)" ) then
            local tempThreshold = tonumber( string.match( command, "stop.cellB@cmp.temp.(%d+)" ) )
            terminal.computer:addCondition( 'fuelCell2', 'stopCondition', function()
                return serviceModule.fuelCell2.temperature <= tempThreshold
            end )
            terminal.output = "FC.A Will stop when temperature <="..tempThreshold
        end
    
    else
        terminal.output = "Unknown command: " .. trimmedInput
    end
end

function terminal.processCommand(command, serviceModule)
    local commands = {}
    for command in string.gmatch(command, "([^;]+)") do
        table.insert(commands, command:match("^%s*(.-)%s*$"))
    end

    for _, command in ipairs(commands) do
        terminal.processSingleCommand(command, serviceModule)
        table.insert(terminal.commandHistory, command)
        if #terminal.commandHistory > 9 then
            table.remove(terminal.commandHistory, 1)
        end
    end

    if string.sub(command, 1, 6) == "alias " then
        local aliasName, fullCommand = string.match(command, "^alias (%S+) (.+)$")
        if aliasName and fullCommand then
            terminal.addAlias(aliasName, fullCommand)
        elseif command == "alias list" then
            terminal.listAliases()
        else
            terminal.output = "Usage: alias <alias_name> <command>, alias list"
        end
        return
    end
end

return terminal
