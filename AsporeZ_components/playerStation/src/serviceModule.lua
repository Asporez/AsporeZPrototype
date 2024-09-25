local serviceModule = {}



function serviceModule.load()

    serviceModule.fuelCell1 = {                 -- table to handle fuel cell
        flux = 5,                               -- Power production in MW
        stored = 0,                             -- amount of power stored
        minStored = 0,                          -- battery empty
        maxStored = 100,                        -- maximum amount of power stored
        fuelAmount = 400,                       -- Total fuel in kilograms
        fuelRate = 0.1,                         -- Fuel consumption rate per second (in kg/s)
        temperature = 300,                      -- Operating temperature in Kelvin
        maxTemperature = 1000,                  -- Maximum allowable temperature in Kelvin
        temperatureRate = 5,                    -- Rate at which temperature increases per second
        running = false,
    }

    serviceModule.fuelCell2 = {
        flux = 5,
        stored = 0,
        minStored = 0,
        maxStored = 100,
        fuelAmount = 400,
        fuelRate = 0.1,
        temperature = 300,
        maxTemperature = 1000,
        temperatureRate = 5,
        running = false,
    }

    serviceModule.battery = {
        flux = 10,
        stored = 0,
        maxStored = 5000,
        active = false
    }
end

function serviceModule.updateFuelCell( cell, dt )
    if cell.running and cell.fuelAmount > 0 then
        if cell.stored < cell.maxStored then
            -- Generate flux
            cell.stored = cell.stored + cell.flux * dt
        end

        -- Consume fuel
        cell.fuelAmount = cell.fuelAmount - cell.fuelRate * dt

        -- Increase temperature
        cell.temperature = cell.temperature + cell.temperatureRate * dt

        -- Check if temperature exceeds max and stop the cell if it does
        if cell.temperature > cell.maxTemperature then
            cell.running = false
            print( "Fuel cell stopped due to overheating!" )
        end
    elseif cell.fuelAmount <= 0 then
        -- Stop the cell if fuel runs out
        cell.running = false
        print( "Fuel cell stopped due to lack of fuel!" )
    end
    -- fuel cell offline, remaining charge is lost and the fuel slowly cools down
    if not cell.running then
        if cell.stored > 1 then
            cell.stored = cell.stored - cell.flux * dt
        end

        if cell.temperature > 300 then
            cell.temperature = cell.temperature - cell.temperatureRate / 5 * dt
        end
    end
end

-- Update both fuel cells
function serviceModule.update(dt)

    -- Battery charging
    if serviceModule.fuelCell1.stored >= 100 and serviceModule.battery.stored <= serviceModule.battery.maxStored then
        serviceModule.battery.stored = serviceModule.battery.stored + serviceModule.fuelCell1.flux * dt
    end
    if serviceModule.fuelCell2.stored >= 100 then
        serviceModule.battery.stored = serviceModule.battery.stored + serviceModule.fuelCell2.flux * dt
    end

    serviceModule.updateFuelCell(serviceModule.fuelCell1, dt)
    serviceModule.updateFuelCell(serviceModule.fuelCell2, dt)
end

return serviceModule