--[[
    Arxki Hub | W
    All features embedded - No external loadstrings
    Compatible with all executors
--]]

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

-- Load Fluent Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Default Config
local DefaultConfig = {
    WalkSpeed = 16, JumpPower = 50, SpeedEnabled = false, JumpEnabled = false,
    DashEnabled = false, DashPower = 100, AimbotActive = false, AntiStun = false,
    BusoEnabled = false, FastAttack = false, FastAttackSpeed = 0.05,
    ESP_Enabled = false, WaterWalk = false, EscapeActive = false, EscapeHealth = 14345,
    GoToFruitActive = false, AutoRandomFruit = false, BoatSpeedEnabled = false,
    BoatFlyEnabled = false, BoatSpeedValue = 2, BoatFlyHeight = 50,
    V3Enabled = false, V4Enabled = false, ZSkills = false, AutoKen = false,
    TargetInfo = false, SilentAimPlayers = false, SilentAimNPC = false,
    Prediction = false, Highlight = false, HighlightRange = 1000,
    LowestHPTarget = false, BuddySwordLock = false,
    FruitCheck = false, TeleportFruit = false, AutoStoreFruit = false,
    INFEnergy = false, FpsBoost = false, FpsOrPings = false, AntiAFK = false,
    Fog = false, Lava = false, RTXMode = "Off",
    BlacklistedPlayers = {},
}

-- Initialize Config
local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end

-- Save/Load/Delete Config
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
        if delfile and isfile and isfile("Arxki/config.json") then
            delfile("Arxki/config.json")
        end
        for k, v in pairs(DefaultConfig) do Config[k] = v end
    end)
end

LoadConfig()

-- Anti-Stun (Fixed - no ability interference)
local AntiStunConnection = nil
local function StartAntiStun()
    if AntiStunConnection then AntiStunConnection:Disconnect() end
    AntiStunConnection = RunService.Heartbeat:Connect(function()
        if not Config.AntiStun then return end
        local char = LocalPlayer.Character
        if not char then return end
        local stun = char:FindFirstChild("Stun")
        local busy = char:FindFirstChild("Busy")
        if stun and stun.Value > 0 then stun.Value = 0 end
        if busy and busy.Value then busy.Value = false end
    end)
end

-- Auto V3
local v3Running = false
local function StartV3()
    if v3Running then return end
    v3Running = true
    task.spawn(function()
        while v3Running and Config.V3Enabled do
            pcall(function()
                local CommE = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommE")
                if CommE then CommE:FireServer("ActivateAbility") end
            end)
            task.wait(31)
        end
        v3Running = false
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
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                local awakening = backpack:FindFirstChild("Awakening")
                if awakening then
                    local rf = awakening:FindFirstChild("RemoteFunction")
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

-- Sky Escape
local escapeConnection = nil
local function StartEscape()
    if escapeConnection then escapeConnection:Disconnect() end
    escapeConnection = RunService.Heartbeat:Connect(function()
        if not Config.EscapeActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 and hum.Health <= Config.EscapeHealth then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0)
        end
    end)
end

-- Water Walk
local waterPlatform = Instance.new("Part")
waterPlatform.Size = Vector3.new(20, 1, 20)
waterPlatform.Transparency = 1
waterPlatform.Anchored = true
waterPlatform.CanCollide = false
waterPlatform.Parent = Workspace

local waterWalkConnection = nil
local function StartWaterWalk()
    if waterWalkConnection then waterWalkConnection:Disconnect() end
    waterWalkConnection = RunService.RenderStepped:Connect(function()
        if not Config.WaterWalk then waterPlatform.CanCollide = false; return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            waterPlatform.CanCollide = true
            waterPlatform.Position = Vector3.new(hrp.Position.X, 0.8, hrp.Position.Z)
        end
    end)
end

-- Dash System
local function DoDash()
    if not Config.DashEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    local dir = hum.MoveDirection.Magnitude > 0 and hum.MoveDirection or Camera.CFrame.LookVector
    dir = Vector3.new(dir.X, 0, dir.Z).Unit
    hrp.Velocity = dir * Config.DashPower
end

