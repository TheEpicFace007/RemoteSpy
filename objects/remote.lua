local remote = {
    cache = {}
}

remote.new = function(instance)
    local object = {
        logs = {},
        calls = 0,
        block = false,
        ignore = false,
        instance = instance
    }

    remote.cache[instance] = object
    return object
end

return remote