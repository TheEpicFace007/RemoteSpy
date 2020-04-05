local ui = {}

local tween_service = game:GetService("TweenService")
local text_service = game:GetService("TextService")
local user_input = game:GetService("UserInputService")
local players = game:GetService("Players")

local client = players.LocalPlayer

local ui = game:GetObjects("rbxassetid://4861485073")[1]

local base = ui.Base

local drag = base.Drag
local body = base.Body



local create_arg = function(index, value)

end

local create_call = function(vargs)

end

ui.create_log = function(instance)
    local object = {}



    return object
end

ui.update = function(object, vargs)
    local log = object.log

    if not log then
        return
    end

    object.calls = object.calls + 1
    table.insert(object.logs, vargs)
end

return ui