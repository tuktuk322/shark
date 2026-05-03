local KillAura = {}

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local enabled        = false
local range          = 300
local includePlayers = true
local includeNPCs    = true
local connection

local function getTargets()
    local results = {}
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return results end
    local myPos = char.HumanoidRootPart.Position

    if includePlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    if (hrp.Position - myPos).Magnitude <= range then
                        table.insert(results, p.Character)
                    end
                end
            end
        end
    end

    if includeNPCs then
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        if enemiesFolder then
            for _, npc in ipairs(enemiesFolder:GetChildren()) do
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                local hum = npc:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    if (hrp.Position - myPos).Magnitude <= range then
                        table.insert(results, npc)
                    end
                end
            end
        end
    end

    return results
end

local function tryHit(target)
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local hrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Try melee/fruit remote
    local leftClick = tool:FindFirstChild("LeftClickRemote")
    if leftClick then
        local dir = (hrp.Position - char.HumanoidRootPart.Position).Unit
        pcall(function() leftClick:FireServer(dir, 1) end)
        return
    end

    -- Try RegisterHit style
    pcall(function()
        if RegisterAttack then RegisterAttack:FireServer(0) end
        if RegisterHit then RegisterHit:FireServer(hrp, {{target, hrp}}) end
    end)
end

local function loop()
    if connection then connection:Disconnect() end
    connection = RunService.Stepped:Connect(function()
        if not enabled then return end
        local targets = getTargets()
        for _, target in ipairs(targets) do
            tryHit(target)
        end
    end)
end

function KillAura:SetEnabled(v)
    enabled = v
    if v then loop() elseif connection then connection:Disconnect() end
end

function KillAura:SetRange(v)          range = v          end
function KillAura:SetIncludePlayers(v) includePlayers = v end
function KillAura:SetIncludeNPCs(v)    includeNPCs = v    end

return KillAura