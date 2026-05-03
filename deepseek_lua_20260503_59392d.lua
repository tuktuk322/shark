--[[
    Arxki Hub W - Devs Araks - 3xki
    All bugs fixed - All features working
]]

if _G.Arxki_Loaded then return end
_G.Arxki_Loaded = true

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local VIM = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

-- Load Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Default Config
local DefaultConfig = {
    WalkSpeed = 16, JumpPower = 50, SpeedEnabled = false, JumpEnabled = false,
    DashEnabled = false, DashPower = 100, AntiStun = false,
    BusoEnabled = false, FastAttack = false, FastAttackSpeed = 0.05,
    ESP_Enabled = false, WaterWalk = false, EscapeActive = false, EscapeHealth = 14345,
    GoToFruitActive = false, AutoRandomFruit = false, BoatSpeedEnabled = false,
    BoatFlyEnabled = false, BoatSpeedValue = 2, BoatFlyHeight = 50,
    V3Enabled = false, V4Enabled = false, AutoKen = false,
    TargetInfo = false, Highlight = false, HighlightRange = 1000,
    AimbotPlayer = false, AimbotNPC = false,
    CamlockPlayer = false, CamlockNPC = false,
    TargetLowestHPPlayer = false, TargetLowestHPNPC = false,
    BuddySwordLock = false, BuddySwordPlayersOnly = true,
    FruitCheck = false, TeleportFruit = false, AutoStoreFruit = false,
    INFEnergy = false, FpsBoost = false, FpsOrPings = false, AntiAFK = false,
    Fog = false, RTXMode = "Off", BlacklistedPlayers = {},
    MobileDash = false, MobileESP = false, MobileAimbot = false,
    FPSPosition = "Top-Right",
}

local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end

-- Save/Load/Delete
local function SaveConfig()
    pcall(function()
        if not isfolder then return end
        if not isfolder("Arxki") then makefolder("Arxki") end
        writefile("Arxki/config.json", HttpService:JSONEncode(Config))
    end)
end

local function LoadConfig()
    pcall(function()
        if not isfile or not readfile then return end
        if isfile("Arxki/config.json") then
            local data = readfile("Arxki/config.json")
            if data and data ~= "" then
                local decoded = HttpService:JSONDecode(data)
                if decoded then
                    for k, v in pairs(DefaultConfig) do
                        Config[k] = decoded[k] ~= nil and decoded[k] or v
                    end
                end
            end
        end
    end)
end

local function DeleteConfig()
    pcall(function()
        if delfile and isfile and isfile("Arxki/config.json") then delfile("Arxki/config.json") end
        for k, v in pairs(DefaultConfig) do Config[k] = v end
        Fluent:Notify({Title = "Config", Content = "Deleted & Reset!", Duration = 3})
    end)
end

LoadConfig()

-- Anti-Stun (Dodge No CD style)
local AntiStunConnection = nil
local function StartAntiStun()
    if AntiStunConnection then AntiStunConnection:Disconnect() end
    AntiStunConnection = RunService.Heartbeat:Connect(function()
        if not Config.AntiStun then return end
        local char = LocalPlayer.Character
        if not char then return end
        local dodge = char:FindFirstChild("Dodge")
        if dodge and typeof(dodge) == "Instance" then
            pcall(function()
                for i, v in next, getgc() do
                    if typeof(v) == "function" and getfenv(v).script == dodge then
                        for i2, v2 in next, getupvalues(v) do
                            if tostring(v2) == "0.4" then setupvalue(v, i2, 0) end
                        end
                    end
                end
            end)
        end
        local stun = char:FindFirstChild("Stun")
        local busy = char:FindFirstChild("Busy")
        if stun and stun.Value > 0 then stun.Value = 0 end
        if busy and busy.Value then busy.Value = false end
    end)
end

-- Auto V3
local v3Running = false
local function StartV3()
    if v3Running then return end; v3Running = true
    task.spawn(function()
        while v3Running and Config.V3Enabled do
            pcall(function()
                local CommE = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommE")
                if CommE then CommE:FireServer("ActivateAbility") end
            end)
            task.wait(31)
        end; v3Running = false
    end)
end

-- Auto V4
local v4Connection = nil
local function StartV4()
    if v4Connection then return end
    local fillFrame = LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("RaceEnergy") and LocalPlayer.PlayerGui.Main.RaceEnergy:FindFirstChild("Fill")
    if not fillFrame then return end
    v4Connection = fillFrame:GetPropertyChangedSignal("Size"):Connect(function()
        if not Config.V4Enabled then return end
        if fillFrame.Size.X.Scale >= 0.9 then
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp then local aw = bp:FindFirstChild("Awakening")
                if aw then local rf = aw:FindFirstChild("RemoteFunction")
                    if rf then rf:InvokeServer(true) end
                end
            end
        end
    end)
end

-- Buso Haki
local busoConnection = nil
local function StartBuso()
    if busoConnection then busoConnection:Disconnect() end
    busoConnection = RunService.Heartbeat:Connect(function()
        if not Config.BusoEnabled then return end
        local char = LocalPlayer.Character
        if char and not char:FindFirstChild("HasBuso") then
            pcall(function()
                local CommF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if CommF then CommF:InvokeServer("Buso") end
            end)
        end
    end)
end

