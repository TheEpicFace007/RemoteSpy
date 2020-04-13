local methods = {
    RemoteEvent = "FireServer",
    RemoteFunction = "InvokeServer",
    BindableEvent = "Fire",
    BindableFunction = "Invoke"
}

local generate = function(instance, vargs)
    local path = rs.methods.get_path(instance)
    local name = instance.Name

    if name:gsub('_', ''):find("%W") then
        name = "remote"
    end

    local script = ("local %s = %s\n"):format(name, path)
    script = ("%s%s:%s("):format(script, name, methods[instance.ClassName])

    for i, arg in pairs(vargs) do
        script = script .. "\n\t" .. rs.methods.data_to_string(arg, 2) .. ','
    end

    return ((#vargs > 0 and script:sub(1, -2) .. '\n') or script) .. ')'
end

return generate