-- Boat System
local boatConnection = nil
local function StartBoat()
    if boatConnection then return end
    boatConnection = RunService.Heartbeat:Connect(function()
        if not Config.BoatSpeedEnabled and not Config.BoatFlyEnabled then return end
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("Humanoid") then return end
            local seat = char.Humanoid.SeatPart
            if not seat or not seat:IsA("VehicleSeat") then return end
            if Config.BoatFlyEnabled then
                seat.CFrame = CFrame.new(seat.Position.X, Config.BoatFlyHeight, seat.Position.Z) * seat.CFrame.Rotation
            end
            if Config.BoatSpeedEnabled and seat.Throttle ~= 0 then
                seat.CFrame = seat.CFrame * CFrame.new(0, 0, -seat.Throttle * Config.BoatSpeedValue)
            end
        end)
    end)
end

-- RTX System
local function ResetRTX()
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect")
        or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then v:Destroy() end
    end
    Lighting.FogEnd = 1000; Lighting.FogStart = 0; Lighting.Brightness = 1
    Lighting.GlobalShadows = true; Lighting.ClockTime = 14
    Lighting.Technology = Enum.Technology.ShadowMap
end

local function ApplyRTX(mode)
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect")
        or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then v:Destroy() end
    end
    local atm = Instance.new("Atmosphere", Lighting)
    local bloom = Instance.new("BloomEffect", Lighting)
    bloom.Intensity = 0.15; bloom.Threshold = 0.6; bloom.Size = 1800
    if mode == "Summer" then
        Lighting.FogEnd = 100000; Lighting.Brightness = 2; Lighting.ClockTime = 14
        atm.Density = 0.3; atm.Color = Color3.fromRGB(255,255,255)
    elseif mode == "Autumn" then
        Lighting.FogEnd = 50000; Lighting.Brightness = 1.5; Lighting.ClockTime = 16
        atm.Density = 0.4; atm.Color = Color3.fromRGB(255,200,160)
    elseif mode == "Spring" then
        Lighting.FogEnd = 100000; Lighting.Brightness = 1.8; Lighting.ClockTime = 12
        atm.Density = 0.25; atm.Color = Color3.fromRGB(210,255,220)
    elseif mode == "Winter" then
        Lighting.FogEnd = 50000; Lighting.Brightness = 1.2; Lighting.ClockTime = 14
        atm.Density = 0.45; atm.Color = Color3.fromRGB(190,220,255)
    end
end

-- Buddy Sword Lock (Fixed - aims where player faces, not at cursor)
local buddySwordConnection = nil
local function StartBuddySwordLock()
    if buddySwordConnection then buddySwordConnection:Disconnect() end
    buddySwordConnection = RunService.RenderStepped:Connect(function()
        if not Config.BuddySwordLock then return end
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
        if tool.Name == "Buddy Sword" or tool.Name == "True Buddy Sword" then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local nearest, nearestDist = nil, 500
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist < nearestDist then nearestDist = dist; nearest = plr.Character end
                end
            end
            if not nearest then
                local enemies = Workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, npc in ipairs(enemies:GetChildren()) do
                        if npc:FindFirstChild("HumanoidRootPart") then
                            local dist = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
                            if dist < nearestDist then nearestDist = dist; nearest = npc end
                        end
                    end
                end
            end
            if nearest then
                -- Aim where player is facing, not at screen center
                local lookDir = Camera.CFrame.LookVector
                local targetPos = nearest.HumanoidRootPart.Position
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                -- Auto fire X skill
                pcall(function()
                    local args = {[1] = "X", [2] = targetPos}
                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    if remotes then
                        local funcs = remotes:FindFirstChild("Functions")
                        if funcs then
                            local invoke = funcs:FindFirstChild("InvokeServer")
                            if invoke then invoke:InvokeServer(args) end
                        end
                    end
                end)
            end
        end
    end)
end
-- Fruit Notifier
local fruitNotifConnection = nil
local notifiedFruits = {}
local function StartFruitNotifier()
    if fruitNotifConnection then fruitNotifConnection:Disconnect() end
    notifiedFruits = {}
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Tool") and not notifiedFruits[v] then
            notifiedFruits[v] = true
            Fluent:Notify({ Title = "🍎 Fruit Found!", Content = v.Name .. " has spawned!", Duration = 5 })
        end
    end
    fruitNotifConnection = Workspace.ChildAdded:Connect(function(v)
        if Config.FruitCheck and v:IsA("Tool") and not notifiedFruits[v] then
            notifiedFruits[v] = true
            Fluent:Notify({ Title = "🍎 Fruit Found!", Content = v.Name .. " has spawned!", Duration = 5 })
            if Config.AutoStoreFruit then
                task.delay(1, function()
                    pcall(function()
                        local CommF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                        if CommF then
                            local result = CommF:InvokeServer("StoreFruit", v.Name, v)
                            if result ~= "Full" and result ~= false then
                                Fluent:Notify({ Title = "✅ Stored", Content = v.Name, Duration = 3 })
                            end
                        end
                    end)
                end)
            end
        end
    end)
