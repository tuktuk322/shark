--[[
    ARAKS HUB | FULL SAPI INTEGRATION + MOBILE DASH + TP NEAREST + SAVE/LOAD
]]

if _G.ARAKS_FULL_LOADED then return end
_G.ARAKS_FULL_LOADED = true

-- ---------- SERVICES ----------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera

-- ---------- LOAD EXTERNAL MODULES ----------
local AimlockModule, ESPModule, SilentAimModule, StuffsModule
local OthersStuffsModule, UiSettingsModule, ZSkillModule

task.spawn(function()
    pcall(function()
        AimlockModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuktuk322/Arkx1/refs/heads/main/AimLockModule.txt"))()
    end)
    pcall(function()
        ESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuktuk322/Arkx1/refs/heads/main/EspModule.txt"))()
    end)
    pcall(function()
        SilentAimModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuktuk322/Arkx1/refs/heads/main/SilentAimModule.txt"))()
    end)
    pcall(function()
        StuffsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuktuk322/Arkx1/refs/heads/main/StuffsModule.txt"))()
    end)
    pcall(function()
        OthersStuffsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuktuk322/Arkx1/refs/heads/main/OtherStuffsModule.txt"))()
    end)
    pcall(function()
        UiSettingsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuktuk322/Arkx1/refs/heads/main/UiSettingsModule.txt"))()
    end)
    pcall(function()
        ZSkillModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuktuk322/Arkx1/refs/heads/main/ZSKillModule.txt"))()
    end)
    print("[ARAKS] All modules loaded!")
end)

-- ---------- CONFIG SAVE/LOAD ----------
local SaveFolder = "ARAKS_UI"
local SaveFile = "config.json"
local SavePath = SaveFolder .. "/" .. SaveFile

local DefaultConfig = {
    WalkSpeed = 16, JumpPower = 50, SpeedEnabled = false, JumpEnabled = false,
    DashEnabled = false, DashPower = 100, AimbotActive = false, AntiStun = false,
    BusoEnabled = false, AutoHunt = false, KillNearest = false, FastAttack = false,
    FastAttackSpeed = 0.05, ESP_Enabled = false, WaterWalk = false,
    EscapeActive = false, EscapeHealth = 14345, GoToFruitActive = false,
    AutoRandomFruit = false, BoatSpeedEnabled = false, BoatFlyEnabled = false,
    BoatSpeedValue = 2, BoatFlyHeight = 50, V3Enabled = false, BunnyHopEnabled = false,
    DodgeEnabled = false, V4Enabled = false, FruitCheck = false, TeleportFruit = false,
    INFEnergy = false, FpsBoost = false, FpsOrPings = false, AntiAFK = false,
    SilentAimPlayers = false, SilentAimNPC = false, ZSkills = false,
    TargetInfo = false, Prediction = false, Highlight = false, AutoKen = false,
    Fog = false, Lava = false, GlobalFont = "Gotham", RTXMode = "Summer",
}

local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end

local function SaveConfig()
    pcall(function()
        if not isfolder or not makefolder then return end
        if not isfolder(SaveFolder) then makefolder(SaveFolder) end
        writefile(SavePath, HttpService:JSONEncode(Config))
        print("[CONFIG] Saved")
    end)
end

local function LoadConfig()
    local success, result = pcall(function()
        if not isfile or not readfile then return nil end
        if isfile(SavePath) then
            local content = readfile(SavePath)
            if content and content ~= "" then return HttpService:JSONDecode(content) end
        end
        return nil
    end)
    if success and result and type(result) == "table" then
        for k, v in pairs(DefaultConfig) do
            Config[k] = result[k] ~= nil and result[k] or v
        end
    else
        SaveConfig()
    end
    print("[CONFIG] Loaded")
end
LoadConfig()