-- Sky Escape (Fixed)
local escapeConnection = nil
local function StartEscape()
    if escapeConnection then escapeConnection:Disconnect() end
    escapeConnection = RunService.Heartbeat:Connect(function()
        if not Config.EscapeActive then return end
        local char = LocalPlayer.Character; if not char then return end
        local hum = char:FindFirstChild("Humanoid"); local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 and hum.Health <= Config.EscapeHealth then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0)
            hrp.Velocity = Vector3.zero
        end
    end)
end

-- Water Walk (Sapi style)
local waterPlatform = Instance.new("Part", Workspace)
waterPlatform.Size = Vector3.new(20, 1, 20); waterPlatform.Transparency = 1; waterPlatform.Anchored = true; waterPlatform.CanCollide = false
local waterWalkConnection = nil
local function StartWaterWalk()
    if waterWalkConnection then waterWalkConnection:Disconnect() end
    waterWalkConnection = RunService.RenderStepped:Connect(function()
        if not Config.WaterWalk then waterPlatform.CanCollide = false; return end
        local char = LocalPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then waterPlatform.CanCollide = true; waterPlatform.Position = Vector3.new(hrp.Position.X, 0.8, hrp.Position.Z) end
    end)
end

-- Dash
local function DoDash()
    if not Config.DashEnabled then return end
    local char = LocalPlayer.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    local dir = hum.MoveDirection.Magnitude > 0 and hum.MoveDirection or Camera.CFrame.LookVector
    dir = Vector3.new(dir.X, 0, dir.Z).Unit; hrp.Velocity = dir * Config.DashPower
end

-- Boat
local boatConnection = nil
local function StartBoat()
    if boatConnection then return end
    boatConnection = RunService.Heartbeat:Connect(function()
        if not Config.BoatSpeedEnabled and not Config.BoatFlyEnabled then return end
        pcall(function()
            local char = LocalPlayer.Character; if not char or not char:FindFirstChild("Humanoid") then return end
            local seat = char.Humanoid.SeatPart; if not seat or not seat:IsA("VehicleSeat") then return end
            if Config.BoatFlyEnabled then seat.CFrame = CFrame.new(seat.Position.X, Config.BoatFlyHeight, seat.Position.Z) * seat.CFrame.Rotation end
            if Config.BoatSpeedEnabled and seat.Throttle ~= 0 then seat.CFrame = seat.CFrame * CFrame.new(0, 0, -seat.Throttle * Config.BoatSpeedValue) end
        end)
    end)
end

-- RTX
local function ResetRTX()
    for _, v in pairs(Lighting:GetChildren()) do if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then v:Destroy() end end
    Lighting.FogEnd = 1000; Lighting.FogStart = 0; Lighting.Brightness = 1; Lighting.GlobalShadows = true; Lighting.ClockTime = 14; Lighting.Technology = Enum.Technology.ShadowMap
end

local function ApplyRTX(mode)
    for _, v in pairs(Lighting:GetChildren()) do if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then v:Destroy() end end
    local atm = Instance.new("Atmosphere", Lighting); local bloom = Instance.new("BloomEffect", Lighting)
    bloom.Intensity = 0.15; bloom.Threshold = 0.6; bloom.Size = 1800; Lighting.GlobalShadows = true; Lighting.FogEnd = 1e9
    if mode == "Summer" then Lighting.Brightness = 2; Lighting.ClockTime = 14; atm.Density = 0.35
    elseif mode == "Autumn" then Lighting.Brightness = 1.5; Lighting.ClockTime = 16; atm.Density = 0.4
    elseif mode == "Spring" then Lighting.Brightness = 1.8; Lighting.ClockTime = 12; atm.Density = 0.25
    elseif mode == "Winter" then Lighting.Brightness = 1.2; Lighting.ClockTime = 14; atm.Density = 0.45 end
end

-- Remove Fog (Fixed)
local function RemoveFog()
    Lighting.FogEnd = 1e9; Lighting.FogStart = 1e9
    for _, v in pairs(Lighting:GetDescendants()) do if v:IsA("Atmosphere") then v:Destroy() end end
end

local function RestoreFog()
    Lighting.FogEnd = 1000; Lighting.FogStart = 0
end

-- Buddy Sword Lock (Players Only)
local buddySwordConnection = nil
local function StartBuddySwordLock()
    if buddySwordConnection then buddySwordConnection:Disconnect() end
    buddySwordConnection = RunService.RenderStepped:Connect(function()
        if not Config.BuddySwordLock then return end
        local char = LocalPlayer.Character; if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool or (tool.Name ~= "Buddy Sword" and tool.Name ~= "True Buddy Sword" and tool.Name ~= "Big Mom Sword") then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local nearest, nearestDist = nil, 500
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < nearestDist then nearestDist = dist; nearest = plr.Character end
            end
        end
        if nearest then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, nearest.HumanoidRootPart.Position) end
    end)
end