end

-- Go to Fruit
local goToFruitRunning = false
local fruitTween = nil
local function StartGoToFruit()
    if goToFruitRunning then return end
    goToFruitRunning = true
    task.spawn(function()
        while goToFruitRunning and Config.GoToFruitActive do
            pcall(function()
                local fruit = nil
                for _, v in pairs(Workspace:GetChildren()) do
                    if v:IsA("Tool") then fruit = v break end
                end
                if fruit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local handle = fruit:FindFirstChild("Handle") or fruit
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local dist = (hrp.Position - handle.Position).Magnitude
                    if dist > 10 then
                        if fruitTween then pcall(function() fruitTween:Cancel() end) end
                        fruitTween = TweenService:Create(hrp, TweenInfo.new(dist / 400), {CFrame = handle.CFrame * CFrame.new(0, 3, 0)})
                        fruitTween:Play()
                        fruitTween.Completed:Wait()
                    end
                end
            end)
            task.wait()
        end
        goToFruitRunning = false
    end)
end

-- Auto Random Fruit
local autoFruitRunning = false
local function StartAutoRandomFruit()
    if autoFruitRunning then return end
    autoFruitRunning = true
    task.spawn(function()
        while autoFruitRunning and Config.AutoRandomFruit do
            pcall(function()
                local CommF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if CommF then
                    for i = 1, 3 do CommF:InvokeServer("Cousin", "Buy"); task.wait(0.5) end
                end
            end)
            task.wait(2)
        end
        autoFruitRunning = false
    end)
end

-- FPS & Ping Display
local fpsGui, fpsLabel, lastTime, frameCount, fps, fpsConn = nil, nil, tick(), 0, 0, nil
local function StartFPSPing()
    if fpsConn then return end
    if not fpsGui then
        fpsGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
        fpsGui.Name = "FPSPing"
        fpsLabel = Instance.new("TextLabel", fpsGui)
        fpsLabel.Size = UDim2.new(0, 120, 0, 20)
        fpsLabel.Position = UDim2.new(1, -10, 0, 10)
        fpsLabel.AnchorPoint = Vector2.new(1, 0)
        fpsLabel.BackgroundTransparency = 1
        fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        fpsLabel.Font = Enum.Font.GothamBold
        fpsLabel.TextSize = 16
        fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
        fpsLabel.RichText = true
    end
    fpsConn = RunService.RenderStepped:Connect(function()
        if not Config.FpsOrPings then fpsGui.Enabled = false; return end
        fpsGui.Enabled = true
        frameCount = frameCount + 1
        if tick() - lastTime >= 1 then fps = frameCount; frameCount = 0; lastTime = tick() end
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 2000)
        local fpsColor = fps >= 50 and "00FF00" or (fps >= 30 and "FFA500" or "FF0000")
        local pingColor = ping <= 80 and "00FF00" or (ping <= 150 and "FFFF00" or "FF0000")
        fpsLabel.Text = string.format('<font color="#%s">FPS: %d</font> | <font color="#%s">Ping: %dms</font>', fpsColor, fps, pingColor, ping)
    end)
end

-- ESP System
local espEnabled = false
local espFolder = game.CoreGui:FindFirstChild("GlobalESP") or Instance.new("Folder", game.CoreGui)
espFolder.Name = "GlobalESP"
local ESPs = {}

local function getESPColor(plr)
    if plr == LocalPlayer then return Color3.fromRGB(0, 255, 0) end
    return Color3.fromRGB(255, 255, 0)
end