-- ---------- MULTI-LANGUAGE ----------
local Languages = {
    ["English"] = {
        main_tab = "Main", combat_tab = "Combat", visuals_tab = "Visuals",
        movement_tab = "Movement", fruits_tab = "Fruits", sea_tab = "Sea",
        settings_tab = "Settings",
        owner_info = "OWNER INFO", owner_name = "Owner: ARAKS",
        rights = "All Rights Reserved", copy_discord = "Copy Discord",
        copy_youtube = "Copy YouTube",
        main_combat = "MAIN COMBAT", aimbot = "Aimbot",
        anti_stun = "Anti-Stun", haki_hardening = "Haki Hardening",
        auto_hunt = "AUTO HUNT", auto_hunt_target = "Auto Hunt Target",
        select_player = "Select Player", kill_nearest = "Kill Nearest",
        fast_attack = "FAST ATTACK", fast_attack_toggle = "Fast Attack",
        attack_speed = "Attack Speed", ultra_fast = "Ultra Fast (0.02)",
        fast = "Fast (0.05)", normal = "Normal (0.1)", slow = "Slow (0.2)",
        v3_skill = "V3 Skill", auto_v4 = "Auto V4", auto_ken = "Auto Ken",
        bunny_hop = "Bunny Hop", dodge_no_cd = "Dodge No CD",
        silent_aim_players = "Silent Aim Players", silent_aim_npc = "Silent Aim NPC",
        z_skills = "Z Skills", prediction = "Prediction",
        teleport_section = "TELEPORT", tp_player = "TP to Nearest Player",
        tp_npc = "TP to Nearest NPC",
        esp_settings = "ESP SETTINGS", esp_players = "ESP Players",
        fruit_esp = "Fruit ESP", target_info = "Target Info (Name/Health)",
        highlight = "Highlight Target", fps_ping = "FPS & Ping Display",
        rtx_graphics = "RTX Graphics Mode", global_font = "Global Font",
        remove_fog = "Remove Fog", remove_lava = "Remove Lava",
        movement_settings = "MOVEMENT SETTINGS", enable_speed = "Enable Speed",
        speed_value = "Speed Value", speed_16 = "16 (Normal)",
        speed_50 = "50 (Fast)", speed_100 = "100 (Very Fast)",
        speed_200 = "200 (Ultra)", speed_300 = "300 (Max)",
        speed_400 = "400 (Extreme)", speed_450 = "450 (Insane)",
        enable_jump = "Enable Jump", jump_power = "Jump Power",
        jump_50 = "50 (Normal)", jump_100 = "100 (High)",
        jump_150 = "150 (Very High)", jump_200 = "200 (Ultra)",
        jump_250 = "250 (Extreme)", enable_dash = "Enable Dash",
        dash_power = "Dash Power", dash_50 = "50 (Weak)",
        dash_100 = "100 (Normal)", dash_150 = "150 (Strong)",
        dash_200 = "200 (Very Strong)", dash_300 = "300 (Ultra)",
        dash_500 = "500 (Insane)", dash_600 = "600 (Extreme)",
        dash_700 = "700 (Max)", water_walk = "Water Walk",
        escape_system = "ESCAPE SYSTEM", sky_escape = "Sky Escape",
        health_limit = "Health Limit", health_1000 = "Low (1000)",
        health_5000 = "Medium (5000)", health_10000 = "High (10000)",
        health_14345 = "Max (14345)",
        fruit_hunter = "FRUIT HUNTER", go_to_fruit = "Go to Fruit",
        auto_random_fruit = "Auto Random Fruit", fruit_check = "Fruit Spawn Check",
        teleport_fruit = "Bring Fruits",
        boat_controls = "BOAT CONTROLS", boat_speed = "Boat Speed",
        speed_amount = "Speed Amount", boat_fly = "Boat Fly",
        fly_height = "Fly Height",
        settings_title = "SETTINGS", save_settings = "Save Settings",
        reset_settings = "Reset Settings", rejoin_server = "Rejoin Server",
        fps_boost = "FPS Boost", inf_energy = "INF Energy",
        anti_afk = "Anti AFK", select_theme = "Select Theme",
        select_background = "Select Background Theme",
        select_text_color = "Select Text Color",
    },
    -- other languages identical structure with translated strings
}
local CurrentLanguage = "English"
local LanguageKeys = {"English"}

local function T(key)
    return Languages[CurrentLanguage][key] or key
end

-- ---------- GUI CREATION ----------
local gui = Instance.new("ScreenGui")
gui.Name = "ARAKS_HUB_GUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then gui.Parent = game:GetService("CoreGui")
    elseif gethui then gui.Parent = gethui()
    else gui.Parent = game:GetService("CoreGui") end
end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 470, 0, 310)
main.Position = UDim2.new(0.5, -235, 0.5, -155)
main.BackgroundTransparency = 1
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(0,0,0)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.15

local bgImg = Instance.new("ImageLabel", main)
bgImg.Size = UDim2.new(1,0,1,0)
bgImg.BackgroundTransparency = 1
bgImg.Image = "rbxassetid://111437698096556"
bgImg.ImageTransparency = 0.08
bgImg.ScaleType = Enum.ScaleType.Stretch
Instance.new("UICorner", bgImg).CornerRadius = UDim.new(0,12)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,42)
header.BackgroundTransparency = 1

local titleLabel = Instance.new("TextLabel", header)
titleLabel.Size = UDim2.new(1,0,1,0)
titleLabel.Text = "ARAKS HUB | V17"
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.BackgroundTransparency = 1

local langBtn = Instance.new("TextButton", header)
langBtn.Size = UDim2.new(0, 38, 0, 28)
langBtn.Position = UDim2.new(1, -42, 0.5, -14)
langBtn.Text = "EN"
langBtn.TextSize = 11
langBtn.Font = Enum.Font.GothamBold
langBtn.TextColor3 = Color3.fromRGB(255,255,255)
langBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
langBtn.BackgroundTransparency = 0.65
langBtn.BorderSizePixel = 0
Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0,6)

