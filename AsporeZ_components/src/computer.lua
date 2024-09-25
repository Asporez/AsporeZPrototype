local computer = {}
computer.__index = computer

function computer.new()
    local self = setmetatable( {}, computer )
    self.conditions = {} -- stores conditions (fuelcells)
    return self
end

-- condition for a fuel cell
function computer:addCondition( cell, conditionType, conditionFunc )
    self.conditions[cell] = self.conditions[cell] or {}
    if not self.conditions[cell] then
        self.conditions[cell] = {}
    end
    self.conditions[cell][conditionType] = conditionFunc
end

-- logic for the start/stop conditions
function computer:evaluateConditions( serviceModule )
    for cellName, conditionSet in pairs(self.conditions) do
        local cell = serviceModule[cellName]

        if conditionSet.startCondition and not cell.running then
            if conditionSet.startCondition() then
                cell.running = true
                print( cellName.."@cmp.stop" )
            end    
        end

        if conditionSet.stopCondition and cell.running then
            if conditionSet.stopCondition() then
                cell.running = false
                print( cellName.."@cmp.stop" )
            end
        end
        
    end
end

function computer:clearConditions()
    self.conditions = {}
end

return computer