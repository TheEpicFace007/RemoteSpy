local remote = {}

rs.cache = {}

remote.new = function(instance)
    local object = {
        logs = {},
        calls = 0,
        block = false,
        ignore = false,
        instance = instance
    }

    rs.cache[instance] = object
    return object
end

return remote