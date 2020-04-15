local remote = {}
rs.cache = {}

local ignore = function(remote)
    remote.ignored = not remote.ignored

    if remote.log then
        
    end
end

local block = function(remote)
    remote.blocked = not remote.blocked
    
    if remote.log then
        
    end
end

remote.new = function(instance)
    local object = {
        logs = {},
        calls = 0,
        block = block,
        blocked = false,
        ignore = ignore,
        ignored = false,
        instance = instance
    }

    rs.cache[instance] = object
    return object
end

return remote