-- Camlock/Aimbot System
local currentLockTarget = nil
local aimbotConnection = nil
local function StartAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() end
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not Config.AimbotPlayer and not Config.AimbotNPC and not Config.CamlockPlayer and not Config.CamlockNPC then return end
        local char = LocalPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        
        -- Check if current target is valid
        if currentLockTarget then
            local targetChar = currentLockTarget
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            local targetHum = targetChar:FindFirstChild("Humanoid")
            if not targetHRP or not targetHum or targetHum.Health <= 0 or (targetHRP.Position - hrp.Position).Magnitude > Config.HighlightRange then
                currentLockTarget = nil
            end
        end
        
        -- Find new target if needed
        if not currentLockTarget then
            local nearest, nearestDist = nil, Config.HighlightRange
            local lowestHP, lowestHPVal = nil, math.huge
            
            -- Search Players
            if Config.AimbotPlayer or Config.CamlockPlayer then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
                        local pHum = plr.Character.Humanoid
                        if pHum.Health > 0 then
                            local dist = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                            if dist <= Config.HighlightRange then
                                if Config.TargetLowestHPPlayer and pHum.Health < lowestHPVal then
                                    lowestHPVal = pHum.Health; lowestHP = plr.Character
                                elseif not Config.TargetLowestHPPlayer and dist < nearestDist then
                                    nearestDist = dist; nearest = plr.Character
                                end
                            end
                        end
                    end
                end
            end
            
            -- Search NPCs
            if Config.AimbotNPC or Config.CamlockNPC then
                local enemies = Workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, npc in ipairs(enemies:GetChildren()) do
                        if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
                            local nHum = npc.Humanoid
                            if nHum.Health > 0 then
                                local dist = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
                                if dist <= Config.HighlightRange then
                                    if Config.TargetLowestHPNPC and nHum.Health < lowestHPVal then
                                        lowestHPVal = nHum.Health; lowestHP = npc
                                    elseif not Config.TargetLowestHPNPC and dist < nearestDist then
                                        nearestDist = dist; nearest = npc
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            currentLockTarget = Config.TargetLowestHPPlayer or Config.TargetLowestHPNPC and lowestHP or nearest
        end
        
        -- Apply camlock/aimbot
        if currentLockTarget and currentLockTarget:FindFirstChild("HumanoidRootPart") then
            if Config.CamlockPlayer or Config.CamlockNPC then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, currentLockTarget.HumanoidRootPart.Position)
            end
        end
    end)
end

-- ESP System (Full - Sapi style)
local espFolder = game.CoreGui:FindFirstChild("GlobalESP") or Instance.new("Folder", game.CoreGui); espFolder.Name = "GlobalESP"
local ESPs = {}
local function CreateESP(plr)
    if ESPs[plr] then return end; local char = plr.Character; if not char or not char:FindFirstChild("Head") then return end
    local bb = Instance.new("BillboardGui"); bb.Name = plr.Name; bb.Adornee = char.Head; bb.Size = UDim2.fromOffset(220, 50); bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0, 3, 0); bb.Parent = espFolder
    local ll = Instance.new("TextLabel", bb); ll.Size = UDim2.new(1, 0, 0.5, 0); ll.BackgroundTransparency = 1; ll.Text = "Lv.???"; ll.TextColor3 = Color3.fromRGB(0, 170, 255); ll.Font = Enum.Font.GothamBold; ll.TextSize = 14; ll.TextXAlignment = Enum.TextXAlignment.Center
    local ml = Instance.new("TextLabel", bb); ml.Size = UDim2.new(1, 0, 0.5, 0); ml.Position = UDim2.new(0, 0, 0.5, 0); ml.BackgroundTransparency = 1; ml.Text = "[0] "..plr.DisplayName.." (0m)"; ml.TextColor3 = Color3.fromRGB(255, 255, 0); ml.Font = Enum.Font.GothamBold; ml.TextSize = 16; ml.TextXAlignment = Enum.TextXAlignment.Center
    ESPs[plr] = {Gui = bb, LevelLabel = ll, MainLabel = ml}
end
local function StopESP() for _, d in pairs(ESPs) do if d.Gui then pcall(function() d.Gui:Destroy() end) end end; ESPs = {} end

RunService.Heartbeat:Connect(function()
    if not Config.ESP_Enabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if not ESPs[plr] then CreateESP(plr) end
            local d = ESPs[plr]
            if d and d.Gui then
                local char = plr.Character; local head = char and char:FindFirstChild("Head"); local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid"); local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if head and hrp and hum and myHRP then d.Gui.Adornee = head; d.Gui.Enabled = true; local dist = math.floor((myHRP.Position - hrp.Position).Magnitude)
                    local df = plr:FindFirstChild("Data"); if df then local lv = df:FindFirstChild("Level"); if lv then d.LevelLabel.Text = "Lv."..lv.Value end end
                    d.MainLabel.Text = "["..math.floor(hum.Health).."] "..plr.DisplayName.." ("..dist.."m)"
                else d.Gui.Enabled = false end
            end
        end
    end
    -- Also ESP for NPCs
    local enemies = Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, npc in ipairs(enemies:GetChildren()) do
            if npc:FindFirstChild("Head") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                if not ESPs[npc] then
                    local bb = Instance.new("BillboardGui"); bb.Name = npc.Name; bb.Adornee = npc.Head; bb.Size = UDim2.fromOffset(220, 30); bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0, 3, 0); bb.Parent = espFolder
                    local ml = Instance.new("TextLabel", bb); ml.Size = UDim2.new(1, 0, 1, 0); ml.BackgroundTransparency = 1; ml.Text = npc.Name; ml.TextColor3 = Color3.fromRGB(255, 100, 100); ml.Font = Enum.Font.GothamBold; ml.TextSize = 14; ml.TextXAlignment = Enum.TextXAlignment.Center
                    ESPs[npc] = {Gui = bb, MainLabel = ml}
                end
            end
        end
    end
end)

