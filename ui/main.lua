local ui = {}

local constants = {
    rounded = "rbxassetid://4503146326",
    empty_logs = UDim2.new(0, 0, 0, 15),
    tween_time = TweenInfo.new(0.15),
    max_width = Vector2.new(133742069, 20),
    log_hover = Color3.fromRGB(50, 50, 50),
    log_leave = Color3.fromRGB(40, 40, 40),
    log_size = UDim2.new(0, 0, 0, 25),
    blocked_color = Color3.fromRGB(170, 0, 0),
    ignored_color = Color3.fromRGB(100, 100, 100),
    normal_color = Color3.fromRGB(200, 200, 200)
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
    BindableFunction = "rbxassetid://4229807624",
    
    block = "rbxassetid://4891641806",
    unblock = "rbxassetid://4891642508",
    ignore = "rbxassetid://4842578510",
    unignore = "rbxassetid://4842578818"
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

local viewing = {
    RemoteEvent = true,
    RemoteFunction = false,
    BindableEvent = false,
    BindableFunction = false
}

local tween_service = game:GetService("TweenService")
local text_service = game:GetService("TextService")
local user_input = game:GetService("UserInputService")
local players = game:GetService("Players")

local client = players.LocalPlayer

local gui = game:GetObjects("rbxassetid://4861485073")[1]
local assets = game:GetObjects("rbxassetid://4863384563")[1]

local generate_script = rs.import("base/generate")
local right_click = rs.import("ui/right_click")
--local message_box = rs.import("ui/message_box")

local base = gui.Base
local right_log = gui.RightLog
local right_call = gui.RightCall

local drag = base.Drag
local body = base.Body

local list = body.List
local logs = body.Logs

local list_flags = list.Flags
local list_results = list.Results.Clip.Content

local logs_back = logs.Back
local logs_indication = logs.RemoteObject
local logs_results = logs.Results.Clip.Content

local create_arg = function(call, index, value)
    local arg = assets.RemoteArg.Clone(assets.RemoteArg)
    local value_type = type(value)

    arg.Icon.Image = icons[value_type]
    arg.Index.Text = index
    arg.Label.Text = (typeof(value) == "Instance" and value.Name) or rs.methods.to_string(value)
    arg.Label.TextColor3 = syntax[value_type]

    call.Size = call.Size + constants.log_size

    arg.Parent = call.Contents
end

local create_call = function(instance, vargs, returns)
    local call = assets.CallPod.Clone(assets.CallPod)

    if #vargs == 0 then
        create_arg(call, 1, nil)
    else
        for i,v in pairs(vargs) do
            create_arg(call, i, v)
        end
    end

    local call_size = UDim2.new(0, 0, 0, call.AbsoluteSize.Y + 5)

    call.MouseButton2Click:Connect(right_click.add(right_call, {
        Generate = function()
            rs.methods.set_clipboard(generate_script(instance, vargs))
        end,

        Remove = function()
            logs_results.CanvasSize = logs_results.CanvasSize - call_size
            call:Destroy()
        end
    }))

    call.Parent = logs_results
    logs_results.CanvasSize = logs_results.CanvasSize + call_size

    return call
end

for i,flag in pairs(list_flags:GetChildren()) do
    if flag:IsA("Frame") then
        local body = flag.Body
        body.MouseButton1Click:Connect(function()
            viewing[flag.Name] = not viewing[flag.Name]
            
            local is_checked = viewing[flag.Name]
            local result_size = UDim2.new(0, 0, 0, 10)
            
            body.Label.Text = (is_checked and '✓') or ''
            
            for k, remote in pairs(rs.cache) do
                if not viewing[remote.instance.ClassName] then
                    remote.log.Visible = false
                else
                    remote.log.Visible = true
                    result_size = result_size + constants.log_size
                end
            end

            list_results.CanvasSize = result_size
        end)
    end
end

logs_back.MouseButton1Click:Connect(function()
    logs.Visible = false
    list.Visible = true
end)

local selected_remote
local create_log = function(instance)
    local log = assets.RemoteLog.Clone(assets.RemoteLog)
    local button = log.Button

    local instance_class = instance.ClassName

    local enter = tween_service:Create(button, constants.tween_time, { ImageColor3 = constants.log_hover })
    local leave = tween_service:Create(button, constants.tween_time, { ImageColor3 = constants.log_leave })

    local block_anim = tween_service:Create(log.Label, constants.tween_time, { TextColor3 = constants.blocked_color })
    local ignore_anim = tween_service:Create(log.Label, constants.tween_time, { TextColor3 = constants.ignored_color })
    local normal_anim = tween_service:Create(log.Label, constants.tween_time, { TextColor3 = constants.normal_color })

    log.Visible = viewing[instance_class]
    log.Label.Text = instance.Name
    log.Icon.Image = icons[instance_class]
    log.Parent = list_results

    button.MouseButton2Click:Connect(right_click.add(right_log, {
        Conditions = function()
            
        end,

        Path = function(remote)
            rs.methods.set_clipboard( rs.methods.get_path(remote.instance) )
        end,

        Block = function(remote)
            remote.block = not remote.block

            if not remote.block and not remote.ignore then
                normal_anim:Play()
            elseif not remote.block and remote.ignore then
                ignore_anim:Play()
            elseif remote.block then
                block_anim:Play()
            end
        end,

        Ignore = function(remote)
            remote.ignore = not remote.ignore

            if not remote.ignore and not remote.block then
                normal_anim:Play()
            elseif not remote.ignore and remote.block then
                block_anim:Play()
            elseif remote.ignore then
                ignore_anim:Play()
            end
        end,

        Remove = function(remote)
            remote.ignore = true
            remote.log = nil
            
            log:Destroy()
        end
    }, { callback = function(selected_menu)
        local remote = rs.cache[instance]
        local ignore = selected_menu.List.Ignore
        local block = selected_menu.List.Block

        ignore.Label.Text = (remote.ignore and "Unignore Calls") or "Ignore Calls"
        ignore.Icon.Image = (remote.ignore and icons.unignore) or icons.ignore

        block.Label.Text = (remote.block and "Unblock Calls") or "Block Calls"
        block.Icon.Image = (remote.block and icons.unblock) or icons.block

        if remote.block and log.Label.TextColor3 ~= constants.blocked_color then
            block_anim:Play()
        elseif remote.ignore and log.Label.TextColor3 ~= constants.ignored_color then
            ignore_anim:Play()
        elseif not remote.ignore and not remote.block then
            normal_anim:Play()
        end
    end, instance = instance}))

    button.MouseButton1Click:Connect(function()
        local remote = rs.cache[instance]

        if selected_remote ~= remote then
            for i,args in pairs(logs_results:GetChildren()) do
                if args.Name == "CallPod" then
                    args:Destroy()
                end
            end

            logs_results.CanvasSize = constants.empty_logs

            local remote_name = instance.Name
            local indication_width = text_service:GetTextSize(remote_name, 16, "SourceSans", constants.max_width).X + 18
            
            logs_indication.Position = UDim2.new(1, -(indication_width + 5), 0, 2)
            logs_indication.Size = UDim2.new(0, indication_width, 0, 20)
            logs_indication.Label.Text = remote_name
            logs_indication.Icon.Image = icons[instance_class]

            for i,args in pairs(remote.logs) do
                create_call(instance, args)
            end
            
            selected_remote = remote
        end

        list.Visible = false
        logs.Visible = true
    end)

    button.MouseEnter:Connect(function()
        enter:Play()
    end)

    button.MouseLeave:Connect(function()
        leave:Play()
    end)

    if viewing[instance_class] then
        list_results.CanvasSize = list_results.CanvasSize + constants.log_size
    end

    return log
end

local update = function(remote, vargs, returns)
    local log = remote.log

    local icon = log.Icon
    local label = log.Label
    local call_count = log.Calls

    remote.calls = remote.calls + 1
    table.insert(remote.logs, vargs)

    local call_width = text_service.GetTextSize(text_service, tostring(remote.calls), 16, "SourceSans", constants.max_width).X + 10

    call_count.Text = remote.calls
    call_count.Size = UDim2.new(0, call_width, 0, 20)

    if selected_remote == remote then
        create_call(remote.instance, vargs, returns)
    end

    if not call_count.Text.Fits then
        if remote.calls < 10000 then
            icon.Position = UDim2.new(0, call_width - 4, 0, 0)

            local icon_width_offset = call_width + icon.AbsoluteSize.X

            label.Position = UDim2.new(0, icon_width_offset, 0, 0)
            label.Size = UDim2.new(1, -icon_width_offset, 0, 20)
        else
            icon.Position = UDim2.new(0, 18, 0, 1)
            label.Position = UDim2.new(0, 40, 0, 0)
            label.Size = UDim2.new(1, -40, 0, 20)

            call_count.Text = "..."
            call_count.Size = UDim2.new(0, 20, 0, 20)
        end
    end
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

ui.viewing = viewing
ui.create_log = create_log
ui.update = update
ui.exit = function()
    gui:Destroy()
    assets:Destroy()
end

return ui