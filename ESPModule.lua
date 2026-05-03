local ESPModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local esp = {
    Enabled = false,
    Box = false,
    Name = false,
    Health = false,
    Level = false,
    Distance = false,
    V3 = false,
    V3CD = 5,
    Buso = false,
    Bunnyhop = false,
    AntiAfk = false,
    NoDodgeCD = false,
    RTXMode = "Default",
    GlobalFont = Enum.Font.GothamBold,
    FruitESP = false
}

local billboards = {}
local v3Connection = nil
local busoConnection = nil

-- Create billboard for ESP
local function createBillboard(character)
    if not character or not character:FindFirstChild("Head") then return nil end
    
    local billboard = Instance.new("BillboardGui")
    billboard.MaxDistance = 10000
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = character.Head
    
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = esp.GlobalFont
    textLabel.TextSize = 14
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Parent = billboard
    
    return billboard, textLabel
end

-- Update ESP display
local function updateESP()
    -- Clear old billboards for removed players
    for char, board in pairs(billboards) do
        if not char.Parent then
            if board then pcall(function() board:Destroy() end) end
            billboards[char] = nil
        end
    end
    
    if not esp.Enabled then return end
    
    -- Update or create billboards for players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            
            if hrp and hum and head then
                local billboard = billboards[char]
                
                if not billboard then
                    billboard, _ = createBillboard(char)
                    billboards[char] = billboard
                end
                
                if billboard and billboard.Parent then
                    local textLabel = billboard:FindFirstChild("TextLabel")
                    if textLabel then
                        local text = player.Name
                        
                        if esp.Health then
                            text = text .. "\nHP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                        end
                        
                        if esp.Distance then
                            local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            text = text .. "\nDist: " .. math.floor(dist)
                        end
                        
                        textLabel.Text = text
                        textLabel.Font = esp.GlobalFont
                    end
                end
            end
        end
    end
end

-- V3 SKILL AUTO
local lastV3Time = 0
local function startV3()
    if v3Connection then v3Connection:Disconnect() end
    
    v3Connection = RunService.Heartbeat:Connect(function()
        if not esp.V3 then return end
        
        local now = tick()
        if now - lastV3Time < esp.V3CD then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes then
            local commF = remotes:FindFirstChild("CommF_")
            if commF then
                pcall(function()
                    commF:InvokeServer("ActivateAbility")
                    lastV3Time = now
                end)
            end
        end
    end)
end

-- BUSO AUTO APPLY
local function startBuso()
    if busoConnection then busoConnection:Disconnect() end
    
    busoConnection = RunService.Heartbeat:Connect(function()
        if not esp.Buso then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local hasBuso = char:FindFirstChild("Buso")
        if hasBuso and hasBuso.Value then return end
        
        -- Check if we can apply buso
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes then
            local commF = remotes:FindFirstChild("CommF_")
            if commF then
                pcall(function()
                    commF:InvokeServer("Buso")
                end)
            end
        end
    end)
end

function ESPModule:SetESP(state)
    esp.Enabled = state
    if state then
        local updateConn = RunService.RenderStepped:Connect(function()
            if esp.Enabled then
                updateESP()
            end
        end)
    end
end

function ESPModule:SetESPBox(state)
    esp.Box = state
end

function ESPModule:SetESPName(state)
    esp.Name = state
end

function ESPModule:SetESPHealth(state)
    esp.Health = state
end

function ESPModule:SetESPLevel(state)
    esp.Level = state
end

function ESPModule:SetESPDistance(state)
    esp.Distance = state
end

function ESPModule:SetV3(state)
    esp.V3 = state
    if state then startV3() end
end

function ESPModule:SetV3CD(cd)
    esp.V3CD = cd
end

function ESPModule:SetBuso(state)
    esp.Buso = state
    if state then startBuso() end
end

function ESPModule:SetBunnyhop(state)
    esp.Bunnyhop = state
    if state then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = 100
        end
    end
end

function ESPModule:SetAntiAfk(state)
    esp.AntiAfk = state
end

function ESPModule:SetNoDodgeCD(state)
    esp.NoDodgeCD = state
end

function ESPModule:SetGlobalFont(font)
    esp.GlobalFont = font
end

function ESPModule:SetRTXMode(mode)
    esp.RTXMode = mode
    -- Apply RTX graphics if mode is set
end

function ESPModule:SetFruitESP(state)
    esp.FruitESP = state
end

return ESPModule