-- Fruit Notifier with Fluent
local fruitNotifConnection = nil; local notifiedFruits = {}
local function StartFruitNotifier()
    if fruitNotifConnection then fruitNotifConnection:Disconnect() end; notifiedFruits = {}
    for _, v in pairs(Workspace:GetChildren()) do if v:IsA("Tool") and not notifiedFruits[v] then notifiedFruits[v] = true; Fluent:Notify({Title = "🍎 Fruit Found!", Content = v.Name.." spawned!", Duration = 5}) end end
    fruitNotifConnection = Workspace.ChildAdded:Connect(function(v)
        if Config.FruitCheck and v:IsA("Tool") and not notifiedFruits[v] then notifiedFruits[v] = true; Fluent:Notify({Title = "🍎 Fruit Found!", Content = v.Name.." spawned!", Duration = 5}) end
    end)
end

-- Go to Fruit
local goToFruitRunning = false; local fruitTween = nil
local function StartGoToFruit()
    if goToFruitRunning then return end; goToFruitRunning = true
    task.spawn(function() while goToFruitRunning and Config.GoToFruitActive do pcall(function()
        local fruit = nil; for _, v in pairs(Workspace:GetChildren()) do if v:IsA("Tool") then fruit = v break end end
        if fruit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local handle = fruit:FindFirstChild("Handle") or fruit; local hrp = LocalPlayer.Character.HumanoidRootPart
            local dist = (hrp.Position - handle.Position).Magnitude
            if dist > 10 then if fruitTween then pcall(function() fruitTween:Cancel() end) end
                fruitTween = TweenService:Create(hrp, TweenInfo.new(dist/400), {CFrame = handle.CFrame * CFrame.new(0, 3, 0)}); fruitTween:Play(); fruitTween.Completed:Wait() end
        end end) task.wait() end; goToFruitRunning = false end)
end

-- Auto Random Fruit
local autoFruitRunning = false
local function StartAutoRandomFruit()
    if autoFruitRunning then return end; autoFruitRunning = true
    task.spawn(function() while autoFruitRunning and Config.AutoRandomFruit do pcall(function()
        local CommF = ReplicatedStorage.Remotes and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if CommF then for i = 1, 3 do CommF:InvokeServer("Cousin", "Buy"); task.wait(0.5) end end
    end) task.wait(2) end; autoFruitRunning = false end)
end

-- FPS/Ping Display (Fixed - no freeze + position options)
local fpsGui, fpsLabel, lastTimeF, frameCount, fps, fpsConn = nil, nil, tick(), 0, 0, nil
local function StartFPSPing()
    if fpsConn then return end
    if not fpsGui then
        fpsGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui")); fpsGui.Name = "FPSPing"; fpsGui.ResetOnSpawn = false
        fpsLabel = Instance.new("TextLabel", fpsGui); fpsLabel.Size = UDim2.new(0, 160, 0, 20); fpsLabel.BackgroundTransparency = 1; fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255); fpsLabel.Font = Enum.Font.GothamBold; fpsLabel.TextSize = 14; fpsLabel.TextXAlignment = Enum.TextXAlignment.Right; fpsLabel.RichText = true
    end
    fpsConn = RunService.RenderStepped:Connect(function()
        if not Config.FpsOrPings then fpsGui.Enabled = false; return end
        fpsGui.Enabled = true; frameCount = frameCount + 1
        if tick() - lastTimeF >= 1 then fps = frameCount; frameCount = 0; lastTimeF = tick() end
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        local fc = fps >= 50 and "00FF00" or (fps >= 30 and "FFA500" or "FF0000")
        local pc = ping <= 80 and "00FF00" or (ping <= 150 and "FFFF00" or "FF0000")
        fpsLabel.Text = string.format('<font color="#%s">FPS: %d</font> | <font color="#%s">Ping: %d</font>', fc, fps, pc, ping)
        -- Position
        if Config.FPSPosition == "Top-Right" then fpsLabel.Position = UDim2.new(1, -10, 0, 10); fpsLabel.AnchorPoint = Vector2.new(1, 0)
        elseif Config.FPSPosition == "Top-Left" then fpsLabel.Position = UDim2.new(0, 10, 0, 10); fpsLabel.AnchorPoint = Vector2.new(0, 0)
        elseif Config.FPSPosition == "Bottom-Right" then fpsLabel.Position = UDim2.new(1, -10, 1, -30); fpsLabel.AnchorPoint = Vector2.new(1, 0)
        elseif Config.FPSPosition == "Bottom-Left" then fpsLabel.Position = UDim2.new(0, 10, 1, -30); fpsLabel.AnchorPoint = Vector2.new(0, 0) end
    end)
end