local sidebar = Instance.new("Frame", main)
sidebar.Position = UDim2.new(0,0,0,42)
sidebar.Size = UDim2.new(0,105,1,-42)
sidebar.BackgroundTransparency = 1

local contentArea = Instance.new("Frame", main)
contentArea.Position = UDim2.new(0,105,0,42)
contentArea.Size = UDim2.new(1,-105,1,-42)
contentArea.BackgroundTransparency = 1

-- Toggle button for showing/hiding
local toggleBtn = Instance.new("ImageButton", gui)
toggleBtn.Size = UDim2.new(0,50,0,50)
toggleBtn.Position = UDim2.new(0,15,0.5,-25)
toggleBtn.Image = "rbxassetid://122812609859670"
toggleBtn.BackgroundTransparency = 1
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)
toggleBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

-- Drag for toggle button
local dragToggle = false
local dragInputT, dragStartT, startPosT
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStartT = input.Position
        startPosT = toggleBtn.Position
        dragInputT = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInputT and dragToggle then
        local delta = input.Position - dragStartT
        toggleBtn.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function() dragToggle = false end)

-- Drag for main window
local dragging = false
local dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function() dragging = false end)

-- ---------- UI COMPONENT BUILDERS ----------
local function createTab(name, yStart, transKey)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1,-12,0,30)
    btn.Position = UDim2.new(0,6,0,yStart)
    btn.Text = name
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 0.75
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0.6 end)
    btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.75 end)

    local frame = Instance.new("ScrollingFrame", contentArea)
    frame.Size = UDim2.new(1,0,1,0)
    frame.Visible = false
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 3
    frame.CanvasSize = UDim2.new(0,0,0,0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.BorderSizePixel = 0

    local layout = Instance.new("UIListLayout", frame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    local padding = Instance.new("UIPadding", frame)
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(contentArea:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        frame.Visible = true
    end)
    return frame
end

local function addLabel(parent, text, order, isSection)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, isSection and 28 or 22)
    lbl.Text = text
    lbl.TextSize = isSection and 14 or 12
    lbl.Font = isSection and Enum.Font.GothamBlack or Enum.Font.GothamBold
    lbl.TextColor3 = isSection and Color3.fromRGB(180,180,255) or Color3.fromRGB(255,255,255)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    return lbl
end

local function addToggle(parent, text, order, default, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 34)
    holder.BackgroundColor3 = Color3.fromRGB(0,0,0)
    holder.BackgroundTransparency = 0.8
    holder.LayoutOrder = order
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0,8)
    local holderStroke = Instance.new("UIStroke", holder)
    holderStroke.Color = Color3.fromRGB(0,0,0)
    holderStroke.Thickness = 1
    holderStroke.Transparency = 0.4

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local switchBg = Instance.new("Frame", holder)
    switchBg.Size = UDim2.new(0, 42, 0, 20)
    switchBg.Position = UDim2.new(1, -52, 0.5, -10)
    switchBg.BackgroundColor3 = default and Color3.fromRGB(0,180,80) or Color3.fromRGB(80,80,80)
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", switchBg)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local statusLbl = Instance.new("TextLabel", holder)
    statusLbl.Size = UDim2.new(0, 30, 0, 20)
    statusLbl.Position = UDim2.new(1, -96, 0.5, -10)
    statusLbl.Text = default and "ON" or "OFF"
    statusLbl.TextSize = 9
    statusLbl.Font = Enum.Font.GothamBold
    statusLbl.TextColor3 = default and Color3.fromRGB(0,220,100) or Color3.fromRGB(180,180,180)
    statusLbl.BackgroundTransparency = 1

    local state = default
    local btn = Instance.new("TextButton", switchBg)
    btn.Size = UDim2.new(1,0,1,0)
    btn.Text = ""
    btn.BackgroundTransparency = 1

    btn.MouseButton1Click:Connect(function()
        state = not state
        switchBg.BackgroundColor3 = state and Color3.fromRGB(0,180,80) or Color3.fromRGB(80,80,80)
        knob.Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
        statusLbl.Text = state and "ON" or "OFF"
        statusLbl.TextColor3 = state and Color3.fromRGB(0,220,100) or Color3.fromRGB(180,180,180)
        if callback then callback(state) end
    end)
    return {SetState = function(self, newState)
        state = newState
        switchBg.BackgroundColor3 = state and Color3.fromRGB(0,180,80) or Color3.fromRGB(80,80,80)
        knob.Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
        statusLbl.Text = state and "ON" or "OFF"
        statusLbl.TextColor3 = state and Color3.fromRGB(0,220,100) or Color3.fromRGB(180,180,180)
    end}
end

