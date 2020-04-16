if rs and rs.exit then
    rs.exit()
    getgenv().rs = nil
end

local methods, missing_methods = {
    get_metatable = getrawmetatable or debug.getmetatable or false,
    get_context = getthreadcontext or syn_context_get or false,
    set_readonly = setreadonly or false,
    set_context = setthreadcontext or syn_context_set or false,
    set_clipboard = setclipboard or false,
    hook_function = hookfunction or replaceclosure or false,
    check_caller = checkcaller or false,
    is_readonly = isreadonly or false,
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

local players = game:GetService("Players")
local client = players.LocalPlayer
local player_scripts = client.PlayerScripts

local gmt = getrawmetatable(game)
local nmc = gmt.__namecall

local import_cache = {}
local import = function(asset)
    if import_cache[asset] then
        return import_cache[asset]
    end

    if type(asset) == "string" then
        local data = loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/Upbolt/RemoteSpy/master/%s.lua"):format(asset)))()
        --local data = loadstring(readfile("hydroxide/remotespy/" .. asset .. '.lua'))()
        import_cache[asset] = data
        return data
    end
end

local hooks = {}
local remotes = import("base/constants").methods

setreadonly(gmt, false)

getgenv().rs = {}
rs.events = {}
rs.methods = methods
rs.import = import
rs.generate_script = import("base/generate")
rs.exit = function()
    gmt.__namecall = hooks.namecall

    for class, method in pairs(remotes) do
        hookfunction(method, hooks[class])
    end

    for name, event in pairs(rs.events) do
        event:Disconnect()
    end

    rs.ui.exit()
end

local ui = import("ui/main")
local remote = import("objects/remote")
import("methods")

rs.ui = ui
rs.remote = remote

local create_log = Instance.new("BindableFunction")
create_log.OnInvoke = ui.create_log

local hook = function(method, env, instance, ...)
    local returns 
    if (instance ~= create_log and remotes[instance.ClassName]) then
        local old = methods.get_context()
        local object = rs.cache[instance] 
        
        if not object then
            object = remote.new(instance)
            object.log = create_log.Invoke(create_log, instance)
        end

        if not object.removed then
            methods.set_context(6)
        
            if string.find(instance.ClassName, "Function") then
                returns = table.pack(method(instance, ...))
            end

            if not object.ignored then
                ui.update(object, { args = {...}, env = env, returns = returns })
            end

            methods.set_context(old)

            if object.blocked then
                return
            end
        end
    end
    
    if returns then
        return unpack(returns)
    end

    return method(instance, ...)
end

for class,method in pairs(remotes) do
    hooks[class] = methods.hook_function(method, function(instance, ...)
        return hook(hooks[class], getfenv(2), instance, ...)
    end)
end

hooks.namecall = nmc
gmt.__namecall = function(instance, ...)
    return hook(nmc, getfenv(2), instance, ...)
end