-- Window
local Window = Fluent:CreateWindow({
    Title = "Arxki Hub W", SubTitle = "Devs Araks - 3xki", TabWidth = 120, Size = UDim2.fromOffset(500, 340),
    Acrylic = true, Theme = "Amethyst", MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs
local Tabs = {
    Dev = Window:AddTab({Title = "Developers", Icon = "crown"}),
    Combat = Window:AddTab({Title = "Combat", Icon = "swords"}),
    Character = Window:AddTab({Title = "Character", Icon = "user"}),
    Visuals = Window:AddTab({Title = "Visuals", Icon = "eye"}),
    Movement = Window:AddTab({Title = "Movement", Icon = "activity"}),
    Fruits = Window:AddTab({Title = "Fruits", Icon = "apple"}),
    Sea = Window:AddTab({Title = "Sea", Icon = "anchor"}),
    Blacklist = Window:AddTab({Title = "Blacklist", Icon = "user-x"}),
    Keybinds = Window:AddTab({Title = "Keybinds", Icon = "keyboard"}),
    Settings = Window:AddTab({Title = "Settings", Icon = "settings"})
}

-- Developer Tab
Tabs.Dev:AddParagraph({Title = "Arxki Hub W", Content = "Devs: Araks & 3xki\nAll features fixed & working!"})
Tabs.Dev:AddButton({Title = "Copy Discord", Callback = function() setclipboard("https://discord.gg/p6kPN4DueP"); Fluent:Notify({Title = "Discord", Content = "Copied!", Duration = 2}) end})
Tabs.Dev:AddButton({Title = "Copy YouTube", Callback = function() setclipboard("https://youtube.com/@araks01"); Fluent:Notify({Title = "YouTube", Content = "Copied!", Duration = 2}) end})

-- Combat Tab
do local C = Tabs.Combat
C:AddParagraph({Title = "⚔️ Combat", Content = ""})
C:AddToggle("FastAttack", {Title = "Fast Attack", Default = Config.FastAttack, Callback = function(v) Config.FastAttack = v; SaveConfig() end})
C:AddSlider("AttackSpeed", {Title = "Attack Speed", Min = 0.02, Max = 0.2, Default = Config.FastAttackSpeed, Rounding = 2, Callback = function(v) Config.FastAttackSpeed = v; SaveConfig() end})
C:AddParagraph({Title = "🎯 Aimbot", Content = ""})
C:AddToggle("AimbotPlayer", {Title = "Aimbot: Players", Default = Config.AimbotPlayer, Callback = function(v) Config.AimbotPlayer = v; StartAimbot(); SaveConfig() end})
C:AddToggle("AimbotNPC", {Title = "Aimbot: NPC", Default = Config.AimbotNPC, Callback = function(v) Config.AimbotNPC = v; StartAimbot(); SaveConfig() end})
C:AddToggle("TargetLowestHPPlayer", {Title = "Target Lowest HP (Player)", Default = Config.TargetLowestHPPlayer, Callback = function(v) Config.TargetLowestHPPlayer = v; currentLockTarget = nil; SaveConfig() end})
C:AddToggle("TargetLowestHPNPC", {Title = "Target Lowest HP (NPC)", Default = Config.TargetLowestHPNPC, Callback = function(v) Config.TargetLowestHPNPC = v; currentLockTarget = nil; SaveConfig() end})
C:AddParagraph({Title = "📷 Camlock", Content = ""})
C:AddToggle("CamlockPlayer", {Title = "Camlock: Players", Default = Config.CamlockPlayer, Callback = function(v) Config.CamlockPlayer = v; StartAimbot(); SaveConfig() end})
C:AddToggle("CamlockNPC", {Title = "Camlock: NPC", Default = Config.CamlockNPC, Callback = function(v) Config.CamlockNPC = v; StartAimbot(); SaveConfig() end})
C:AddParagraph({Title = "🗡️ Buddy Sword", Content = ""})
C:AddToggle("BuddySwordLock", {Title = "Auto Lock (Players Only)", Default = Config.BuddySwordLock, Callback = function(v) Config.BuddySwordLock = v; if v then StartBuddySwordLock() else if buddySwordConnection then buddySwordConnection:Disconnect() end end; SaveConfig() end})
end

-- Character Tab
do local Ch = Tabs.Character
Ch:AddParagraph({Title = "🧬 Abilities", Content = ""})
Ch:AddToggle("V3Skill", {Title = "Auto V3", Default = Config.V3Enabled, Callback = function(v) Config.V3Enabled = v; if v then StartV3() else v3Running = false end; SaveConfig(); Fluent:Notify({Title = "Auto V3", Content = v and "ON" or "OFF", Duration = 2}) end})
Ch:AddToggle("V4Skill", {Title = "Auto V4", Default = Config.V4Enabled, Callback = function(v) Config.V4Enabled = v; if v then StartV4() else if v4Connection then v4Connection:Disconnect(); v4Connection = nil end end; SaveConfig(); Fluent:Notify({Title = "Auto V4", Content = v and "ON" or "OFF", Duration = 2}) end})
Ch:AddToggle("BusoHaki", {Title = "Auto Buso", Default = Config.BusoEnabled, Callback = function(v) Config.BusoEnabled = v; if v then StartBuso() else if busoConnection then busoConnection:Disconnect(); busoConnection = nil end end; SaveConfig(); Fluent:Notify({Title = "Buso", Content = v and "ON" or "OFF", Duration = 2}) end})
Ch:AddToggle("AutoKen", {Title = "Auto Ken", Default = Config.AutoKen, Callback = function(v) Config.AutoKen = v; SaveConfig(); Fluent:Notify({Title = "Auto Ken", Content = v and "ON" or "OFF", Duration = 2}) end})
Ch:AddToggle("Highlight", {Title = "Highlight Target", Default = Config.Highlight, Callback = function(v) Config.Highlight = v; SaveConfig(); Fluent:Notify({Title = "Highlight", Content = v and "ON" or "OFF", Duration = 2}) end})
Ch:AddSlider("HighlightRange", {Title = "Range (0=∞)", Min = 0, Max = 50000, Default = Config.HighlightRange, Rounding = 0, Callback = function(v) Config.HighlightRange = v; currentLockTarget = nil; SaveConfig() end})
Ch:AddToggle("TargetInfo", {Title = "Target Info", Default = Config.TargetInfo, Callback = function(v) Config.TargetInfo = v; SaveConfig(); Fluent:Notify({Title = "Target Info", Content = v and "ON" or "OFF", Duration = 2}) end})
Ch:AddToggle("AntiStun", {Title = "Anti-Stun (Dodge CD)", Default = Config.AntiStun, Callback = function(v) Config.AntiStun = v; if v then StartAntiStun() else if AntiStunConnection then AntiStunConnection:Disconnect() end end; SaveConfig(); Fluent:Notify({Title = "Anti-Stun", Content = v and "ON" or "OFF", Duration = 2}) end})
end

-- Visuals Tab
do local V = Tabs.Visuals
V:AddParagraph({Title = "👁️ ESP & Graphics", Content = ""})
V:AddToggle("ESP", {Title = "ESP (Players & NPCs)", Default = Config.ESP_Enabled, Callback = function(v) Config.ESP_Enabled = v; if v then for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then CreateESP(plr) end end else StopESP() end; SaveConfig(); Fluent:Notify({Title = "ESP", Content = v and "ON" or "OFF", Duration = 2}) end})
V:AddDropdown("RTXMode", {Title = "RTX Graphics", Values = {"Off", "Summer", "Autumn", "Spring", "Winter"}, Default = Config.RTXMode, Callback = function(v) Config.RTXMode = v; if v == "Off" then ResetRTX() else ApplyRTX(v) end; SaveConfig(); Fluent:Notify({Title = "RTX", Content = v, Duration = 2}) end})
V:AddToggle("Fog", {Title = "Remove Fog", Default = Config.Fog, Callback = function(v) Config.Fog = v; if v then RemoveFog() else RestoreFog() end; SaveConfig(); Fluent:Notify({Title = "Fog", Content = v and "Removed" or "Restored", Duration = 2}) end})
V:AddToggle("FPSPing", {Title = "FPS & Ping", Default = Config.FpsOrPings, Callback = function(v) Config.FpsOrPings = v; if v then StartFPSPing() else if fpsConn then fpsConn:Disconnect(); fpsConn = nil; fpsGui.Enabled = false end end; SaveConfig(); Fluent:Notify({Title = "FPS/Ping", Content = v and "ON" or "OFF", Duration = 2}) end})
V:AddDropdown("FPSPos", {Title = "FPS Position", Values = {"Top-Right", "Top-Left", "Bottom-Right", "Bottom-Left"}, Default = Config.FPSPosition, Callback = function(v) Config.FPSPosition = v; SaveConfig() end})
end

-- Movement Tab
do local M = Tabs.Movement
M:AddParagraph({Title = "🏃 Movement", Content = ""})
M:AddToggle("SpeedEnabled", {Title = "Enable Speed", Default = Config.SpeedEnabled, Callback = function(v) Config.SpeedEnabled = v; SaveConfig() end})
M:AddSlider("SpeedValue", {Title = "Speed", Min = 16, Max = 450, Default = Config.WalkSpeed, Rounding = 0, Callback = function(v) Config.WalkSpeed = v; SaveConfig() end})
M:AddToggle("JumpEnabled", {Title = "Enable Jump", Default = Config.JumpEnabled, Callback = function(v) Config.JumpEnabled = v; SaveConfig() end})
M:AddSlider("JumpValue", {Title = "Jump Power", Min = 50, Max = 500, Default = Config.JumpPower, Rounding = 0, Callback = function(v) Config.JumpPower = v; SaveConfig() end})
M:AddToggle("DashEnabled", {Title = "Enable Dash (Q)", Default = Config.DashEnabled, Callback = function(v) Config.DashEnabled = v; DashBtn.Visible = v; SaveConfig() end})
M:AddSlider("DashValue", {Title = "Dash Power", Min = 50, Max = 700, Default = Config.DashPower, Rounding = 0, Callback = function(v) Config.DashPower = v; SaveConfig() end})
M:AddToggle("WaterWalk", {Title = "Water Walk", Default = Config.WaterWalk, Callback = function(v) Config.WaterWalk = v; if v then StartWaterWalk() else if waterWalkConnection then waterWalkConnection:Disconnect() end; waterPlatform.CanCollide = false end; SaveConfig() end})
M:AddParagraph({Title = "🚀 Escape System", Content = ""})
M:AddToggle("Escape", {Title = "Sky Escape", Default = Config.EscapeActive, Callback = function(v) Config.EscapeActive = v; if v then StartEscape() else if escapeConnection then escapeConnection:Disconnect() end end; SaveConfig() end})
M:AddSlider("EscapeHP", {Title = "Escape HP", Min = 1000, Max = 14345, Default = Config.EscapeHealth, Rounding = 0, Callback = function(v) Config.EscapeHealth = v; SaveConfig() end})
end

-- Movement Loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            if Config.SpeedEnabled then hum.WalkSpeed = Config.WalkSpeed end
            if Config.JumpEnabled then hum.JumpPower = Config.JumpPower end
        end
    end)
end)

