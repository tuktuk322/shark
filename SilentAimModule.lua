local SilentAimModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local silent = {
    PlayerSilentAim = false,
    NPCSilentAim = false,
    Prediction = false,
    PredictionAmount = 0.1,
    DistanceLimit = 1000,
    SelectedPlayer = nil,
    Highlight = false,
    AutoKen = false,
    ZSkillOrM1 = false
}

local oldNamecall
local currentSilentTarget = nil
local silentConnection = nil

local function getNearestPlayer()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = char.HumanoidRootPart.Position
    local nearest = nil
    local nearestDist = silent.DistanceLimit + 1
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetChar = player.Character
            local hrp = targetChar:FindFirstChild("HumanoidRootPart")
            local hum = targetChar:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - myPos).Magnitude
                if dist <= silent.DistanceLimit and dist < nearestDist then
                    nearestDist = dist
                    nearest = targetChar
                end
            end
        end
    end
    
    return nearest
end

local function getNearestNPC()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = char.HumanoidRootPart.Position
    local nearest = nil
    local nearestDist = silent.DistanceLimit + 1
    
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end
    
    for _, npc in ipairs(enemiesFolder:GetChildren()) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        local hum = npc:FindFirstChildOfClass("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            local dist = (hrp.Position - myPos).Magnitude
            if dist <= silent.DistanceLimit and dist < nearestDist then
                nearestDist = dist
                nearest = npc
            end
        end
    end
    
    return nearest
end

local function getPredictedPos(targetChar)
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local hrp = targetChar.HumanoidRootPart
    if not silent.Prediction then
        return hrp.Position
    end
    
    local velocity = hrp.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
    return hrp.Position + (velocity * silent.PredictionAmount)
end

local function getSilentTarget()
    if silent.SelectedPlayer then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name == silent.SelectedPlayer and player.Character then
                return player.Character
            end
        end
    end
    
    if silent.PlayerSilentAim then
        return getNearestPlayer()
    elseif silent.NPCSilentAim then
        return getNearestNPC()
    end
    
    return nil
end

local function hookSilentAim()
    if oldNamecall then return end
    
    local oldNC
    oldNC = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if (method == "FireServer" or method == "InvokeServer") and (silent.PlayerSilentAim or silent.NPCSilentAim) then
            local targetPos = nil
            
            if silent.PlayerSilentAim or silent.NPCSilentAim then
                currentSilentTarget = getSilentTarget()
                if currentSilentTarget then
                    targetPos = getPredictedPos(currentSilentTarget)
                end
            end
            
            if targetPos then
                -- Replace Vector3 arguments
                for i, arg in ipairs(args) do
                    if typeof(arg) == "Vector3" then
                        args[i] = targetPos
                        break
                    elseif typeof(arg) == "CFrame" then
                        args[i] = CFrame.new(targetPos) * arg.Rotation
                        break
                    end
                end
            end
        end
        
        return oldNC(self, unpack(args))
    end)
    
    oldNamecall = oldNC
end

local function startAutoKen()
    if silentConnection then silentConnection:Disconnect() end
    
    silentConnection = RunService.Heartbeat:Connect(function()
        if not silent.AutoKen then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local ken = char:FindFirstChild("Ken")
        if not ken or not ken.Value then
            -- Activate Ken if not active
            local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            if remotes then
                pcall(function()
                    remotes:FindFirstChild("CommF_"):InvokeServer("Ken")
                end)
            end
        end
    end)
end

function SilentAimModule:SetPlayerSilentAim(state)
    silent.PlayerSilentAim = state
    if state then hookSilentAim() end
end

function SilentAimModule:SetNPCSilentAim(state)
    silent.NPCSilentAim = state
    if state then hookSilentAim() end
end

function SilentAimModule:SetPrediction(state)
    silent.Prediction = state
end

function SilentAimModule:SetPredictionAmount(amount)
    silent.PredictionAmount = amount
end

function SilentAimModule:SetDistanceLimit(limit)
    silent.DistanceLimit = limit
end

function SilentAimModule:SetSelectedPlayer(playerName)
    silent.SelectedPlayer = playerName
    if playerName then
        silent.PlayerSilentAim = true
        hookSilentAim()
    end
end

function SilentAimModule:SetHighlight(state)
    silent.Highlight = state
    if state and currentSilentTarget then
        if currentSilentTarget:FindFirstChild("Highlight") then
            currentSilentTarget.Highlight:Destroy()
        end
        
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Parent = currentSilentTarget
    end
end

function SilentAimModule:SetAutoKen(state)
    silent.AutoKen = state
    if state then startAutoKen() end
end

function SilentAimModule:SetZSkillorM1(state)
    silent.ZSkillOrM1 = state
end

function SilentAimModule:SetMiniTogglePlayerSilentAim(state)
    self:SetPlayerSilentAim(state)
end

function SilentAimModule:SetMiniToggleNpcSilentAim(state)
    self:SetNPCSilentAim(state)
end

function SilentAimModule:GetCurrentTarget()
    return currentSilentTarget
end

return SilentAimModule
