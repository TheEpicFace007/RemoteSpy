local ui = {}

local constants = {
    empty_logs = UDim2.new(0, 0, 0, 10),
    tween_time = TweenInfo.new(0.15),
    max_width = Vector2.new(133742069, 20),
    log_hover = Color3.fromRGB(50, 50, 50),
    log_leave = Color3.fromRGB(40, 40, 40),
    log_size = UDim2.new(0, 0, 0, 25),
}

local icons = {
    ["nil"] = "rbxassetid://4800232219",
    table = "rbxassetid://4666594276",
    string = "rbxassetid://4666593882",
    number = "rbxassetid://4666593882",
    boolean = "rbxassetid://4666593882",
    userdata = "rbxassetid://4666594723",
    ["function"] = "rbxassetid://4666593447",
    RemoteEvent = "rbxassetid://4229806545",
    RemoteFunction = "rbxassetid://4229810474",
    BindableEvent = "rbxassetid://4229809371",
    BindableFunction = "rbxassetid://4229807624"
}

local syntax = {
    ["nil"] = Color3.fromRGB(244, 135, 113),
    table = Color3.fromRGB(200, 200, 200),
    string = Color3.fromRGB(225, 150, 85),
    number = Color3.fromRGB(170, 225, 127),
    boolean = Color3.fromRGB(127, 200, 255),
    userdata = Color3.fromRGB(200, 200, 200),
    ["function"] = Color3.fromRGB(200, 200, 200)
}

local tween_service = game:GetService("TweenService")
local text_service = game:GetService("TextService")
local user_input = game:GetService("UserInputService")
local players = game:GetService("Players")

local client = players.LocalPlayer

local gui = game:GetObjects("rbxassetid://4861485073")[1]
local assets = game:GetObjects("rbxassetid://4863384563")[1]

local base = gui.Base

local drag = base.Drag
local body = base.Body

local list = body.List
local logs = body.Logs

local list_flags = list.Flags
local list_results = list.Results.Clip.Content

local logs_back = logs.Back
local logs_object = logs.RemoteObject
local logs_results = logs.Results.Clip.Content

local to_string = function(value)
    local type = typeof(value)
    if type == "userdata" or type == "table" then
        local mt = rs.methods.get_metatable(value)
        local __tostring = mt and rawget(mt, "__tostring")

        if not mt or (mt and not __tostring) then 
            return tostring(value) 
        end

        rawset(mt, "__tostring", nil)
        
        value = tostring(value)
        
        rawset(mt, "__tostring", __tostring)

        return value  
    else 
        return tostring(value) 
    end
end

local create_call = function(vargs)
    local call = assets.CallPod.Clone(assets.CallPod)

    for i,v in pairs(vargs) do
        local arg = assets.RemoteArg.Clone(assets.RemoteArg)
        local value_type = type(value)

        arg.Icon.Image = icons[value_type]
        arg.Label.Text = to_string(value)
        arg.Label.TextColor3 = syntax[value_type]

        call.Size = call.Size + constants.log_size

        arg.Parent = call.Contents
    end

    call.Parent = logs_results
    logs_results.CanvasSize = logs_results.CanvasSize + UDim2.new(0, 0, 0, call.AbsoluteSize.Y)

    return call
end

logs_back.MouseButton1Click:Connect(function()
    logs.Visible = false
    list.Visible = true
end)

local selected_remote
ui.create_log = function(remote)
    local instance = remote.instance
    local log = assets.RemoteLog.Clone(assets.RemoteLog)
    local button = log.Button

    local enter = tween_service:Create(button, constants.tween_time, { ImageColor3 = constants.log_hover })
    local leave = tween_service:Create(button, constants.tween_time, { ImageColor3 = constants.log_leave })

    log.Label.Text = instance.Name
    log.Icon.Image = icons[instance.ClassName]
    log.Parent = list_results

    button.MouseButton1Click.Connect(button.MouseButton1Click, function()
        if selected_remote ~= remote then
            for i,args in pairs(logs_results.GetChildren(logs_results)) do
                if args.ClassName == "ImageButton" then
                    args.Destroy(args)
                end
            end

            logs_results.CanvasSize = constants.empty_logs

            for i,args in pairs(remote.logs) do
                create_call(args)
            end

            selected_remote = remote
        end

        list.Visible = false
        logs.Visible = true
    end)

    button.MouseEnter.Connect(button.MouseEnter, function()
        enter.Play(enter)
    end)

    button.MouseLeave.Connect(button.MouseLeave, function()
        leave.Play(leave)
    end)

    list_results.CanvasSize = list_results.CanvasSize + constants.log_size

    return log
end

ui.update = function(object, vargs)
    local log = object.log

    if not log then
        return
    end

    object.calls = object.calls + 1
    table.insert(object.logs, vargs)
end

local dragging, dragInput, dragStart, startPos

drag.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = base.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

drag.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

user_input.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
	    base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

gui.Parent = game:GetService("CoreGui")

return ui