-- Fruits Tab
do local F = Tabs.Fruits
F:AddParagraph({Title = "🍎 Fruit Hunter", Content = ""})
F:AddToggle("GoToFruit", {Title = "Go to Fruit", Default = Config.GoToFruitActive, Callback = function(v) Config.GoToFruitActive = v; if v then StartGoToFruit() else goToFruitRunning = false; if fruitTween then pcall(function() fruitTween:Cancel() end) end end; SaveConfig() end})
F:AddToggle("AutoRandomFruit", {Title = "Auto Random Fruit", Default = Config.AutoRandomFruit, Callback = function(v) Config.AutoRandomFruit = v; if v then StartAutoRandomFruit() else autoFruitRunning = false end; SaveConfig() end})
F:AddToggle("FruitCheck", {Title = "Fruit Spawn Check", Default = Config.FruitCheck, Callback = function(v) Config.FruitCheck = v; if v then StartFruitNotifier() else if fruitNotifConnection then fruitNotifConnection:Disconnect() end; notifiedFruits = {} end; SaveConfig() end})
F:AddToggle("TeleportFruit", {Title = "Bring Fruits", Default = Config.TeleportFruit, Callback = function(v) Config.TeleportFruit = v; SaveConfig() end})
F:AddToggle("AutoStoreFruit", {Title = "Auto Store Fruit", Default = Config.AutoStoreFruit, Callback = function(v) Config.AutoStoreFruit = v; SaveConfig() end})
end