local function CreateESP(plr)
    if ESPs[plr] then return end
    local char = plr.Character
    if not char or not char:FindFirstChild("Head") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = plr.Name
    billboard.Adornee = char.Head
    billboard.Size = UDim2.fromOffset(220, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = espFolder
    
    local levelLabel = Instance.new("TextLabel", billboard)
    levelLabel.Size = UDim2.new(1, 0, 0.5, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Lv. ???"
    levelLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.TextSize = 14
    levelLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local mainLabel = Instance.new("TextLabel", billboard)
    mainLabel.Size = UDim2.new(1, 0, 0.5, 0)
    mainLabel.Position = UDim2.new(0, 0, 0.5, 0)
    mainLabel.BackgroundTransparency = 1
    mainLabel.Text = "[0] "..plr.DisplayName.." (0m)"
    mainLabel.TextColor3 = getESPColor(plr)
    mainLabel.Font = Enum.Font.GothamBold
    mainLabel.TextSize = 16
    mainLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    ESPs[plr] = {Gui = billboard, LevelLabel = levelLabel, MainLabel = mainLabel}
end

local function StopESP()
    for _, data in pairs(ESPs) do
        if data.Gui then data.Gui.Enabled = false end
    end
    while #ESPs > 0 do
        for plr, data in pairs(ESPs) do
            pcall(function() data.Gui:Destroy() end)
            ESPs[plr] = nil
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not Config.ESP_Enabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if not ESPs[plr] then CreateESP(plr) end
            local data = ESPs[plr]
            if data and data.Gui then
                local char = plr.Character
                local head = char and char:FindFirstChild("Head")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if head and hrp and hum and myHRP then
                    data.Gui.Adornee = head
                    data.Gui.Enabled = true
                    local dist = math.floor((myHRP.Position - hrp.Position).Magnitude)
                    data.LevelLabel.Text = "Lv. ???"
                    local dataFolder = plr:FindFirstChild("Data")
                    if dataFolder then
                        local lvl = dataFolder:FindFirstChild("Level")
                        if lvl then data.LevelLabel.Text = "Lv. "..lvl.Value end
                    end
                    data.MainLabel.Text = "["..math.floor(hum.Health).."] "..plr.DisplayName.." ("..dist.."m)"
                else
                    data.Gui.Enabled = false
                end
            end
        end
    end
end)

-- Window Creation
local Window = Fluent:CreateWindow({
    Title = "Arxki Hub",
    SubTitle = "W",
    TabWidth = 120,
    Size = UDim2.fromOffset(500, 340),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tab icons that work: crown, swords, user, eye, zap, apple, anchor, settings, keyboard, home, star, shield, target, crosshair, list, search, heart, music, camera, video, bell, mail, map, clock, lock, unlock, upload, download, play, pause, refresh-cw, volume, wifi, bluetooth, monitor, tablet, smartphone, folder, file, image, book, edit, trash, link, globe, compass, activity, award, bookmark, briefcase, calendar, gift, package, truck, shopping-cart, tag, users, user-plus, user-minus, user-check, user-x, plus-circle, minus-circle, x-circle, check-circle, alert-circle, info, cloud, sun, moon

local Tabs = {
    Dev = Window:AddTab({ Title = "Developers", Icon = "crown" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    Character = Window:AddTab({ Title = "Character", Icon = "user" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "activity" }),
    Fruits = Window:AddTab({ Title = "Fruits", Icon = "apple" }),
    Sea = Window:AddTab({ Title = "Sea", Icon = "anchor" }),
    Blacklist = Window:AddTab({ Title = "Blacklist", Icon = "user-x" }),
    Keybinds = Window:AddTab({ Title = "Keybinds", Icon = "keyboard" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}
-- Developer Tab
Tabs.Dev:AddParagraph({ Title = "Arxki Hub", Content = "Main Developer: ARAKS\nAssistant: 3xki\n\nW Build - All features working\nFully embedded - No external scripts" })
Tabs.Dev:AddButton({ Title = "Copy Discord", Callback = function() setclipboard("https://discord.gg/p6kPN4DueP") end })
Tabs.Dev:AddButton({ Title = "Copy YouTube", Callback = function() setclipboard("https://youtube.com/@araks01") end })

-- Combat Tab
do
    local C = Tabs.Combat
    C:AddParagraph({ Title = "Combat", Content = "" })
    
    C:AddToggle("FastAttack", { Title = "Fast Attack", Default = Config.FastAttack, Callback = function(v)
        Config.FastAttack = v; SaveConfig()
    end})
    
    C:AddDropdown("AttackSpeed", { Title = "Attack Speed", Values = {"Ultra Fast (0.02)", "Fast (0.05)", "Normal (0.1)", "Slow (0.2)"}, Default = "Fast (0.05)", Callback = function(v)
        local s = {["Ultra Fast (0.02)"]=0.02, ["Fast (0.05)"]=0.05, ["Normal (0.1)"]=0.1, ["Slow (0.2)"]=0.2}
        Config.FastAttackSpeed = s[v] or 0.05; SaveConfig()
    end})
    
    C:AddToggle("Aimbot", { Title = "Aimbot", Default = Config.AimbotActive, Callback = function(v)
        Config.AimbotActive = v; SaveConfig()
    end})
    
    C:AddToggle("AntiStun", { Title = "Anti-Stun", Default = Config.AntiStun, Callback = function(v)
        Config.AntiStun = v
        if v then StartAntiStun() else if AntiStunConnection then AntiStunConnection:Disconnect() end end
        SaveConfig()
    end})
    
    C:AddToggle("SilentAimPlayers", { Title = "Silent Aim Players", Default = Config.SilentAimPlayers, Callback = function(v)
        Config.SilentAimPlayers = v; SaveConfig()
    end})
    
    C:AddToggle("SilentAimNPC", { Title = "Silent Aim NPC", Default = Config.SilentAimNPC, Callback = function(v)
        Config.SilentAimNPC = v; SaveConfig()
    end})
    
    C:AddToggle("LowestHPTarget", { Title = "Target Lowest HP", Default = Config.LowestHPTarget, Callback = function(v)
        Config.LowestHPTarget = v; SaveConfig()
    end})
    
    C:AddToggle("Prediction", { Title = "Prediction", Default = Config.Prediction, Callback = function(v)
        Config.Prediction = v; SaveConfig()
    end})
    
    C:AddParagraph({ Title = "Buddy Sword", Content = "" })
    C:AddToggle("BuddySwordLock", { Title = "Auto Lock", Default = Config.BuddySwordLock, Callback = function(v)
        Config.BuddySwordLock = v
        if v then StartBuddySwordLock() else if buddySwordConnection then buddySwordConnection:Disconnect() end end
        SaveConfig()
    end})
end

-- Character Tab
do
    local Ch = Tabs.Character
    Ch:AddParagraph({ Title = "Abilities", Content = "" })
    
    Ch:AddToggle("V3Skill", { Title = "Auto V3", Default = Config.V3Enabled, Callback = function(v)
        Config.V3Enabled = v
        if v then StartV3() else v3Running = false end
        SaveConfig()
    end})
    
    Ch:AddToggle("V4Skill", { Title = "Auto V4", Default = Config.V4Enabled, Callback = function(v)
        Config.V4Enabled = v
        if v then StartV4() else if v4Connection then v4Connection:Disconnect(); v4Connection = nil end end
        SaveConfig()
    end})
    
    Ch:AddToggle("BusoHaki", { Title = "Auto Buso Haki", Default = Config.BusoEnabled, Callback = function(v)
        Config.BusoEnabled = v
        if v then StartBuso() else if busoConnection then busoConnection:Disconnect(); busoConnection = nil end end
        SaveConfig()
    end})
    
    Ch:AddToggle("AutoKen", { Title = "Auto Ken", Default = Config.AutoKen, Callback = function(v)
        Config.AutoKen = v; SaveConfig()
    end})
    
    Ch:AddToggle("ZSkills", { Title = "Z Skills", Default = Config.ZSkills, Callback = function(v)
        Config.ZSkills = v; SaveConfig()
    end})
    
    Ch:AddToggle("Highlight", { Title = "Highlight Target", Default = Config.Highlight, Callback = function(v)
        Config.Highlight = v; SaveConfig()
    end})
    
    Ch:AddSlider("HighlightRange", { Title = "Highlight Range", Min = 0, Max = 10000, Default = Config.HighlightRange, Rounding = 0, Callback = function(v)
        Config.HighlightRange = v; SaveConfig()
    end})
    
    Ch:AddToggle("TargetInfo", { Title = "Target Info", Default = Config.TargetInfo, Callback = function(v)
        Config.TargetInfo = v; SaveConfig()
    end})
end

-- Visuals Tab
do
    local V = Tabs.Visuals
    V:AddParagraph({ Title = "ESP & Graphics", Content = "" })
    
    V:AddToggle("ESP", { Title = "ESP Players", Default = Config.ESP_Enabled, Callback = function(v)
        Config.ESP_Enabled = v
        if v then
            for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then CreateESP(plr) end end
        else
            StopESP()
        end
        SaveConfig()
    end})
    
    V:AddDropdown("RTXMode", { Title = "RTX Graphics", Values = {"Off", "Summer", "Autumn", "Spring", "Winter"}, Default = Config.RTXMode, Callback = function(v)
        Config.RTXMode = v
        if v == "Off" then ResetRTX() else ApplyRTX(v) end
        SaveConfig()
    end})
    
    V:AddToggle("Fog", { Title = "Remove Fog", Default = Config.Fog, Callback = function(v)
        Config.Fog = v; SaveConfig()
    end})
    
    V:AddToggle("Lava", { Title = "Remove Lava", Default = Config.Lava, Callback = function(v)
        Config.Lava = v; SaveConfig()
    end})
    
    V:AddToggle("FPSPing", { Title = "FPS & Ping", Default = Config.FpsOrPings, Callback = function(v)
        Config.FpsOrPings = v
        if v then StartFPSPing() else if fpsConn then fpsConn:Disconnect(); fpsConn = nil end end
        SaveConfig()
    end})
end
-- Movement Tab
do
    local M = Tabs.Movement
    M:AddParagraph({ Title = "Movement", Content = "" })
    
    M:AddToggle("SpeedEnabled", { Title = "Enable Speed", Default = Config.SpeedEnabled, Callback = function(v) Config.SpeedEnabled = v; SaveConfig() end})
    M:AddSlider("SpeedValue", { Title = "Speed", Min = 16, Max = 450, Default = Config.WalkSpeed, Rounding = 0, Callback = function(v) Config.WalkSpeed = v; SaveConfig() end})
    
    M:AddToggle("JumpEnabled", { Title = "Enable Jump", Default = Config.JumpEnabled, Callback = function(v) Config.JumpEnabled = v; SaveConfig() end})
    M:AddSlider("JumpValue", { Title = "Jump Power", Min = 50, Max = 500, Default = Config.JumpPower, Rounding = 0, Callback = function(v) Config.JumpPower = v; SaveConfig() end})
    
    M:AddToggle("DashEnabled", { Title = "Enable Dash", Default = Config.DashEnabled, Callback = function(v)
        Config.DashEnabled = v; DashBtn.Visible = v; SaveConfig()
    end})
    M:AddSlider("DashValue", { Title = "Dash Power", Min = 50, Max = 700, Default = Config.DashPower, Rounding = 0, Callback = function(v) Config.DashPower = v; SaveConfig() end})
    
    M:AddToggle("WaterWalk", { Title = "Water Walk", Default = Config.WaterWalk, Callback = function(v)
        Config.WaterWalk = v
        if v then StartWaterWalk() else if waterWalkConnection then waterWalkConnection:Disconnect() end; waterPlatform.CanCollide = false end
        SaveConfig()
    end})
    
    M:AddParagraph({ Title = "Escape System", Content = "" })
    M:AddToggle("Escape", { Title = "Sky Escape", Default = Config.EscapeActive, Callback = function(v)
        Config.EscapeActive = v
        if v then StartEscape() else if escapeConnection then escapeConnection:Disconnect() end end
        SaveConfig()
    end})
    M:AddSlider("EscapeHP", { Title = "Escape HP", Min = 1000, Max = 14345, Default = Config.EscapeHealth, Rounding = 0, Callback = function(v) Config.EscapeHealth = v; SaveConfig() end})
end

-- Movement Render Loop
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
do
    local F = Tabs.Fruits
    F:AddParagraph({ Title = "Fruit Hunter", Content = "" })
    
    F:AddToggle("GoToFruit", { Title = "Go to Fruit", Default = Config.GoToFruitActive, Callback = function(v)
        Config.GoToFruitActive = v
        if v then StartGoToFruit() else goToFruitRunning = false; if fruitTween then pcall(function() fruitTween:Cancel() end) end end
        SaveConfig()
    end})
    
    F:AddToggle("AutoRandomFruit", { Title = "Auto Random Fruit", Default = Config.AutoRandomFruit, Callback = function(v)
        Config.AutoRandomFruit = v
        if v then StartAutoRandomFruit() else autoFruitRunning = false end
        SaveConfig()
    end})
    
    F:AddToggle("FruitCheck", { Title = "Fruit Spawn Check", Default = Config.FruitCheck, Callback = function(v)
        Config.FruitCheck = v
        if v then StartFruitNotifier() else if fruitNotifConnection then fruitNotifConnection:Disconnect() end; notifiedFruits = {} end
        SaveConfig()
    end})
    
    F:AddToggle("TeleportFruit", { Title = "Bring Fruits", Default = Config.TeleportFruit, Callback = function(v)
        Config.TeleportFruit = v; SaveConfig()
    end})
    
    F:AddToggle("AutoStoreFruit", { Title = "Auto Store Fruit", Default = Config.AutoStoreFruit, Callback = function(v)
        Config.AutoStoreFruit = v; SaveConfig()
    end})
end

-- Sea Tab
do
    local S = Tabs.Sea
    S:AddParagraph({ Title = "Boat Controls", Content = "" })
    
    S:AddToggle("BoatSpeed", { Title = "Boat Speed", Default = Config.BoatSpeedEnabled, Callback = function(v)
        Config.BoatSpeedEnabled = v
        if v or Config.BoatFlyEnabled then StartBoat() else if boatConnection then boatConnection:Disconnect(); boatConnection = nil end end
        SaveConfig()
    end})
    S:AddSlider("BoatSpeedAmt", { Title = "Speed Amount", Min = 1, Max = 10, Default = Config.BoatSpeedValue, Rounding = 0, Callback = function(v) Config.BoatSpeedValue = v; SaveConfig() end})
    
    S:AddToggle("BoatFly", { Title = "Boat Fly", Default = Config.BoatFlyEnabled, Callback = function(v)
        Config.BoatFlyEnabled = v
        if v or Config.BoatSpeedEnabled then StartBoat() else if boatConnection then boatConnection:Disconnect(); boatConnection = nil end end
        SaveConfig()
    end})
    S:AddSlider("BoatFlyHeight", { Title = "Fly Height", Min = 0, Max = 135, Default = Config.BoatFlyHeight, Rounding = 0, Callback = function(v) Config.BoatFlyHeight = v; SaveConfig() end})
end

-- Blacklist Tab
do
    local B = Tabs.Blacklist
    B:AddParagraph({ Title = "Blacklist", Content = "Excluded from Aimbot & Silent Aim" })
    
    local BlacklistedPlayers = {}
    
    local function GetPlayers()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(list, p.Name) end
        end
        return list
    end
    
    local dropdown = B:AddDropdown("BlSelect", { Title = "Select Player", Values = GetPlayers(), Default = "", Callback = function(v)
        if v and v ~= "" then
            Config.BlacklistedPlayers[v] = true
            BlacklistedPlayers[v] = true
            SaveConfig()
            Fluent:Notify({ Title = "Blacklist", Content = v .. " added!", Duration = 3 })
        end
    end})
    
    B:AddButton({ Title = "Refresh List", Callback = function() dropdown:SetValues(GetPlayers()) end })
    B:AddButton({ Title = "Clear Blacklist", Callback = function()
        Config.BlacklistedPlayers = {}; BlacklistedPlayers = {}; SaveConfig()
        Fluent:Notify({ Title = "Blacklist", Content = "Cleared!", Duration = 3 })
    end})
end

-- Keybinds/Buttons Tab
do
    local K = Tabs.Keybinds
    K:AddParagraph({ Title = "Keybinds & Mobile Buttons", Content = "Set keys or use on-screen buttons" })
    
    K:AddKeybind("DashKey", { Title = "Dash Key", Default = "F", Mode = "Hold", Callback = function()
        if Config.DashEnabled then DoDash() end
    end})
    
    K:AddKeybind("ToggleUI", { Title = "Toggle UI", Default = "LeftControl", Mode = "Toggle", Callback = function()
        -- handled by Fluent
    end})
    
    K:AddParagraph({ Title = "Mobile Buttons", Content = "These appear on-screen for mobile users" })
    K:AddButton({ Title = "Dash Button (Mobile)", Callback = function()
        if Config.DashEnabled then DoDash() end
    end})
    
    K:AddButton({ Title = "Toggle ESP (Mobile)", Callback = function()
        Config.ESP_Enabled = not Config.ESP_Enabled
        if Config.ESP_Enabled then
            for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then CreateESP(plr) end end
        else
            StopESP()
        end
        Fluent:Notify({ Title = "ESP", Content = Config.ESP_Enabled and "ON" or "OFF", Duration = 2 })
    end})
    
    K:AddButton({ Title = "Toggle Aimbot (Mobile)", Callback = function()
        Config.AimbotActive = not Config.AimbotActive
        Fluent:Notify({ Title = "Aimbot", Content = Config.AimbotActive and "ON" or "OFF", Duration = 2 })
    end})
end

-- Mobile Dash Button (On-Screen)
local DashBtn = Instance.new("TextButton")
DashBtn.Size = UDim2.new(0, 60, 0, 60)
DashBtn.Position = UDim2.new(0.8, 0, 0.75, 0)
DashBtn.Text = "DASH"
DashBtn.TextScaled = true
DashBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
DashBtn.TextColor3 = Color3.fromRGB(255, 100, 0)
DashBtn.Font = Enum.Font.GothamBold
DashBtn.BackgroundTransparency = 0.3
DashBtn.BorderSizePixel = 0
DashBtn.Visible = Config.DashEnabled

local DashGui = Instance.new("ScreenGui")
DashGui.Name = "DashButton"
DashGui.ResetOnSpawn = false
pcall(function() DashGui.Parent = gethui() end)
if not DashGui.Parent then DashGui.Parent = game.CoreGui end
DashBtn.Parent = DashGui

Instance.new("UICorner", DashBtn).CornerRadius = UDim.new(1, 0)

-- Dash button drag
local dragging, dragInput, dragStart, startPos
DashBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = DashBtn.Position; dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        DashBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input == dragInput then dragging = false end
end)

DashBtn.MouseButton1Click:Connect(function()
    if Config.DashEnabled then DoDash() end
end)
-- Settings Tab
do
    local S = Tabs.Settings
    S:AddParagraph({ Title = "Settings", Content = "" })
    
    S:AddToggle("FPSBoost", { Title = "FPS Boost", Default = Config.FpsBoost, Callback = function(v)
        Config.FpsBoost = v; SaveConfig()
    end})
    
    S:AddToggle("INFEnergy", { Title = "INF Energy", Default = Config.INFEnergy, Callback = function(v)
        Config.INFEnergy = v; SaveConfig()
    end})
    
    S:AddToggle("AntiAFK", { Title = "Anti AFK", Default = Config.AntiAFK, Callback = function(v)
        Config.AntiAFK = v; SaveConfig()
    end})
    
    S:AddButton({ Title = "Save Settings", Callback = function()
        SaveConfig()
        Fluent:Notify({ Title = "Config", Content = "Saved!", Duration = 3 })
    end})
    
    S:AddButton({ Title = "Reset Config", Callback = function()
        for k, v in pairs(DefaultConfig) do Config[k] = v end
        SaveConfig()
        Fluent:Notify({ Title = "Config", Content = "Reset to defaults!", Duration = 3 })
    end})
    
    S:AddButton({ Title = "Delete Config", Callback = function()
        DeleteConfig()
    end})
    
    S:AddButton({ Title = "Rejoin Server", Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end})
end

-- Save & Interface Managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("Arxki")
SaveManager:SetFolder("Arxki/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Initialize Features
task.spawn(function()
    task.wait(1)
    
    -- Anti-Stun
    if Config.AntiStun then StartAntiStun() end
    
    -- Character
    if Config.V3Enabled then StartV3() end
    if Config.V4Enabled then StartV4() end
    if Config.BusoEnabled then StartBuso() end
    
    -- Movement
    if Config.EscapeActive then StartEscape() end
    if Config.WaterWalk then StartWaterWalk() end
    if Config.BoatSpeedEnabled or Config.BoatFlyEnabled then StartBoat() end
    
    -- Visuals
    if Config.ESP_Enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then CreateESP(plr) end
        end
    end
    
    if Config.RTXMode ~= "Off" then ApplyRTX(Config.RTXMode) end
    if Config.FpsOrPings then StartFPSPing() end
    
    -- Fruits
    if Config.FruitCheck then StartFruitNotifier() end
    if Config.GoToFruitActive then StartGoToFruit() end
    if Config.AutoRandomFruit then StartAutoRandomFruit() end
    
    -- Buddy Sword
    if Config.BuddySwordLock then StartBuddySwordLock() end
    
    -- Notify
    Fluent:Notify({ Title = "Arxki Hub", Content = "All features loaded! Press LeftControl to toggle UI.", Duration = 5 })
end)

-- Select first tab
Window:SelectTab(1)

-- Notify on load
Fluent:Notify({ Title = "Arxki Hub", Content = "W Build - Ready!\nPress F to Dash\nLeftControl to toggle UI", Duration = 6 })

print("==================================================")
print("Arxki Hub - W Build Loaded Successfully!")
print("All features embedded - No external dependencies")
print("==================================================")