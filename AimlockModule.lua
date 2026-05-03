local AimlockModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local aimlock = {
    PlayerAimlock = false,
    NpcAimlock = false,
    Prediction = false,
    PredictionTime = 0.1,
    SelectedPlayer = nil,
    Distance = 5000
}

local currentTarget = nil
local aimConnection = nil

local function getPlayers()
    return Players:GetPlayers()
end

local function getNearestPlayer()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = char.HumanoidRootPart.Position
    local nearest = nil
    local nearestDist = aimlock.Distance + 1
    
    for _, player in ipairs(getPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetChar = player.Character
            local hrp = targetChar:FindFirstChild("HumanoidRootPart")
            local hum = targetChar:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - myPos).Magnitude
                if dist <= aimlock.Distance and dist < nearestDist then
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
    local nearestDist = aimlock.Distance + 1
    
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end
    
    for _, npc in ipairs(enemiesFolder:GetChildren()) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        local hum = npc:FindFirstChildOfClass("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            local dist = (hrp.Position - myPos).Magnitude
            if dist <= aimlock.Distance and dist < nearestDist then
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
    if not aimlock.Prediction then
        return hrp.Position
    end
    
    local velocity = hrp.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
    return hrp.Position + (velocity * aimlock.PredictionTime)
end

local function updateTarget()
    -- If a player is selected, target them
    if aimlock.SelectedPlayer then
        for _, player in ipairs(getPlayers()) do
            if player.Name == aimlock.SelectedPlayer and player.Character then
                local targetChar = player.Character
                local hrp = targetChar:FindFirstChild("HumanoidRootPart")
                local hum = targetChar:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    currentTarget = targetChar
                    return
                end
            end
        end
        currentTarget = nil
        return
    end
    
    -- Otherwise auto-pick nearest
    if aimlock.PlayerAimlock then
        currentTarget = getNearestPlayer()
    elseif aimlock.NpcAimlock then
        currentTarget = getNearestNPC()
    else
        currentTarget = nil
    end
end

local function startAimlock()
    if aimConnection then aimConnection:Disconnect() end
    
    aimConnection = RunService.RenderStepped:Connect(function()
        if not (aimlock.PlayerAimlock or aimlock.NpcAimlock) then
            return
        end
        
        updateTarget()
        
        if not currentTarget then return end
        
        local targetPos = getPredictedPos(currentTarget)
        if not targetPos then return end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local camera = workspace.CurrentCamera
        local hrp = char.HumanoidRootPart
        
        -- Point camera at target
        local newCFrame = CFrame.new(camera.CFrame.Position, targetPos)
        camera.CFrame = newCFrame
    end)
end

function AimlockModule:SetPlayerAimlock(state)
    aimlock.PlayerAimlock = state
    if state then startAimlock() end
end

function AimlockModule:SetNpcAimlock(state)
    aimlock.NpcAimlock = state
    if state then startAimlock() end
end

function AimlockModule:SetPrediction(state)
    aimlock.Prediction = state
end

function AimlockModule:SetPredictionTime(time)
    aimlock.PredictionTime = time
end

function AimlockModule:SetDistance(dist)
    aimlock.Distance = dist
end

function AimlockModule:SetSelectedPlayer(playerName)
    aimlock.SelectedPlayer = playerName
    if playerName then
        aimlock.PlayerAimlock = true
        startAimlock()
    end
end

function AimlockModule:GetCurrentTarget()
    return currentTarget
end

function AimlockModule:SetMiniTogglePlayerAimlock(state)
    self:SetPlayerAimlock(state)
end

function AimlockModule:SetMiniToggleNpcAimlock(state)
    self:SetNpcAimlock(state)
end

return AimlockModule