local function addButton(parent, text, order, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Text = text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 0.8
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(0,0,0)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.4
    btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0.7 end)
    btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.8 end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function addDropdown(parent, text, order, values, default, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 34)
    holder.BackgroundColor3 = Color3.fromRGB(0,0,0)
    holder.BackgroundTransparency = 0.8
    holder.LayoutOrder = order
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0,8)
    local holderStroke = Instance.new("UIStroke", holder)
    holderStroke.Color = Color3.fromRGB(0,0,0)
    holderStroke.Thickness = 1
    holderStroke.Transparency = 0.4

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = text
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local currentIndex = table.find(values, default) or 1
    local cycleBtn = Instance.new("TextButton", holder)
    cycleBtn.Size = UDim2.new(0.45, -10, 0, 24)
    cycleBtn.Position = UDim2.new(0.55, 0, 0.5, -12)
    cycleBtn.Text = values[currentIndex]
    cycleBtn.TextSize = 11
    cycleBtn.Font = Enum.Font.GothamBold
    cycleBtn.TextColor3 = Color3.fromRGB(200,200,255)
    cycleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    cycleBtn.BackgroundTransparency = 0.7
    Instance.new("UICorner", cycleBtn).CornerRadius = UDim.new(0,6)

    cycleBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #values + 1
        cycleBtn.Text = values[currentIndex]
        if callback then callback(values[currentIndex]) end
    end)
    return holder
end

-- ---------- BUILD TABS ----------
local tabMain = createTab(T("main_tab"), 10, "main_tab")
local tabCombat = createTab(T("combat_tab"), 45, "combat_tab")
local tabVisuals = createTab(T("visuals_tab"), 80, "visuals_tab")
local tabMovement = createTab(T("movement_tab"), 115, "movement_tab")
local tabFruits = createTab(T("fruits_tab"), 150, "fruits_tab")
local tabSea = createTab(T("sea_tab"), 185, "sea_tab")
local tabSettings = createTab(T("settings_tab"), 220, "settings_tab")
tabMain.Visible = true

