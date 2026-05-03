local UiSettingsModule = {}

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

UiSettingsModule.currentTheme = "Synapse"

UiSettingsModule.themes = {
    Default = Color3.fromRGB(0, 200, 255),
    Synapse = Color3.fromRGB(10, 250, 10),
    Dark = Color3.fromRGB(50, 50, 50),
    Purple = Color3.fromRGB(200, 100, 255)
}

UiSettingsModule.backgroundThemes = {
    Dark = Color3.fromRGB(20, 20, 20),
    Light = Color3.fromRGB(200, 200, 200),
    Neon = Color3.fromRGB(0, 100, 200)
}

function UiSettingsModule:getThemeNames()
    local names = {}
    for name, _ in pairs(self.themes) do
        table.insert(names, name)
    end
    return names
end

function UiSettingsModule:getBackgroundThemeNames()
    local names = {}
    for name, _ in pairs(self.backgroundThemes) do
        table.insert(names, name)
    end
    return names
end

function UiSettingsModule:updateSchemeColor(color, library)
    if library then
        pcall(function()
            library:UpdateSchemeColor(color)
        end)
    end
end

function UiSettingsModule:updateBackgroundColor(color, library)
    if library then
        pcall(function()
            library:UpdateBackgroundColor(color)
        end)
    end
end

function UiSettingsModule:updateTextColor(color, library)
    if library then
        pcall(function()
            library:UpdateTextColor(color)
        end)
    end
end

function UiSettingsModule:SetWalkSpeed(speed)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = speed
        end
    end
end

function UiSettingsModule:SetV4(state)
    if state then
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes then
            pcall(function()
                remotes:FindFirstChild("CommF_"):InvokeServer("V4")
            end)
        end
    end
end

function UiSettingsModule:SetFruitCheck(state)
    -- Placeholder for fruit check feature
end

function UiSettingsModule:SetTeleportFruit(state)
    -- Placeholder for teleport fruit feature
end

function UiSettingsModule:SetGoToFruit(state)
    -- Placeholder for go to fruit feature
end

function UiSettingsModule:SetAutoRandomFruit(state)
    -- Placeholder for auto random fruit feature
end

function UiSettingsModule:MakeDraggable(gui)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    if gui:IsA("GuiObject") then
        gui.MouseButton1Down:Connect(function()
            dragging = true
            dragStart = game:GetService("UserInputService"):GetMouseLocation()
            startPos = gui.Position
        end)
        
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        RunService.RenderStepped:Connect(function()
            if dragging then
                local currentMouse = game:GetService("UserInputService"):GetMouseLocation()
                local delta = currentMouse - dragStart
                gui.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
            end
        end)
    end
end

return UiSettingsModule
