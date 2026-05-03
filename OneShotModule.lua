local OneShot = {}

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

local enabled = false
local KEYBIND = Enum.KeyCode.H

-- Weapons whose stun move triggers the 1-shot
local STUN_WEAPONS = { ["Saishi"] = true, ["Spikey Trident"] = true }

local SEA_Y = -500 -- How far down to teleport the enemy

local function isStunned(character)
    local stun = character:FindFirstChild("Stun")
    if stun and type(stun.Value) == "number" and stun.Value > 0 then return true end
    local busy = character:FindFirstChild("Busy")
    if busy and busy.Value then return true end
    return false
end

local function getStunnedEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position
    local best, bestDist = nil, math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 and isStunned(p.Character) then
                local d = (hrp.Position - myPos).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = p.Character
                end
            end
        end
    end

    return best
end

local function doOneShot()
    if not enabled then return end
    local target = getStunnedEnemy()
    if not target then return end
    if target == LocalPlayer.Character then return end -- safety

    local hrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Teleport only the enemy down to sea — never the local player
    pcall(function()
        -- Remove any body movers so they drop freely
        for _, obj in ipairs(hrp:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                obj:Destroy()
            end
        end
        hrp.CFrame = CFrame.new(hrp.Position.X, SEA_Y, hrp.Position.Z)
        -- Apply downward velocity to ensure they keep falling
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, -200, 0)
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Parent = hrp
        game:GetService("Debris"):AddItem(bv, 1)
    end)
end

-- Listen for keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == KEYBIND then
        doOneShot()
    end
end)

function OneShot:SetEnabled(v) enabled = v end
function OneShot:SetKeybind(key) KEYBIND = key end

return OneShot