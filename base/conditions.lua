local condition = {}

local check = function(condition, data)
    
end

local new = function(values, types)
    local object = {
        values = values,
        types = types
    }

    object.check = check

    return object
end

return condition