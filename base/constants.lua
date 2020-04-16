local constants = {
    empty_logs = UDim2.new(0, 0, 0, 15),

    block_size = UDim2.new(0, 62, 0, 20),
    unblock_size = UDim2.new(0, 80, 0, 20),
    ignore_size = UDim2.new(0, 66, 0, 20),
    unignore_size = UDim2.new(0, 84, 0, 20),

    blocked_color = Color3.fromRGB(170, 0, 0),
    ignored_color = Color3.fromRGB(100, 100, 100),
    normal_color = Color3.fromRGB(200, 200, 200),

    tween_time = TweenInfo.new(0.15),
    max_width = Vector2.new(133742069, 20),
    log_hover = Color3.fromRGB(50, 50, 50),
    log_leave = Color3.fromRGB(40, 40, 40),
    log_size = UDim2.new(0, 0, 0, 25)
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

local methods = {
    RemoteEvent = Instance.new("RemoteEvent").FireServer,
    RemoteFunction = Instance.new("RemoteFunction").InvokeServer,
    BindableEvent = Instance.new("BindableEvent").Fire,
    BindableFunction = Instance.new("BindableFunction").Invoke
}

return { 
    constants = constants, 
    icons = icons, 
    syntax = syntax,
    methods = methods
}