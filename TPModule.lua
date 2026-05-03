local TPModule = {}

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local tpPlayer = false
local tpNPC    = false
local tpRange  = 250
local conn

local function getNearestPlayer()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position
    local best, bestDist = nil, tpRange + 1
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - myPos).Magnitude
                if d < bestDist then bestDist = d; best = hrp end
            end
        end
    end
    return best
end

local function getNearestNPC()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position
    local best, bestDist = nil, tpRange + 1
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    for _, npc in ipairs(folder:GetChildren()) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        local hum = npc:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local d = (hrp.Position - myPos).Magnitude
            if d < bestDist then bestDist = d; best = hrp end
        end
    end
    return best
end

local function loop()
    if conn then conn:Disconnect() end
    conn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local myHRP = char.HumanoidRootPart

        if tpPlayer then
            local target = getNearestPlayer()
            if target then
                -- TP slightly behind target
                local offset = target.CFrame.LookVector * -3
                pcall(function()
                    myHRP.CFrame = CFrame.new(target.Position + offset + Vector3.new(0, 2, 0))
                end)
            end
        elseif tpNPC then
            local target = getNearestNPC()
            if target then
                pcall(function()
                    myHRP.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
                end)
            end
        end
    end)
end

function TPModule:SetTpNearestPlayer(v)
    tpPlayer = v
    if v or tpNPC then loop() elseif conn then conn:Disconnect() end
end

function TPModule:SetTpNearestNPC(v)
    tpNPC = v
    if v or tpPlayer then loop() elseif conn then conn:Disconnect() end
end

function TPModule:SetRange(v) tpRange = v end

function TPModule:TpBehindNearest()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local target = getNearestPlayer() or getNearestNPC()
    if not target then return end
    pcall(function()
        local offset = target.CFrame.LookVector * -4
        char.HumanoidRootPart.CFrame = CFrame.new(target.Position + offset + Vector3.new(0, 2, 0))
    end)
end

return TPModule