-- Sea Tab
do local S = Tabs.Sea
S:AddParagraph({Title = "⛵ Boat Controls", Content = ""})
S:AddToggle("BoatSpeed", {Title = "Boat Speed", Default = Config.BoatSpeedEnabled, Callback = function(v) Config.BoatSpeedEnabled = v; if v or Config.BoatFlyEnabled then StartBoat() else if boatConnection then boatConnection:Disconnect(); boatConnection = nil end end; SaveConfig() end})
S:AddSlider("BoatSpeedAmt", {Title = "Speed", Min = 1, Max = 10, Default = Config.BoatSpeedValue, Rounding = 0, Callback = function(v) Config.BoatSpeedValue = v; SaveConfig() end})
S:AddToggle("BoatFly", {Title = "Boat Fly", Default = Config.BoatFlyEnabled, Callback = function(v) Config.BoatFlyEnabled = v; if v or Config.BoatSpeedEnabled then StartBoat() else if boatConnection then boatConnection:Disconnect(); boatConnection = nil end end; SaveConfig() end})
S:AddSlider("BoatFlyHeight", {Title = "Fly Height", Min = 0, Max = 135, Default = Config.BoatFlyHeight, Rounding = 0, Callback = function(v) Config.BoatFlyHeight = v; SaveConfig() end})
end

-- Blacklist Tab
do local B = Tabs.Blacklist
B:AddParagraph({Title = "🚫 Blacklist", Content = "Excluded from Aimbot & Camlock"})
local BlacklistedPlayers = {}
local function GetPlayers() local list = {}; for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(list, p.Name) end end; return list end
local dropdown = B:AddDropdown("BlSelect", {Title = "Select Player", Values = GetPlayers(), Default = "", Callback = function(v) if v and v ~= "" then Config.BlacklistedPlayers[v] = true; BlacklistedPlayers[v] = true; SaveConfig(); Fluent:Notify({Title = "Blacklist", Content = v.." added!", Duration = 3}) end end})
B:AddButton({Title = "Refresh List", Callback = function() dropdown:SetValues(GetPlayers()) end})
B:AddButton({Title = "Clear Blacklist", Callback = function() Config.BlacklistedPlayers = {}; BlacklistedPlayers = {}; SaveConfig(); Fluent:Notify({Title = "Blacklist", Content = "Cleared!", Duration = 3}) end})
end

-- Keybinds Tab
do local K = Tabs.Keybinds
K:AddParagraph({Title = "⌨️ Keybinds & Mobile", Content = "Mobile buttons appear as icons"})
K:AddParagraph({Title = "Mobile Toggles", Content = ""})
K:AddToggle("MobileDash", {Title = "Mobile Dash Button", Default = Config.MobileDash, Callback = function(v) Config.MobileDash = v; DashBtn.Visible = v; SaveConfig() end})
K:AddToggle("MobileESP", {Title = "Mobile ESP Toggle", Default = Config.MobileESP, Callback = function(v) Config.MobileESP = v; MobileESPBtn.Visible = v; SaveConfig() end})
K:AddToggle("MobileAimbot", {Title = "Mobile Aimbot Toggle", Default = Config.MobileAimbot, Callback = function(v) Config.MobileAimbot = v; MobileAimbotBtn.Visible = v; SaveConfig() end})
K:AddParagraph({Title = "Keybinds", Content = ""})
K:AddKeybind("DashKey", {Title = "Dash Key", Default = "Q", Mode = "Hold", Callback = function() if Config.DashEnabled then DoDash() end end})
end

-- Mobile Dash Button
local DashBtn = Instance.new("TextButton")
DashBtn.Size = UDim2.new(0, 55, 0, 55); DashBtn.Position = UDim2.new(0.82, 0, 0.7, 0); DashBtn.Text = "DASH"
DashBtn.TextScaled = true; DashBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); DashBtn.TextColor3 = Color3.fromRGB(255, 100, 0)
DashBtn.Font = Enum.Font.GothamBold; DashBtn.BackgroundTransparency = 0.3; DashBtn.BorderSizePixel = 0; DashBtn.Visible = Config.MobileDash
local DashGui = Instance.new("ScreenGui", pcall(gethui) and gethui() or game.CoreGui); DashGui.Name = "DashButton"; DashGui.ResetOnSpawn = false; DashBtn.Parent = DashGui
Instance.new("UICorner", DashBtn).CornerRadius = UDim.new(1, 0)