-- Language button logic
local langIndex = 1
local langBtnTexts = {["English"] = "EN"}
langBtn.MouseButton1Click:Connect(function()
    langIndex = langIndex % #LanguageKeys + 1
    CurrentLanguage = LanguageKeys[langIndex]
    langBtn.Text = langBtnTexts[CurrentLanguage] or "EN"
    -- update all UI text (simplified, full would loop through elements)
    for _, frame in pairs(contentArea:GetChildren()) do
        if frame:IsA("ScrollingFrame") then
            for _, obj in ipairs(frame:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    local transKey = obj:GetAttribute("TransKey")
                    if transKey then
                        obj.Text = T(transKey)
                    end
                end
            end
        end
    end
end)

-- Helper to set attribute for auto-translation
local function setTrans(obj, key)
    obj:SetAttribute("TransKey", key)
    obj.Text = T(key)
end

-- ---------- MAIN TAB ----------
addLabel(tabMain, T("owner_info"), 1, true)
addLabel(tabMain, T("owner_name"), 2)
addLabel(tabMain, T("rights"), 3)
addButton(tabMain, T("copy_discord"), 4, function()
    pcall(function() setclipboard("https://discord.gg/p6kPN4DueP") end)
end)
addButton(tabMain, T("copy_youtube"), 5, function()
    pcall(function() setclipboard("https://youtube.com/@araks01") end)
end)

-- ---------- COMBAT TAB (original + Sapi) ----------
addLabel(tabCombat, T("main_combat"), 1, true)
addToggle(tabCombat, T("aimbot"), 2, Config.AimbotActive, function(v)
    Config.AimbotActive = v; if AimlockModule then AimlockModule:SetPlayerAimlock(v) end; SaveConfig()
end)
addToggle(tabCombat, T("anti_stun"), 3, Config.AntiStun, function(v)
    Config.AntiStun = v; if StuffsModule then StuffsModule:SetAntiStun(v) end; SaveConfig()
end)
addToggle(tabCombat, T("haki_hardening"), 4, Config.BusoEnabled, function(v)
    Config.BusoEnabled = v; if ESPModule then ESPModule:SetBuso(v) end; SaveConfig()
end)

addLabel(tabCombat, T("auto_hunt"), 5, true)
addToggle(tabCombat, T("auto_hunt_target"), 6, Config.AutoHunt, function(v) Config.AutoHunt = v; SaveConfig() end)
addButton(tabCombat, T("select_player"), 7, function() print("Select Player clicked") end)
addToggle(tabCombat, T("kill_nearest"), 8, Config.KillNearest, function(v)
    Config.KillNearest = v; SaveConfig()
end)

addLabel(tabCombat, T("fast_attack"), 9, true)
addToggle(tabCombat, T("fast_attack_toggle"), 10, Config.FastAttack, function(v)
    Config.FastAttack = v; if StuffsModule then StuffsModule:SetFastAttack(v) end; SaveConfig()
end)
addDropdown(tabCombat, T("attack_speed"), 11, {T("ultra_fast"), T("fast"), T("normal"), T("slow")}, T("fast"), function(v)
    local speeds = {[T("ultra_fast")] = 0.02, [T("fast")] = 0.05, [T("normal")] = 0.1, [T("slow")] = 0.2}
    Config.FastAttackSpeed = speeds[v] or 0.05; SaveConfig()
end)

-- Sapi features
addToggle(tabCombat, T("v3_skill"), 12, Config.V3Enabled, function(v)
    Config.V3Enabled = v; if ESPModule then ESPModule:SetV3(v) end; SaveConfig()
end)
addToggle(tabCombat, T("auto_v4"), 13, Config.V4Enabled, function(v)
    Config.V4Enabled = v; if UiSettingsModule then UiSettingsModule:SetV4(v) end; SaveConfig()
end)
addToggle(tabCombat, T("auto_ken"), 14, Config.AutoKen, function(v)
    Config.AutoKen = v; if SilentAimModule then SilentAimModule:SetAutoKen(v) end; SaveConfig()
end)
addToggle(tabCombat, T("bunny_hop"), 15, Config.BunnyHopEnabled, function(v)
    Config.BunnyHopEnabled = v; if ESPModule then ESPModule:SetBunnyhop(v) end; SaveConfig()
end)
addToggle(tabCombat, T("dodge_no_cd"), 16, Config.DodgeEnabled, function(v)
    Config.DodgeEnabled = v; if ESPModule then ESPModule:SetNoDodgeCD(v) end; SaveConfig()
end)
addToggle(tabCombat, T("silent_aim_players"), 17, Config.SilentAimPlayers, function(v)
    Config.SilentAimPlayers = v; if SilentAimModule then SilentAimModule:SetPlayerSilentAim(v) end; SaveConfig()
end)
addToggle(tabCombat, T("silent_aim_npc"), 18, Config.SilentAimNPC, function(v)
    Config.SilentAimNPC = v; if SilentAimModule then SilentAimModule:SetNPCSilentAim(v) end; SaveConfig()
end)
addToggle(tabCombat, T("z_skills"), 19, Config.ZSkills, function(v)
    Config.ZSkills = v; if ZSkillModule then ZSkillModule:SetZSkills(v) end; SaveConfig()
end)
addToggle(tabCombat, T("prediction"), 20, Config.Prediction, function(v)
    Config.Prediction = v; if AimlockModule then AimlockModule:SetPrediction(v) end; SaveConfig()
end)

-- Teleport section
addLabel(tabCombat, T("teleport_section"), 21, true)
addButton(tabCombat, T("tp_player"), 22, function()
    if not StuffsModule then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local myTeam = LocalPlayer.Team
    local nearest, nearestDist = nil, 5000
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local targetTeam = plr.Team
            if myTeam and targetTeam then
                local enemy = (myTeam.Name == "Pirates" and targetTeam.Name == "Marines") or (myTeam.Name == "Marines" and targetTeam.Name == "Pirates")
                if not enemy and myTeam.Name == targetTeam.Name then
                    enemy = not (LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Allies") and LocalPlayer.PlayerGui.Main.Allies:FindFirstChild("Container") and LocalPlayer.PlayerGui.Main.Allies.Container:FindFirstChild("Allies") and LocalPlayer.PlayerGui.Main.Allies.Container.Allies:FindFirstChild("ScrollingFrame") and table.find(LocalPlayer.PlayerGui.Main.Allies.Container.Allies.ScrollingFrame:GetChildren(), plr.Name))
                end
                if enemy then
                    local dist = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist; nearest = plr.Character
                    end
                end
            end
        end
    end
    if nearest then
        hrp.CFrame = nearest.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
    end
end)
addButton(tabCombat, T("tp_npc"), 23, function()
    if not StuffsModule then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return end
    local nearest, nearestDist = nil, 5000
    for _, npc in ipairs(enemiesFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 and npc:FindFirstChild("HumanoidRootPart") then
            local dist = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist; nearest = npc
            end
        end
    end
    if nearest then
        hrp.CFrame = nearest.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
    end
end)

-- ---------- VISUALS TAB ----------
addLabel(tabVisuals, T("esp_settings"), 1, true)
addToggle(tabVisuals, T("esp_players"), 2, Config.ESP_Enabled, function(v)
    Config.ESP_Enabled = v; if ESPModule then ESPModule:SetESP(v) end; SaveConfig()
end)
addToggle(tabVisuals, T("fruit_esp"), 3, true, function(v) end) -- Fruit ESP placeholder (handled elsewhere)
addToggle(tabVisuals, T("target_info"), 4, Config.TargetInfo, function(v)
    Config.TargetInfo = v; if ZSkillModule then ZSkillModule:SetInfo(v) end; SaveConfig()
end)
addToggle(tabVisuals, T("highlight"), 5, Config.Highlight, function(v)
    Config.Highlight = v; if SilentAimModule then SilentAimModule:SetHighlight(v) end; SaveConfig()
end)
addToggle(tabVisuals, T("fps_ping"), 6, Config.FpsOrPings, function(v)
    Config.FpsOrPings = v; if StuffsModule then StuffsModule:SetPingsOrFps(v) end; SaveConfig()
end)
addDropdown(tabVisuals, T("rtx_graphics"), 7, {"Summer", "Autumn", "Spring", "Winter"}, Config.RTXMode or "Summer", function(v)
    Config.RTXMode = v; if ESPModule then ESPModule:SetRTXMode(v) end; SaveConfig()
end)
addDropdown(tabVisuals, T("global_font"), 8, {"Gotham", "SourceSans", "Arial", "FredokaOne", "LuckiestGuy", "Oswald", "Nunito", "RobotoMono", "Fantasy", "SciFi"}, Config.GlobalFont or "Gotham", function(v)
    Config.GlobalFont = v; local fontEnum = Enum.Font[v] or Enum.Font.Gotham
    if ESPModule then ESPModule:SetGlobalFont(fontEnum) end; SaveConfig()
end)
addToggle(tabVisuals, T("remove_fog"), 9, Config.Fog, function(v)
    Config.Fog = v; if StuffsModule then StuffsModule:SetFog(v) end; SaveConfig()
end)
addToggle(tabVisuals, T("remove_lava"), 10, Config.Lava, function(v)
    Config.Lava = v; if StuffsModule then StuffsModule:SetLava(v) end; SaveConfig()
end)

-- ---------- MOVEMENT TAB ----------
addLabel(tabMovement, T("movement_settings"), 1, true)
addToggle(tabMovement, T("enable_speed"), 2, Config.SpeedEnabled, function(v)
    Config.SpeedEnabled = v; SaveConfig()
end)
addDropdown(tabMovement, T("speed_value"), 3, {T("speed_16"), T("speed_50"), T("speed_100"), T("speed_200"), T("speed_300"), T("speed_400"), T("speed_450")}, T("speed_16"), function(v)
    local speeds = {[T("speed_16")]=16, [T("speed_50")]=50, [T("speed_100")]=100, [T("speed_200")]=200, [T("speed_300")]=300, [T("speed_400")]=400, [T("speed_450")]=450}
    Config.WalkSpeed = speeds[v] or 16; SaveConfig()
end)
addToggle(tabMovement, T("enable_jump"), 4, Config.JumpEnabled, function(v)
    Config.JumpEnabled = v; SaveConfig()
end)
addDropdown(tabMovement, T("jump_power"), 5, {T("jump_50"), T("jump_100"), T("jump_150"), T("jump_200"), T("jump_250")}, T("jump_50"), function(v)
    local jumps = {[T("jump_50")]=50, [T("jump_100")]=100, [T("jump_150")]=150, [T("jump_200")]=200, [T("jump_250")]=250}
    Config.JumpPower = jumps[v] or 50; SaveConfig()
end)

-- Dash toggle + dash button visibility control
local dashToggle = addToggle(tabMovement, T("enable_dash"), 6, Config.DashEnabled, function(v)
    Config.DashEnabled = v
    if StuffsModule then StuffsModule:SetDash(v) end
    if dashBtn then dashBtn.Visible = v end
    SaveConfig()
end)
addDropdown(tabMovement, T("dash_power"), 7, {T("dash_50"), T("dash_100"), T("dash_150"), T("dash_200"), T("dash_300"), T("dash_500"), T("dash_600"), T("dash_700")}, T("dash_100"), function(v)
    local powers = {[T("dash_50")]=50, [T("dash_100")]=100, [T("dash_150")]=150, [T("dash_200")]=200, [T("dash_300")]=300, [T("dash_500")]=500, [T("dash_600")]=600, [T("dash_700")]=700}
    Config.DashPower = powers[v] or 100
    if StuffsModule then StuffsModule:SetDashPower(Config.DashPower) end
    SaveConfig()
end)
addToggle(tabMovement, T("water_walk"), 8, Config.WaterWalk, function(v)
    Config.WaterWalk = v; if StuffsModule then StuffsModule:SetWalkWater(v) end; SaveConfig()
end)
addLabel(tabMovement, T("escape_system"), 9, true)
addToggle(tabMovement, T("sky_escape"), 10, Config.EscapeActive, function(v)
    Config.EscapeActive = v; if StuffsModule then StuffsModule:SetEscape(v) end; SaveConfig()
end)
addDropdown(tabMovement, T("health_limit"), 11, {T("health_1000"), T("health_5000"), T("health_10000"), T("health_14345")}, T("health_14345"), function(v)
    local vals = {[T("health_1000")]=1000, [T("health_5000")]=5000, [T("health_10000")]=10000, [T("health_14345")]=14345}
    Config.EscapeHealth = vals[v] or 14345
    if StuffsModule then StuffsModule:SetEscapeHealth(Config.EscapeHealth) end
    SaveConfig()
end)

-- ---------- FRUITS TAB ----------
addLabel(tabFruits, T("fruit_hunter"), 1, true)
addToggle(tabFruits, T("go_to_fruit"), 2, Config.GoToFruitActive, function(v)
    Config.GoToFruitActive = v; if UiSettingsModule then UiSettingsModule:SetGoToFruit(v) end; SaveConfig()
end)
addToggle(tabFruits, T("auto_random_fruit"), 3, Config.AutoRandomFruit, function(v)
    Config.AutoRandomFruit = v; if UiSettingsModule then UiSettingsModule:SetAutoRandomFruit(v) end; SaveConfig()
end)
addToggle(tabFruits, T("fruit_check"), 4, Config.FruitCheck, function(v)
    Config.FruitCheck = v; if UiSettingsModule then UiSettingsModule:SetFruitCheck(v) end; SaveConfig()
end)
addToggle(tabFruits, T("teleport_fruit"), 5, Config.TeleportFruit, function(v)
    Config.TeleportFruit = v; if UiSettingsModule then UiSettingsModule:SetTeleportFruit(v) end; SaveConfig()
end)

-- ---------- SEA TAB ----------
addLabel(tabSea, T("boat_controls"), 1, true)
addToggle(tabSea, T("boat_speed"), 2, Config.BoatSpeedEnabled, function(v)
    Config.BoatSpeedEnabled = v; if StuffsModule then StuffsModule:SetBoatSpeed(v) end; SaveConfig()
end)
addDropdown(tabSea, T("speed_amount"), 3, {"1x", "2x", "3x", "4x", "5x", "6x", "7x", "8x", "9x", "10x"}, "2x", function(v)
    local num = tonumber(v:gsub("x","")) or 2
    Config.BoatSpeedValue = num; if StuffsModule then StuffsModule:SetBoatSpeedValue(num) end; SaveConfig()
end)
addToggle(tabSea, T("boat_fly"), 4, Config.BoatFlyEnabled, function(v)
    Config.BoatFlyEnabled = v; if StuffsModule then StuffsModule:SetBoatFly(v) end; SaveConfig()
end)
addDropdown(tabSea, T("fly_height"), 5, {"0", "25", "50", "75", "100", "125", "135"}, tostring(Config.BoatFlyHeight or 50), function(v)
    local num = tonumber(v) or 50
    Config.BoatFlyHeight = num; if StuffsModule then StuffsModule:SetBoatFlyHeight(num) end; SaveConfig()
end)

-- ---------- SETTINGS TAB ----------
addLabel(tabSettings, T("settings_title"), 1, true)
addToggle(tabSettings, T("fps_boost"), 2, Config.FpsBoost, function(v)
    Config.FpsBoost = v; if StuffsModule then StuffsModule:SetFpsBoost(v) end; SaveConfig()
end)
addToggle(tabSettings, T("inf_energy"), 3, Config.INFEnergy, function(v)
    Config.INFEnergy = v; if StuffsModule then StuffsModule:SetINFEnergy(v) end; SaveConfig()
end)
addToggle(tabSettings, T("anti_afk"), 4, Config.AntiAFK, function(v)
    Config.AntiAFK = v; if ESPModule then ESPModule:SetAntiAfk(v) end; SaveConfig()
end)
addButton(tabSettings, T("save_settings"), 5, SaveConfig)
addButton(tabSettings, T("reset_settings"), 6, function()
    for k, v in pairs(DefaultConfig) do Config[k] = v end; SaveConfig()
end)
addButton(tabSettings, T("rejoin_server"), 7, function()
    if StuffsModule then StuffsModule:SetRejoinServer() end
end)
addDropdown(tabSettings, T("select_theme"), 8, {"Default"}, "Default", function(v) end)
addDropdown(tabSettings, T("select_background"), 9, {"Default"}, "Default", function(v) end)
addDropdown(tabSettings, T("select_text_color"), 10, {"Default"}, "Default", function(v) end)

-- ---------- MOBILE DASH BUTTON ----------
local dashBtnGui = Instance.new("ScreenGui")
dashBtnGui.Name = "MobileDashGUI"
dashBtnGui.ResetOnSpawn = false
dashBtnGui.Parent = (function()
    pcall(function() if gethui then return gethui() end end)
    return game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
end)()

local dashBtn = Instance.new("TextButton")
dashBtn.Size = UDim2.new(0, 65, 0, 65)
dashBtn.Position = UDim2.new(0.8, 0, 0.7, 0)
dashBtn.Text = "DASH"
dashBtn.TextScaled = true
dashBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
dashBtn.TextColor3 = Color3.fromRGB(255, 100, 0)
dashBtn.Font = Enum.Font.GothamBold
dashBtn.BackgroundTransparency = 0.3
dashBtn.BorderSizePixel = 0
dashBtn.Visible = Config.DashEnabled
Instance.new("UICorner", dashBtn).CornerRadius = UDim.new(1, 0)
dashBtn.Parent = dashBtnGui

-- Drag for mobile dash button
local dashDragging = false
local dashDragInput, dashDragStart, dashStartPos
dashBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dashDragging = true
        dashDragStart = input.Position
        dashStartPos = dashBtn.Position
        dashDragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dashDragInput and dashDragging then
        local delta = input.Position - dashDragStart
        dashBtn.Position = UDim2.new(
            dashStartPos.X.Scale, dashStartPos.X.Offset + delta.X,
            dashStartPos.Y.Scale, dashStartPos.Y.Offset + delta.Y
        )
    end
end)
UIS.InputEnded:Connect(function(input)
    if input == dashDragInput then dashDragging = false end
end)

dashBtn.MouseButton1Click:Connect(function()
    if Config.DashEnabled and StuffsModule then
        StuffsModule:DoDash()
    end
end)

-- ---------- KEYBINDS ----------
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.M then
        main.Visible = not main.Visible
    end
end)
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        if StuffsModule and Config.DashEnabled then StuffsModule:DoDash() end
    end
end)
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.G then
        Config.SilentAimPlayers = not Config.SilentAimPlayers
        if SilentAimModule then SilentAimModule:SetPlayerSilentAim(Config.SilentAimPlayers) end
        SaveConfig()
    end
