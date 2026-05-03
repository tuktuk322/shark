-- Add these to your existing StuffsModule

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ── ANTI STUN ──────────────────────────────────────────────────────────────
local _antiStunConn
function Stuffs:SetAntiStun(v)
    if _antiStunConn then _antiStunConn:Disconnect() end
    if not v then return end
    _antiStunConn = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.PlatformStand then hum.PlatformStand = false end
            if hum.Sit then hum.Sit = false end
        end
        local stun = char:FindFirstChild("Stun")
        if stun and type(stun.Value) == "number" and stun.Value > 0 then
            pcall(function() stun.Value = 0 end)
        end
        local busy = char:FindFirstChild("Busy")
        if busy and busy.Value then pcall(function() busy.Value = false end) end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, c in ipairs(hrp:GetChildren()) do
                if c:IsA("BodyVelocity") or c:IsA("BodyPosition") or c:IsA("BodyGyro") then
                    pcall(function() c:Destroy() end)
                end
            end
        end
    end)
end

-- ── WATER WALK V2 (platform) ───────────────────────────────────────────────
local _platform, _waterConn
function Stuffs:SetWaterWalk(v)
    if _waterConn then _waterConn:Disconnect() end
    if _platform then pcall(function() _platform:Destroy() end) end
    if not v then return end

    _platform = Instance.new("Part")
    _platform.Name         = "ArkxiWaterPlatform"
    _platform.Size         = Vector3.new(8, 0.5, 8)
    _platform.Transparency = 1
    _platform.Anchored     = true
    _platform.CanCollide   = true
    _platform.CanTouch     = false
    _platform.Parent       = workspace

    _waterConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local pos = hrp.Position
        -- auto resurface if underwater
        if pos.Y < -1 then
            pcall(function()
                hrp.CFrame = CFrame.new(pos.X, 5, pos.Z)
            end)
        end
        _platform.CFrame = CFrame.new(pos.X, pos.Y - 3.2, pos.Z)
    end)
end

-- ── FAST ATTACK ────────────────────────────────────────────────────────────
local _fastConn, _fastSpeed = nil, 0.05
function Stuffs:SetFastAttack(v)
    if _fastConn then _fastConn:Disconnect() end
    if not v then return end
    _fastConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
        local lc = tool:FindFirstChild("LeftClickRemote")
        if lc then
            -- auto click toward nearest enemy
            pcall(function() lc:FireServer(Vector3.new(0,0,-1), 1) end)
        end
    end)
end
function Stuffs:SetFastAttackSpeed(v) _fastSpeed = v end
function Stuffs:SetDashEnabled(v)     _dashEnabled = v end
function Stuffs:SetDashPower(v)       _dashPower = v end

-- ── SKY ESCAPE ─────────────────────────────────────────────────────────────
local _escapeHealth = 1000, _escapeConn
function Stuffs:SetSkyEscape(v)
    if _escapeConn then _escapeConn:Disconnect() end
    if not v then return end
    _escapeConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 and hum.Health <= _escapeHealth then
            pcall(function()
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 300, 0)
            end)
        end
    end)
end
function Stuffs:SetEscapeHealth(v) _escapeHealth = v end

-- ── BOAT ───────────────────────────────────────────────────────────────────
local _boatSpeed, _boatFly, _boatMult, _boatHeight = false, false, 2, 50
local _boatConn
local function startBoatLoop()
    if _boatConn then _boatConn:Disconnect() end
    _boatConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local seat = hum.SeatPart
        if not seat or not seat:IsA("VehicleSeat") then return end
        if _boatFly then
            pcall(function()
                seat.CFrame = CFrame.new(seat.Position.X, _boatHeight, seat.Position.Z) * CFrame.Angles(0, seat.CFrame:ToEulerAnglesYXZ(), 0)
            end)
        end
        if _boatSpeed then
            pcall(function()
                seat.CFrame = seat.CFrame * CFrame.new(0, 0, -0.5 * _boatMult)
            end)
        end
    end)
end

function Stuffs:SetBoatSpeed(v)      _boatSpeed = v;   startBoatLoop() end
function Stuffs:SetBoatFly(v)        _boatFly = v;     startBoatLoop() end
function Stuffs:SetBoatSpeedMult(v)  _boatMult = v     end
function Stuffs:SetBoatFlyHeight(v)  _boatHeight = v   ends