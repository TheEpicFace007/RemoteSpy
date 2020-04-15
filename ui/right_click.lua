local players = game:GetService("Players")
local user_input = game:GetService("UserInputService")

local client = players.LocalPlayer
local mouse = client:GetMouse()

local handler = {}
local cache = {}

local selected_menu

rs.events.right_click_event = user_input.InputEnded:Connect(function(e)
    if e.UserInputType == Enum.UserInputType.MouseButton1 and selected_menu then
        selected_menu.Visible = false
    end
end)

handler.add = function(menu, callbacks, extra)
    return (function()
        local old = rs.methods.get_context()
        rs.methods.set_context(6)

        for name,callback in pairs(callbacks) do
            local menu_item = menu.List:FindFirstChild(name)

            if cache[menu_item] then
                cache[menu_item]:Disconnect()
                cache[menu_item] = nil
            end
            
            cache[menu_item] = menu_item.MouseButton1Click:Connect(function()
                local old = rs.methods.get_context()
                rs.methods.set_context(6)

                if callback then
                    callback((extra and extra.param) or nil)
                end

                rs.methods.set_context(old)
            end)
        end

        
        if selected_menu ~= menu then
            if selected_menu then
                selected_menu.Visible = false
            end
            
            selected_menu = menu
        end

        if extra and extra.callback then
            extra.callback(selected_menu)
        end
        
        menu.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
        menu.Visible = true

        rs.methods.set_context(old)
    end)
end

return handler