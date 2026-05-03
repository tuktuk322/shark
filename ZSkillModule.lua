local ZSkillModule = {}

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local zskill = {
    Enabled = false,
    ShowInfo = false,
    CurrentTarget = nil
}

local infoConnection = nil

local function getNearestEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = char.HumanoidRootPart.Position
    local nearest = nil
    local nearestDist = 5000
    
    -- Check players
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetChar = player.Character
            local hrp = targetChar:FindFirstChild("HumanoidRootPart")
            local hum = targetChar:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - myPos).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = targetChar
                end
            end
        end
    end
    
    return nearest
end

function ZSkillModule:SetZSkills(state)
    zskill.Enabled = state
end

function ZSkillModule:SetInfo(state)
    zskill.ShowInfo = state
    
    if infoConnection then infoConnection:Disconnect() end
    
    if state then
        infoConnection = RunService.Heartbeat:Connect(function()
            local target = getNearestEnemy()
            if target then
                zskill.CurrentTarget = target
                local hum = target:FindFirstChildOfClass("Humanoid")
                if hum then
                    local info = target.Name .. " - HP: " .. math.floor(hum.Health)
                    -- Update UI with target info (would need UI reference)
                end
            end
        end)
    end
end

function ZSkillModule:GetCurrentTarget()
    return zskill.CurrentTarget
end

return ZSkillModule