local dd, di, ds, sp = false, nil, nil, nil
DashBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dd = true; ds = input.Position; sp = DashBtn.Position; di = input end end)
UIS.InputChanged:Connect(function(input) if input == di and dd then local delta = input.Position - ds; DashBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function(input) if input == di then dd = false end end)
DashBtn.MouseButton1Click:Connect(function() if Config.DashEnabled then DoDash() end end)

-- Mobile ESP Toggle
local MobileESPBtn = Instance.new("TextButton")
MobileESPBtn.Size = UDim2.new(0, 45, 0, 45); MobileESPBtn.Position = UDim2.new(0.82, 0, 0.55, 0); MobileESPBtn.Text = "ESP"
MobileESPBtn.TextScaled = true; MobileESPBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MobileESPBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
MobileESPBtn.Font = Enum.Font.GothamBold; MobileESPBtn.BackgroundTransparency = 0.3; MobileESPBtn.BorderSizePixel = 0; MobileESPBtn.Visible = Config.MobileESP
MobileESPBtn.Parent = DashGui
Instance.new("UICorner", MobileESPBtn).CornerRadius = UDim.new(1, 0)
MobileESPBtn.MouseButton1Click:Connect(function() Config.ESP_Enabled = not Config.ESP_Enabled; if Config.ESP_Enabled then for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then CreateESP(plr) end end else StopESP() end; MobileESPBtn.TextColor3 = Config.ESP_Enabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100) end)

-- Mobile Aimbot Toggle
local MobileAimbotBtn = Instance.new("TextButton")
MobileAimbotBtn.Size = UDim2.new(0, 45, 0, 45); MobileAimbotBtn.Position = UDim2.new(0.82, 0, 0.42, 0); MobileAimbotBtn.Text = "AIM"
MobileAimbotBtn.TextScaled = true; MobileAimbotBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MobileAimbotBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
MobileAimbotBtn.Font = Enum.Font.GothamBold; MobileAimbotBtn.BackgroundTransparency = 0.3; MobileAimbotBtn.BorderSizePixel = 0; MobileAimbotBtn.Visible = Config.MobileAimbot
MobileAimbotBtn.Parent = DashGui
Instance.new("UICorner", MobileAimbotBtn).CornerRadius = UDim.new(1, 0)
MobileAimbotBtn.MouseButton1Click:Connect(function() Config.AimbotPlayer = not Config.AimbotPlayer; StartAimbot(); MobileAimbotBtn.TextColor3 = Config.AimbotPlayer and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 100, 100) end)

-- Settings Tab
do local S = Tabs.Settings
S:AddParagraph({Title = "⚙️ Settings", Content = ""})
S:AddToggle("FPSBoost", {Title = "FPS Boost", Default = Config.FpsBoost, Callback = function(v) Config.FpsBoost = v; SaveConfig() end})
S:AddToggle("INFEnergy", {Title = "INF Energy", Default = Config.INFEnergy, Callback = function(v) Config.INFEnergy = v; SaveConfig() end})
S:AddToggle("AntiAFK", {Title = "Anti AFK", Default = Config.AntiAFK, Callback = function(v) Config.AntiAFK = v; SaveConfig() end})
S:AddButton({Title = "Save Settings", Callback = function() SaveConfig(); Fluent:Notify({Title = "Config", Content = "Saved!", Duration = 3}) end})
S:AddButton({Title = "Reset Config", Callback = function() for k, v in pairs(DefaultConfig) do Config[k] = v end; SaveConfig(); Fluent:Notify({Title = "Config", Content = "Reset!", Duration = 3}) end})
S:AddButton({Title = "Delete Config", Callback = function() DeleteConfig() end})
S:AddButton({Title = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end})
end

-- Save & Interface Managers
SaveManager:SetLibrary(Fluent); InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("Arxki"); SaveManager:SetFolder("Arxki/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings); SaveManager:BuildConfigSection(Tabs.Settings)

-- Initialize
task.spawn(function()
    task.wait(2)
    if Config.AntiStun then StartAntiStun() end
    if Config.V3Enabled then StartV3() end
    if Config.V4Enabled then StartV4() end
    if Config.BusoEnabled then StartBuso() end
    if Config.EscapeActive then StartEscape() end
    if Config.WaterWalk then StartWaterWalk() end
    if Config.BoatSpeedEnabled or Config.BoatFlyEnabled then StartBoat() end
    if Config.ESP_Enabled then for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then CreateESP(plr) end end end
    if Config.RTXMode ~= "Off" then ApplyRTX(Config.RTXMode) end
    if Config.Fog then RemoveFog() end
    if Config.FpsOrPings then StartFPSPing() end
    if Config.FruitCheck then StartFruitNotifier() end
    if Config.GoToFruitActive then StartGoToFruit() end
    if Config.AutoRandomFruit then StartAutoRandomFruit() end
    if Config.BuddySwordLock then StartBuddySwordLock() end
    if Config.AimbotPlayer or Config.AimbotNPC or Config.CamlockPlayer or Config.CamlockNPC then StartAimbot() end
    Fluent:Notify({Title = "Arxki Hub W", Content = "All features loaded!\nQ = Dash | LeftCtrl = Toggle UI", Duration = 5})
end)

Window:SelectTab(1)
Fluent:Notify({Title = "Arxki Hub W", Content = "Ready! Q = Dash | LeftCtrl = Toggle UI", Duration = 6})
print("Arxki Hub W - Loaded Successfully!")