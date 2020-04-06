local methods, missing_methods = {
    get_metatable = getrawmetatable or debug.getmetatable or false,
    get_context = (syn and syn.get_thread_identity) or getthreadcontext or false,
    set_readonly = setreadonly or false,
    set_context = (syn and syn.set_thread_identity) or setthreadcontext or false,
    new_cclosure = newcclosure or false,
    hook_function = hookfunction or replaceclosure or false,
    check_caller = checkcaller or false,
    is_readonly = isreadonly or false
}, ""

for name, method in pairs(methods) do
    if not method then
        missing_methods = missing_methods .. name .. ', '
    end
end

assert(
    #missing_methods == 0, 
    ("Your exploit is missing: %s"):format(missing_methods:sub(1, -3))
)

local remote_check = {
    RemoteEvent = Instance.new("RemoteEvent").FireServer,
    RemoteFunction = Instance.new("RemoteFunction").InvokeServer,
    BindableEvent = Instance.new("BindableEvent").Fire,
    BindableFunction = Instance.new("BindableFunction").Invoke
}

local import = function(asset)
    if type(asset) == "string" then
        return loadstring(readfile("hydroxide/remotespy/" .. asset .. '.lua'))()
    end
end

local remote_spy_hook = Instance.new("BindableFunction")
remote_spy_hook.OnInvoke = function(object)
    return ui.create_log(object)
end

getgenv().rs = {}
rs.methods = methods

local ui = import("ui")
local remote = import("objects/remote")

local hook = function(method, instance, ...)
    if methods.check_caller() and instance == remote_spy_hook then
        return method(instance, ...)
    end

    if remote_check[instance.ClassName] then
        local old_context = methods.get_context()
        local object = remote.cache[instance]

        methods.set_context(6)

        if not object then
            object = remote.new(instance)
            object.logs = remote_spy_hook.Invoke(remote_spy_hook, object)
        end

        if methods.check_caller() or object.ignore then
            return method(instance, ...)
        end

        if object.block then
            return
        end

        ui.update(object, {...})
        methods.set_context(old_context)
    end

    return method(instance, ...)
end

local gmt = methods.get_metatable(game)
local nmc = gmt.__namecall

for object_name, method in pairs(remote_check) do
    local original_method 
    original_method = methods.hook_function(method, function(instance, ...)
        return hook(original_method, instance, ...)
    end)
end

methods.set_readonly(gmt, false)

gmt.__namecall = function(instance, ...)
    return hook(nmc, instance, ...)
end