local text_service = game:GetService("TextService")

local remote = {}
rs.cache = {}

local constants = rs.import("base/constants")
local constant = constants.constants

local ignore = function(remote)
    remote.ignored = not remote.ignored
    local log = remote.log

    if not remote.ignored and not remote.blocked then
        log.normal_anim:Play()
    elseif remote.blocked and not remote.ignored then
        log.block_anim:Play()
    elseif remote.ignored then
        log.ignore_anim:Play()
    end
end

local block = function(remote)
    remote.blocked = not remote.blocked
    local log = remote.log

    if not remote.blocked and not remote.ignored then
        log.normal_anim:Play()
    elseif not remote.blocked and remote.ignored then
        log.ignore_anim:Play()
    elseif remote.blocked then
        log.block_anim:Play()
    end
end

local clear = function(remote)
    remote.logs = {}
    remote.calls = 0

    local instance = remote.log.instance
    local call_count = instance.Calls
    local label = instance.Label
    local icon = instance.Icon
    
    local call_width = text_service:GetTextSize(tostring(remote.calls), 16, "SourceSans", constant.max_width).X + 10
    local icon_width_offset = call_width + icon.AbsoluteSize.X
    
    call_count.Text = remote.calls
    call_count.Size = UDim2.new(0, call_width, 0, 20)

    icon.Position = UDim2.new(0, call_width - 4, 0, 1)

    label.Position = UDim2.new(0, icon_width_offset, 0, 0)
    label.Size = UDim2.new(1, -icon_width_offset, 0, 20)
end

remote.new = function(instance)
    local object = {
        logs = {},
        calls = 0,
        block = block,
        blocked = false,
        ignore = ignore,
        ignored = false,
        clear = clear,
        instance = instance,
        removed = false
    }

    rs.cache[instance] = object
    return object
end

remote.block = block
remote.ignore = ignore
remote.clear = clear
return remote