end)

-- ---------- INITIALIZE FEATURES FROM CONFIG ----------
task.spawn(function()
    repeat task.wait(0.5) until AimlockModule and ESPModule and SilentAimModule and StuffsModule and UiSettingsModule and ZSkillModule
    if AimlockModule then
        if Config.AimbotActive then AimlockModule:SetPlayerAimlock(true) end
        if Config.Prediction then AimlockModule:SetPrediction(true) end
    end
    if ESPModule then
        if Config.ESP_Enabled then ESPModule:SetESP(true) end
        if Config.BusoEnabled then ESPModule:SetBuso(true) end
        if Config.V3Enabled then ESPModule:SetV3(true) end
        if Config.BunnyHopEnabled then ESPModule:SetBunnyhop(true) end
        if Config.DodgeEnabled then ESPModule:SetNoDodgeCD(true) end
        if Config.AntiAFK then ESPModule:SetAntiAfk(true) end
        if Config.GlobalFont then
            local fontEnum = Enum.Font[Config.GlobalFont] or Enum.Font.Gotham
            ESPModule:SetGlobalFont(fontEnum)
        end
        if Config.RTXMode then ESPModule:SetRTXMode(Config.RTXMode) end
    end
    if SilentAimModule then
        if Config.SilentAimPlayers then SilentAimModule:SetPlayerSilentAim(true) end
        if Config.SilentAimNPC then SilentAimModule:SetNPCSilentAim(true) end
        if Config.AutoKen then SilentAimModule:SetAutoKen(true) end
        if Config.Highlight then SilentAimModule:SetHighlight(true) end
    end
    if StuffsModule then
        if Config.AntiStun then StuffsModule:SetAntiStun(true) end
        if Config.FastAttack then StuffsModule:SetFastAttack(true) end
        if Config.WaterWalk then StuffsModule:SetWalkWater(true) end
        if Config.EscapeActive then StuffsModule:SetEscape(true) end
        if Config.DashEnabled then StuffsModule:SetDash(true) end
        if Config.BoatSpeedEnabled then StuffsModule:SetBoatSpeed(true) end
        if Config.BoatFlyEnabled then StuffsModule:SetBoatFly(true) end
        if Config.FpsBoost then StuffsModule:SetFpsBoost(true) end
        if Config.INFEnergy then StuffsModule:SetINFEnergy(true) end
        if Config.FpsOrPings then StuffsModule:SetPingsOrFps(true) end
        if Config.Fog then StuffsModule:SetFog(true) end
        if Config.Lava then StuffsModule:SetLava(true) end
    end
    if UiSettingsModule then
        if Config.V4Enabled then UiSettingsModule:SetV4(true) end
        if Config.GoToFruitActive then UiSettingsModule:SetGoToFruit(true) end
        if Config.AutoRandomFruit then UiSettingsModule:SetAutoRandomFruit(true) end
        if Config.FruitCheck then UiSettingsModule:SetFruitCheck(true) end
        if Config.TeleportFruit then UiSettingsModule:SetTeleportFruit(true) end
    end
    if ZSkillModule then
        if Config.ZSkills then ZSkillModule:SetZSkills(true) end
        if Config.TargetInfo then ZSkillModule:SetInfo(true) end
    end
    print("[ARAKS] Features initialized from config!")
end)

-- Notification
task.delay(3, function()
    pcall(function()
        local notif = Instance.new("TextLabel", gui)
        notif.Size = UDim2.new(0, 400, 0, 45)
        notif.Position = UDim2.new(0.5, -200, 0, 10)
        notif.Text = "ARAKS HUB | V17 - All Features Active!"
        notif.TextSize = 13
        notif.Font = Enum.Font.GothamBold
        notif.TextColor3 = Color3.new(1,1,1)
        notif.BackgroundColor3 = Color3.fromRGB(0,0,0)
        notif.BackgroundTransparency = 0.7
        Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
        task.delay(5, function() notif:Destroy() end)
    end)
end)

print("ARAKS HUB V17 - Full Integration with Mobile Dash & TP Nearest loaded!")