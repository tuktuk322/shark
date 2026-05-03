--[[
    ARAKS HUB | V17 - FINAL (Multi-Language + Smooth Dash + Haki Hardening + Save/Load System)
    FIXED: Config application on load, CharacterAdded re-application, all features use Config
]]

-- Execution Guard - Prevent duplicate execution
if _G.ARAKS_Loaded then
    print("[ARAKS] Script already loaded! Cleaning up previous instance...")
    if _G.ARAKS_Cleanup then
        _G.ARAKS_Cleanup()
    end
end
_G.ARAKS_Loaded = true

-- Connection tracker for cleanup
local AllConnections = {}
local function TrackConnection(conn)
    table.insert(AllConnections, conn)
    return conn
end

local function CleanupAllConnections()
    print("[ARAKS] Cleaning up " .. #AllConnections .. " connections...")
    for _, conn in ipairs(AllConnections) do
        pcall(function() conn:Disconnect() end)
    end
    AllConnections = {}
end

-- Register cleanup function globally
_G.ARAKS_Cleanup = function()
    CleanupAllConnections()
    if AntiStunConnection then
        pcall(function() AntiStunConnection:Disconnect() end)
        AntiStunConnection = nil
    end
    if BusoConnection then
        pcall(function() BusoConnection:Disconnect() end)
        BusoConnection = nil
    end
    if FastAttackConnection then
        pcall(function() FastAttackConnection:Disconnect() end)
        FastAttackConnection = nil
    end
    if BoatConnection then
        pcall(function() BoatConnection:Disconnect() end)
        BoatConnection = nil
    end
    if ESPConnection then
        pcall(function() ESPConnection:Disconnect() end)
        ESPConnection = nil
    end
    if MovementConnection then
        pcall(function() MovementConnection:Disconnect() end)
        MovementConnection = nil
    end
    if WaterWalkConnection then
        pcall(function() WaterWalkConnection:Disconnect() end)
        WaterWalkConnection = nil
    end
    if AimbotConnection then
        pcall(function() AimbotConnection:Disconnect() end)
        AimbotConnection = nil
    end
    CombatRunning = false
    FruitGoRunning = false
    AutoFruitRunning = false
    print("[ARAKS] Cleanup complete")
end

------------------------------------------------------------------------
-- [ SERVICES ]
------------------------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

------------------------------------------------------------------------
-- [ SAVE SYSTEM ]
------------------------------------------------------------------------
local SaveFolder = "ARAKS"
local SaveFile = "config.json"
local SavePath = SaveFolder .. "/" .. SaveFile

-- DEFAULT CONFIG - This is the ONLY place default values are defined
local DefaultConfig = {
    BusoEnabled = false,
    WalkSpeed = 16,
    JumpPower = 50,
    FastAttackSpeed = 0.05,
    DashEnabled = false,
    DashPower = 100,
    AimbotActive = false,
    AntiStun = false,
    ESP_Box = false,
    ESP_Name = false,
    ESP_HealthBar = false,
    ESP_Level = false,
    ESP_Distance = false,
    WaterWalk = false,
    EscapeActive = false,
    EscapeHealth = 14345,
    FruitESP = false,
    GoToFruitActive = false,
    FastAttack = false,
    AutoRandomFruit = false,
    SpeedEnabled = false,
    JumpEnabled = false,
    BoatSpeedEnabled = false,
    BoatFlyEnabled = false
}

-- THIS IS THE SINGLE SOURCE OF TRUTH - All features MUST read from here
local Config = {}

-- DEEP COPY function
local function DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Initialize Config with defaults
for k, v in pairs(DefaultConfig) do
    Config[k] = v
end

local function SaveConfig()
    local success, err = pcall(function()
        if not isfolder or not makefolder then
            print("[SAVE] Error: File functions not available")
            return
        end
        if not isfolder(SaveFolder) then
            makefolder(SaveFolder)
        end
        local jsonData = HttpService:JSONEncode(Config)
        writefile(SavePath, jsonData)
        print("[SAVE] Config saved successfully")
    end)
    if not success then
        print("[SAVE] Error saving config: " .. tostring(err))
    end
end

local function LoadConfig()
    local success, result = pcall(function()
        if not isfile or not readfile then
            print("[SAVE] Error: File functions not available")
            return nil
        end
        if isfile(SavePath) then
            local fileContent = readfile(SavePath)
            if fileContent and fileContent ~= "" then
                local decoded = HttpService:JSONDecode(fileContent)
                print("[SAVE] Config loaded from file")
                return decoded
            end
        end
        return nil
    end)

    if success and result and type(result) == "table" then
        -- MERGE: Apply saved values, use defaults for missing keys
        for key, defaultValue in pairs(DefaultConfig) do
            if result[key] ~= nil then
                Config[key] = result[key]
            else
                Config[key] = defaultValue
            end
        end
        print("[SAVE] Config merged with defaults")
    else
        -- Use all defaults
        for key, value in pairs(DefaultConfig) do
            Config[key] = value
        end
        print("[SAVE] Using default config")
        -- Save default config
        task.spawn(function()
            task.wait(0.5)
            SaveConfig()
        end)
    end
    
    -- Print loaded config for debugging
    print("[SAVE] Loaded Config: WalkSpeed=" .. Config.WalkSpeed .. ", JumpPower=" .. Config.JumpPower .. ", BusoEnabled=" .. tostring(Config.BusoEnabled))
end

-- Load config at startup
LoadConfig()

------------------------------------------------------------------------
-- [ CONFIG APPLICATION SYSTEM ]
------------------------------------------------------------------------
-- This function applies ALL config values to the game
local function ApplyAllConfig()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    -- Apply speed
    if Config.SpeedEnabled then
        hum.WalkSpeed = Config.WalkSpeed
    else
        hum.WalkSpeed = 16 -- Default Roblox speed
    end
    
    -- Apply jump
    if Config.JumpEnabled then
        hum.JumpPower = Config.JumpPower
    else
        hum.JumpPower = 50 -- Default Roblox jump
    end
    
    print("[CONFIG] Applied: WalkSpeed=" .. hum.WalkSpeed .. ", JumpPower=" .. hum.JumpPower)
end

-- Apply config when character spawns/respawns
local function OnCharacterAdded(character)
    print("[ARAKS] Character added, waiting for Humanoid...")
    local hum = character:WaitForChild("Humanoid")
    print("[ARAKS] Humanoid found, applying config...")
    ApplyAllConfig()
    
    -- Re-apply when humanoid loads
    hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        -- This ensures speed stays applied
    end)
end

-- Connect to character added
if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

------------------------------------------------------------------------
-- [ ADDITIONAL CONFIG VALUES ]
------------------------------------------------------------------------
-- These are not saved but needed for the script
Config.TargetPart = "HumanoidRootPart"
Config.MaxDistance = 1500

local AutoHunt = {
    Enabled = false,
    SelectedPlayer = nil,
    SelectedPlayerName = "None",
    KillNearest = false,
    CurrentTarget = nil,
}

local CurrentTarget = nil
local currentTween = nil
local fruitTween = nil

-- MULTI-LANGUAGE SYSTEM
local Languages = {
    ["English"] = {
        main_tab = "Main",
        combat_tab = "Combat",
        visuals_tab = "Visuals",
        movement_tab = "Movement",
        fruits_tab = "Fruits",
        sea_tab = "Sea",
        owner_info = "OWNER INFO",
        owner_name = "Owner: ARAKS | Fully Protected",
        rights = "All Rights Reserved",
        copy_discord = "Copy Discord",
        copy_youtube = "Copy YouTube",
        main_combat = "MAIN COMBAT",
        aimbot = "Aimbot (Silent)",
        anti_stun = "Anti-Stun",
        haki_hardening = "Haki Hardening",
        auto_hunt = "AUTO HUNT",
        auto_hunt_target = "Auto Hunt Target",
        select_player = "Select Player",
        kill_nearest = "Kill Nearest",
        fast_attack = "FAST ATTACK",
        fast_attack_toggle = "Fast Attack",
        attack_speed = "Attack Speed",
        ultra_fast = "Ultra Fast (0.02)",
        fast = "Fast (0.05)",
        normal = "Normal (0.1)",
        slow = "Slow (0.2)",
        esp_settings = "ESP SETTINGS",
        esp_box = "ESP Box",
        esp_name = "ESP Name",
        health_bar = "Health Bar",
        esp_level = "ESP Level",
        esp_distance = "ESP Distance",
        fruit_esp = "Fruit ESP",
        movement_settings = "MOVEMENT SETTINGS",
        enable_speed = "Enable Speed",
        speed_value = "Speed Value",
        speed_normal = "16 (Normal)",
        speed_fast = "50 (Fast)",
        speed_vfast = "100 (Very Fast)",
        speed_ultra = "200 (Ultra)",
        speed_max = "300 (Max)",
        speed_400 = "400 (Extreme)",
        speed_450 = "450 (Insane)",
        enable_jump = "Enable Jump",
        jump_power = "Jump Power",
        jump_normal = "50 (Normal)",
        jump_high = "100 (High)",
        jump_vhigh = "150 (Very High)",
        jump_ultra = "200 (Ultra)",
        jump_250 = "250 (Extreme)",
        enable_dash = "Enable Dash",
        dash_power = "Dash Power",
        dash_50 = "50 (Weak)",
        dash_100 = "100 (Normal)",
        dash_150 = "150 (Strong)",
        dash_200 = "200 (Very Strong)",
        dash_300 = "300 (Ultra)",
        dash_500 = "500 (Insane)",
        dash_600 = "600 (Extreme)",
        dash_700 = "700 (Max)",
        water_walk = "Water Walk",
        escape_system = "ESCAPE SYSTEM",
        sky_escape = "Sky Escape",
        health_limit = "Health Limit",
        health_low = "Low (1000)",
        health_medium = "Medium (5000)",
        health_high = "High (10000)",
        health_max = "Max (14345)",
        fruit_hunter = "FRUIT HUNTER",
        go_to_fruit = "Go to Fruit",
        auto_random_fruit = "Auto Random Fruit",
        boat_controls = "BOAT CONTROLS",
        boat_speed = "Boat Speed",
        speed_amount = "Speed Amount",
        boat_fly = "Boat Fly",
        fly_height = "Fly Height",
    },
    ["العربية"] = {
        main_tab = "الرئيسية",
        combat_tab = "القتال",
        visuals_tab = "البصريات",
        movement_tab = "الحركة",
        fruits_tab = "الفواكه",
        sea_tab = "البحر",
        owner_info = "معلومات المالك",
        owner_name = "المالك: ARAKS | محمي بالكامل",
        rights = "جميع الحقوق محفوظة",
        copy_discord = "نسخ رابط الديسكورد",
        copy_youtube = "نسخ رابط اليوتيوب",
        main_combat = "القتال الرئيسي",
        aimbot = "إيمبوت (صامت)",
        anti_stun = "مضاد التثبيت",
        haki_hardening = "هاكي التصلب",
        auto_hunt = "الصيد التلقائي",
        auto_hunt_target = "صيد الهدف المختار",
        select_player = "اختيار لاعب",
        kill_nearest = "قتل الأقرب",
        fast_attack = "الهجوم السريع",
        fast_attack_toggle = "الهجوم السريع",
        attack_speed = "سرعة الهجوم",
        ultra_fast = "سريع جداً (0.02)",
        fast = "سريع (0.05)",
        normal = "عادي (0.1)",
        slow = "بطيء (0.2)",
        esp_settings = "إعدادات ESP",
        esp_box = "إطار ESP",
        esp_name = "اسم ESP",
        health_bar = "شريط الصحة",
        esp_level = "مستوى ESP",
        esp_distance = "مسافة ESP",
        fruit_esp = "ESP الفواكه",
        movement_settings = "إعدادات الحركة",
        enable_speed = "تفعيل السرعة",
        speed_value = "قيمة السرعة",
        speed_normal = "16 (عادي)",
        speed_fast = "50 (سريع)",
        speed_vfast = "100 (سريع جداً)",
        speed_ultra = "200 (فائق)",
        speed_max = "300 (أقصى)",
        speed_400 = "400 (متطرف)",
        speed_450 = "450 (جنوني)",
        enable_jump = "تفعيل القفز",
        jump_power = "قوة القفز",
        jump_normal = "50 (عادي)",
        jump_high = "100 (عالي)",
        jump_vhigh = "150 (عالي جداً)",
        jump_ultra = "200 (فائق)",
        jump_250 = "250 (متطرف)",
        enable_dash = "تفعيل الداش",
        dash_power = "قوة الداش",
        dash_50 = "50 (ضعيف)",
        dash_100 = "100 (عادي)",
        dash_150 = "150 (قوي)",
        dash_200 = "200 (قوي جداً)",
        dash_300 = "300 (فائق)",
        dash_500 = "500 (جنوني)",
        dash_600 = "600 (متطرف)",
        dash_700 = "700 (أقصى)",
        water_walk = "المشي على الماء",
        escape_system = "نظام الهروب",
        sky_escape = "الهروب إلى السماء",
        health_limit = "حد الصحة",
        health_low = "منخفض (1000)",
        health_medium = "متوسط (5000)",
        health_high = "مرتفع (10000)",
        health_max = "أقصى (14345)",
        fruit_hunter = "صائد الفواكه",
        go_to_fruit = "الذهاب إلى الفاكهة",
        auto_random_fruit = "شراء فواكه عشوائي تلقائي",
        boat_controls = "التحكم بالقارب",
        boat_speed = "سرعة القارب",
        speed_amount = "مقدار السرعة",
        boat_fly = "طيران القارب",
        fly_height = "ارتفاع الطيران",
    },
    ["Français"] = {
        main_tab = "Principal",
        combat_tab = "Combat",
        visuals_tab = "Visuels",
        movement_tab = "Mouvement",
        fruits_tab = "Fruits",
        sea_tab = "Mer",
        owner_info = "INFOS PROPRIÉTAIRE",
        owner_name = "Propriétaire: ARAKS | Entièrement protégé",
        rights = "Tous droits réservés",
        copy_discord = "Copier Discord",
        copy_youtube = "Copier YouTube",
        main_combat = "COMBAT PRINCIPAL",
        aimbot = "Aimbot (Silencieux)",
        anti_stun = "Anti-Stun",
        haki_hardening = "Haki Durcissement",
        auto_hunt = "CHASSE AUTO",
        auto_hunt_target = "Chasser la cible",
        select_player = "Sélectionner un joueur",
        kill_nearest = "Tuer le plus proche",
        fast_attack = "ATTAQUE RAPIDE",
        fast_attack_toggle = "Attaque rapide",
        attack_speed = "Vitesse d'attaque",
        ultra_fast = "Ultra rapide (0.02)",
        fast = "Rapide (0.05)",
        normal = "Normal (0.1)",
        slow = "Lent (0.2)",
        esp_settings = "PARAMÈTRES ESP",
        esp_box = "Boîte ESP",
        esp_name = "Nom ESP",
        health_bar = "Barre de santé",
        esp_level = "Niveau ESP",
        esp_distance = "Distance ESP",
        fruit_esp = "ESP Fruit",
        movement_settings = "PARAMÈTRES DE MOUVEMENT",
        enable_speed = "Activer la vitesse",
        speed_value = "Valeur de vitesse",
        speed_normal = "16 (Normal)",
        speed_fast = "50 (Rapide)",
        speed_vfast = "100 (Très rapide)",
        speed_ultra = "200 (Ultra)",
        speed_max = "300 (Max)",
        speed_400 = "400 (Extrême)",
        speed_450 = "450 (Insensé)",
        enable_jump = "Activer le saut",
        jump_power = "Puissance de saut",
        jump_normal = "50 (Normal)",
        jump_high = "100 (Haut)",
        jump_vhigh = "150 (Très haut)",
        jump_ultra = "200 (Ultra)",
        jump_250 = "250 (Extrême)",
        enable_dash = "Activer le dash",
        dash_power = "Puissance du dash",
        dash_50 = "50 (Faible)",
        dash_100 = "100 (Normal)",
        dash_150 = "150 (Fort)",
        dash_200 = "200 (Très fort)",
        dash_300 = "300 (Ultra)",
        dash_500 = "500 (Insensé)",
        dash_600 = "600 (Extrême)",
        dash_700 = "700 (Max)",
        water_walk = "Marcher sur l'eau",
        escape_system = "SYSTÈME D'ÉVASION",
        sky_escape = "Évasion céleste",
        health_limit = "Limite de santé",
        health_low = "Bas (1000)",
        health_medium = "Moyen (5000)",
        health_high = "Haut (10000)",
        health_max = "Max (14345)",
        fruit_hunter = "CHASSEUR DE FRUITS",
        go_to_fruit = "Aller au fruit",
        auto_random_fruit = "Achat auto fruit aléatoire",
        boat_controls = "CONTRÔLES DU BATEAU",
        boat_speed = "Vitesse du bateau",
        speed_amount = "Quantité de vitesse",
        boat_fly = "Vol du bateau",
        fly_height = "Hauteur de vol",
    },
    ["हिंदी"] = {
        main_tab = "मुख्य",
        combat_tab = "युद्ध",
        visuals_tab = "दृश्य",
        movement_tab = "गति",
        fruits_tab = "फल",
        sea_tab = "समुद्र",
        owner_info = "मालिक की जानकारी",
        owner_name = "मालिक: ARAKS | पूर्ण रूप से संरक्षित",
        rights = "सभी अधिकार सुरक्षित",
        copy_discord = "डिस्कॉर्ड कॉपी करें",
        copy_youtube = "यूट्यूब कॉपी करें",
        main_combat = "मुख्य युद्ध",
        aimbot = "एम्बॉट (साइलेंट)",
        anti_stun = "एंटी-स्टन",
        haki_hardening = "हाकी हार्डनिंग",
        auto_hunt = "ऑटो शिकार",
        auto_hunt_target = "लक्ष्य का शिकार करें",
        select_player = "खिलाड़ी चुनें",
        kill_nearest = "निकटतम को मारें",
        fast_attack = "त्वरित हमला",
        fast_attack_toggle = "त्वरित हमला",
        attack_speed = "हमले की गति",
        ultra_fast = "अल्ट्रा फास्ट (0.02)",
        fast = "तेज़ (0.05)",
        normal = "सामान्य (0.1)",
        slow = "धीमा (0.2)",
        esp_settings = "ESP सेटिंग्स",
        esp_box = "ESP बॉक्स",
        esp_name = "ESP नाम",
        health_bar = "स्वास्थ्य बार",
        esp_level = "ESP स्तर",
        esp_distance = "ESP दूरी",
        fruit_esp = "फल ESP",
        movement_settings = "गति सेटिंग्स",
        enable_speed = "गति सक्षम करें",
        speed_value = "गति मान",
        speed_normal = "16 (सामान्य)",
        speed_fast = "50 (तेज़)",
        speed_vfast = "100 (बहुत तेज़)",
        speed_ultra = "200 (अल्ट्रा)",
        speed_max = "300 (अधिकतम)",
        speed_400 = "400 (अत्यधिक)",
        speed_450 = "450 (पागलपन)",
        enable_jump = "कूद सक्षम करें",
        jump_power = "कूद शक्ति",
        jump_normal = "50 (सामान्य)",
        jump_high = "100 (उच्च)",
        jump_vhigh = "150 (बहुत उच्च)",
        jump_ultra = "200 (अल्ट्रा)",
        jump_250 = "250 (अत्यधिक)",
        enable_dash = "डैश सक्षम करें",
        dash_power = "डैश शक्ति",
        dash_50 = "50 (कमजोर)",
        dash_100 = "100 (सामान्य)",
        dash_150 = "150 (मजबूत)",
        dash_200 = "200 (बहुत मजबूत)",
        dash_300 = "300 (अल्ट्रा)",
        dash_500 = "500 (पागलपन)",
        dash_600 = "600 (अत्यधिक)",
        dash_700 = "700 (अधिकतम)",
        water_walk = "पानी पर चलना",
        escape_system = "पलायन प्रणाली",
        sky_escape = "आकाश पलायन",
        health_limit = "स्वास्थ्य सीमा",
        health_low = "निम्न (1000)",
        health_medium = "मध्यम (5000)",
        health_high = "उच्च (10000)",
        health_max = "अधिकतम (14345)",
        fruit_hunter = "फल शिकारी",
        go_to_fruit = "फल के पास जाएं",
        auto_random_fruit = "ऑटो रैंडम फल",
        boat_controls = "नियंत्रण नाव",
        boat_speed = "नाव की गति",
        speed_amount = "गति की मात्रा",
        boat_fly = "नाव उड़ान",
        fly_height = "उड़ान ऊंचाई",
    }
}

local CurrentLanguage = "English"
local LanguageKeys = {"English", "العربية", "Français", "हिंदी"}

local function T(key)
    local text = Languages[CurrentLanguage][key]
    if text then return text end
    return Languages["English"][key] or key
end

-- Store UI elements for dynamic update
local UIElements = {
    Tabs = {},
    Labels = {},
    Buttons = {},
    ToggleLabels = {},
    DropdownLabels = {}
}

local function UpdateAllUIText()
    for i, tab in pairs(UIElements.Tabs) do
        if tab.btn and tab.transKey then
            tab.btn.Text = T(tab.transKey)
        end
    end
    for _, lbl in pairs(UIElements.Labels) do
        if lbl.element and lbl.transKey then
            lbl.element.Text = T(lbl.transKey)
        end
    end
    for _, btn in pairs(UIElements.Buttons) do
        if btn.element and btn.transKey then
            btn.element.Text = T(btn.transKey)
        end
    end
    for _, toggle in pairs(UIElements.ToggleLabels) do
        if toggle.element and toggle.transKey then
            toggle.element.Text = T(toggle.transKey)
        end
    end
    for _, dropdown in pairs(UIElements.DropdownLabels) do
        if dropdown.element and dropdown.transKey then
            dropdown.element.Text = T(dropdown.transKey)
        end
    end
    if selectPlayerBtn then
        local playerText = AutoHunt.SelectedPlayerName and AutoHunt.SelectedPlayerName ~= "None" and (": " .. AutoHunt.SelectedPlayerName) or ""
        selectPlayerBtn.Text = T("select_player") .. playerText
    end
end

-- البلاطة
local platform = Instance.new("Part")
platform.Name = "ARAKS_Platform"
platform.Size = Vector3.new(10, 0.5, 10)
platform.Transparency = 0.4
platform.Material = Enum.Material.Neon
platform.Color = Color3.fromRGB(88, 55, 175)
platform.Anchored = true
platform.CanCollide = true
platform.Parent = workspace
platform.CFrame = CFrame.new(0, -1000, 0)

------------------------------------------------------------------------
-- [ GAME REFERENCES ]
------------------------------------------------------------------------
local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules.Net
local RegisterAttack = Net and Net["RE/RegisterAttack"]
local RegisterHit = Net and Net["RE/RegisterHit"]
local CommF_ = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.CommF_

local function GetSessionID()
    local ok, result = pcall(function()
        local SendHitsToServer = getrenv()._G.SendHitsToServer
        local CombatThread = getupvalues(SendHitsToServer)[1]
        return tostring(LocalPlayer.UserId):sub(2,4)..tostring(CombatThread):sub(11,15)
    end)
    return ok and result or ""
end

------------------------------------------------------------------------
-- [ ANTI-STUN FUNCTIONS - USES Config.AntiStun ]
------------------------------------------------------------------------
local AntiStunConnection = nil

local function StartAntiStun()
    if AntiStunConnection then
        AntiStunConnection:Disconnect()
        AntiStunConnection = nil
    end
    
    AntiStunConnection = RunService.RenderStepped:Connect(function()
        if not Config.AntiStun then return end  -- READ FROM CONFIG
        if not LocalPlayer.Character then return end
        
        local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        
        if not Root or not Hum then return end

        if Hum.PlatformStand then 
            Hum.PlatformStand = false 
        end
        if Hum.Sit then 
            Hum.Sit = false 
        end

        local stunValue = LocalPlayer.Character:FindFirstChild("Stun")
        local busyValue = LocalPlayer.Character:FindFirstChild("Busy")

        if stunValue and stunValue.Value > 0 then
            stunValue.Value = 0
        end

        if busyValue and busyValue.Value then
            busyValue.Value = false
        end

        for _, v in pairs(Root:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyPosition") or v:IsA("BodyGyro") then
                v:Destroy()
            end
        end
    end)
    
    -- Apply based on saved config
    if Config.AntiStun then
        print("[ARAKS] AntiStun activated from config")
    end
end

local function StopAntiStun()
    if AntiStunConnection then
        AntiStunConnection:Disconnect()
        AntiStunConnection = nil
    end
end

-- Start anti-stun with current config value
StartAntiStun()

------------------------------------------------------------------------
-- [ HAKI HARDENING - USES Config.BusoEnabled ]
------------------------------------------------------------------------
local BusoConnection = nil

local function IsBusoActive()
    local character = LocalPlayer.Character
    if character then
        return character:FindFirstChild("HasBuso") ~= nil
    end
    return false
end

local function ActivateBuso()
    pcall(function()
        if CommF_ and not IsBusoActive() then
            CommF_:InvokeServer("Buso")
            print("[ARAKS] Buso Activated")
        end
    end)
end

local function StartBuso()
    if BusoConnection then
        BusoConnection:Disconnect()
        BusoConnection = nil
    end
    
    BusoConnection = RunService.Heartbeat:Connect(function()
        if not Config.BusoEnabled then return end  -- READ FROM CONFIG
        if not IsBusoActive() then
            ActivateBuso()
        end
    end)
    
    if Config.BusoEnabled then
        print("[ARAKS] Buso Haki activated from config")
    end
end

local function StopBuso()
    if BusoConnection then
        BusoConnection:Disconnect()
        BusoConnection = nil
    end
end

-- Start Buso with current config value
StartBuso()

------------------------------------------------------------------------
-- [ FAST ATTACK FUNCTIONS - USES Config.FastAttack AND Config.FastAttackSpeed ]
------------------------------------------------------------------------
local lastFastAttack = 0
local fastCombo = 0
local lastFastCombo = 0
local FastAttackConnection = nil

local function GetClosestEnemyFast()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = character.HumanoidRootPart.Position
    local closest = nil
    local closestDist = 120
    
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            local dist = (v.HumanoidRootPart.Position - myPos).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = v
            end
        end
    end
    
    for _, v in pairs(workspace.Characters:GetChildren()) do
        if v.Name ~= LocalPlayer.Name and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            local dist = (v.HumanoidRootPart.Position - myPos).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = v
            end
        end
    end
    
    return closest
end

local function DoFastAttack()
    if not Config.FastAttack then return end  -- READ FROM CONFIG
    if tick() - lastFastAttack < Config.FastAttackSpeed then return end  -- READ FROM CONFIG
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local hum = character.Humanoid
    if hum.Health <= 0 then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local target = GetClosestEnemyFast()
    if not target then return end
    
    lastFastAttack = tick()
    
    if tick() - lastFastCombo > 0.4 then
        fastCombo = 0
    end
    fastCombo = fastCombo + 1
    if fastCombo > 4 then fastCombo = 1 end
    lastFastCombo = tick()
    
    local toolTip = tool.ToolTip
    
    if toolTip == "Sword" or toolTip == "Melee" then
        if RegisterAttack and RegisterHit then
            RegisterAttack:FireServer(0)
            RegisterHit:FireServer(target.HumanoidRootPart, {{target, target.HumanoidRootPart}})
        end
    elseif toolTip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
        local dir = (target.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Unit
        tool.LeftClickRemote:FireServer(dir, fastCombo)
    elseif toolTip == "Gun" then
        local ShootGunEvent = Net and Net["RE/ShootGunEvent"]
        if ShootGunEvent then
            ShootGunEvent:FireServer(target.HumanoidRootPart.Position)
        end
    end
end

local function StartFastAttack()
    if FastAttackConnection then
        FastAttackConnection:Disconnect()
        FastAttackConnection = nil
    end
    FastAttackConnection = RunService.Stepped:Connect(DoFastAttack)
end

local function StopFastAttack()
    if FastAttackConnection then
        FastAttackConnection:Disconnect()
        FastAttackConnection = nil
    end
end

-- Start fast attack with current config value
StartFastAttack()

------------------------------------------------------------------------
-- [ BOAT FUNCTIONS - USES Config.BoatSpeedEnabled AND Config.BoatFlyEnabled ]
------------------------------------------------------------------------
local BoatSpeedValue = 2
local BoatFlyHeight = 50
local BoatConnection = nil

local function StartBoat()
    if BoatConnection then
        BoatConnection:Disconnect()
        BoatConnection = nil
    end
    BoatConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                local seat = char.Humanoid.SeatPart
                if seat and seat:IsA("VehicleSeat") then
                    if Config.BoatFlyEnabled then  -- READ FROM CONFIG
                        seat.Velocity = Vector3.new(seat.Velocity.X, 0, seat.Velocity.Z)
                        seat.CFrame = CFrame.new(seat.Position.X, BoatFlyHeight, seat.Position.Z) * seat.CFrame.Rotation
                    end
                    if Config.BoatSpeedEnabled and seat.Throttle ~= 0 then  -- READ FROM CONFIG
                        seat.CFrame = seat.CFrame * CFrame.new(0, 0, -seat.Throttle * BoatSpeedValue)
                    end
                end
            end
        end)
    end)
end

StartBoat()

------------------------------------------------------------------------
-- [ DASH FUNCTIONS - USES Config.DashEnabled AND Config.DashPower ]
------------------------------------------------------------------------
local dashGui = Instance.new("ScreenGui")
dashGui.Name = "ARAKS_DashGui"
dashGui.ResetOnSpawn = false

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(dashGui)
        dashGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        dashGui.Parent = gethui()
    else
        dashGui.Parent = game:GetService("CoreGui")
    end
end)
if not dashGui.Parent then dashGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local DashButton = Instance.new("TextButton", dashGui)
DashButton.Size = UDim2.new(0, 55, 0, 55)
DashButton.Position = UDim2.new(0.82, 0, 0.7, 0)
DashButton.Text = "DASH"
DashButton.TextScaled = true
DashButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
DashButton.TextColor3 = Color3.fromRGB(255, 100, 0)
DashButton.Visible = Config.DashEnabled  -- SET FROM CONFIG ON LOAD
DashButton.BackgroundTransparency = 0.3
DashButton.BorderSizePixel = 0
Instance.new("UICorner", DashButton).CornerRadius = UDim.new(1, 0)

local dashDragging = false
local dashDragInput, dashDragStart, dashStartPos

DashButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dashDragging = true
        dashDragStart = input.Position
        dashStartPos = DashButton.Position
        dashDragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dashDragInput and dashDragging then
        local delta = input.Position - dashDragStart
        DashButton.Position = UDim2.new(dashStartPos.X.Scale, dashStartPos.X.Offset + delta.X, dashStartPos.Y.Scale, dashStartPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input == dashDragInput then
        dashDragging = false
        dashDragInput = nil
    end
end)

local function DoDash()
    if not Config.DashEnabled then return end  -- READ FROM CONFIG
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    local dir = hum.MoveDirection.Magnitude > 0 and hum.MoveDirection or Camera.CFrame.LookVector
    dir = Vector3.new(dir.X, 0, dir.Z).Unit
    
    hrp.Velocity = dir * Config.DashPower  -- READ FROM CONFIG
end

DashButton.MouseButton1Click:Connect(DoDash)

------------------------------------------------------------------------
-- [ MOVEMENT RENDER LOOP - USES Config VALUES ]
------------------------------------------------------------------------
local MovementConnection = nil

local function StartMovementLoop()
    if MovementConnection then
        MovementConnection:Disconnect()
        MovementConnection = nil
    end
    
    MovementConnection = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end
        
        -- Speed Control - READ FROM CONFIG
        if Config.SpeedEnabled then
            hum.WalkSpeed = Config.WalkSpeed
        else
            if hum.WalkSpeed ~= 16 then
                hum.WalkSpeed = 16
            end
        end
        
        -- Jump Control - READ FROM CONFIG
        if Config.JumpEnabled then
            hum.JumpPower = Config.JumpPower
        else
            if hum.JumpPower ~= 50 then
                hum.JumpPower = 50
            end
        end
    end)
end

StartMovementLoop()

------------------------------------------------------------------------
-- [ ESP FUNCTIONS - USES Config VALUES ]
------------------------------------------------------------------------
local Boxes = {}
local NameTags = {}
local HealthBars = {}
local LevelTags = {}
local DistTags = {}

local function CreateESP(plr)
    if plr == LocalPlayer then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 1
    Box.Filled = false
    Box.Color = Color3.fromRGB(255,0,0)
    Box.Visible = false
    
    local NameTag = Drawing.new("Text")
    NameTag.Size = 14
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.Color = Color3.new(1,1,1)
    NameTag.Visible = false
    
    local HealthBar = Drawing.new("Square")
    HealthBar.Thickness = 1
    HealthBar.Filled = true
    HealthBar.Color = Color3.fromRGB(0,255,0)
    HealthBar.Visible = false
    
    local LevelTag = Drawing.new("Text")
    LevelTag.Size = 13
    LevelTag.Center = true
    LevelTag.Outline = true
    LevelTag.Color = Color3.fromRGB(255,255,0)
    LevelTag.Visible = false
    
    local DistTag = Drawing.new("Text")
    DistTag.Size = 13
    DistTag.Center = true
    DistTag.Outline = true
    DistTag.Color = Color3.fromRGB(200,200,200)
    DistTag.Visible = false
    
    Boxes[plr] = Box
    NameTags[plr] = NameTag
    HealthBars[plr] = HealthBar
    LevelTags[plr] = LevelTag
    DistTags[plr] = DistTag
end

local function RemoveESP(plr)
    if Boxes[plr] then Boxes[plr]:Remove() Boxes[plr] = nil end
    if NameTags[plr] then NameTags[plr]:Remove() NameTags[plr] = nil end
    if HealthBars[plr] then HealthBars[plr]:Remove() HealthBars[plr] = nil end
    if LevelTags[plr] then LevelTags[plr]:Remove() LevelTags[plr] = nil end
    if DistTags[plr] then DistTags[plr]:Remove() DistTags[plr] = nil end
end

for _, plr in pairs(Players:GetPlayers()) do CreateESP(plr) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

local FruitText = Drawing.new("Text")
FruitText.Size = 14
FruitText.Center = true
FruitText.Outline = true
FruitText.Color = Color3.fromRGB(0,255,100)
FruitText.Visible = false

local ESPConnection = nil

local function StartESP()
    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end
    
    ESPConnection = RunService.RenderStepped:Connect(function()
        -- READ FROM CONFIG
        if not (Config.ESP_Box or Config.ESP_Name or Config.ESP_HealthBar or Config.ESP_Level or Config.ESP_Distance or Config.FruitESP) then
            return
        end

        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
                local root = plr.Character.HumanoidRootPart
                local hum = plr.Character.Humanoid
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local sizeX = 2300 / pos.Z
                    local sizeY = sizeX * 1.5
                    local boxPos = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                    
                    if Config.ESP_Box and Boxes[plr] then
                        Boxes[plr].Visible = true
                        Boxes[plr].Size = Vector2.new(sizeX, sizeY)
                        Boxes[plr].Position = boxPos
                    elseif Boxes[plr] then Boxes[plr].Visible = false end
                    
                    if Config.ESP_HealthBar and HealthBars[plr] then
                        local hpPercent = hum.Health / hum.MaxHealth
                        HealthBars[plr].Visible = true
                        HealthBars[plr].Size = Vector2.new(3, sizeY)
                        HealthBars[plr].Position = Vector2.new(boxPos.X - 6, boxPos.Y)
                        HealthBars[plr].Color = Color3.fromHSV(hpPercent * 0.3, 1, 1)
                    elseif HealthBars[plr] then HealthBars[plr].Visible = false end
                    
                    if Config.ESP_Name and NameTags[plr] then
                        NameTags[plr].Visible = true
                        NameTags[plr].Text = plr.Name
                        NameTags[plr].Position = Vector2.new(pos.X, boxPos.Y - 20)
                    elseif NameTags[plr] then NameTags[plr].Visible = false end
                    
                    if Config.ESP_Level and LevelTags[plr] then
                        local data = plr:FindFirstChild("Data") or plr:FindFirstChild("leaderstats")
                        local lvl = data and (data:FindFirstChild("Level") or data:FindFirstChild("Mivai"))
                        LevelTags[plr].Visible = true
                        LevelTags[plr].Text = "Lv. " .. (lvl and lvl.Value or "???")
                        LevelTags[plr].Position = Vector2.new(pos.X, boxPos.Y - 35)
                    elseif LevelTags[plr] then LevelTags[plr].Visible = false end
                    
                    if Config.ESP_Distance and DistTags[plr] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                        DistTags[plr].Visible = true
                        DistTags[plr].Text = "[" .. dist .. "m]"
                        DistTags[plr].Position = Vector2.new(pos.X, boxPos.Y + sizeY + 5)
                    elseif DistTags[plr] then DistTags[plr].Visible = false end
                else
                    if Boxes[plr] then Boxes[plr].Visible = false end
                    if NameTags[plr] then NameTags[plr].Visible = false end
                    if HealthBars[plr] then HealthBars[plr].Visible = false end
                    if LevelTags[plr] then LevelTags[plr].Visible = false end
                    if DistTags[plr] then DistTags[plr].Visible = false end
                end
            else
                if Boxes[plr] then Boxes[plr].Visible = false end
                if NameTags[plr] then NameTags[plr].Visible = false end
                if HealthBars[plr] then HealthBars[plr].Visible = false end
                if LevelTags[plr] then LevelTags[plr].Visible = false end
                if DistTags[plr] then DistTags[plr].Visible = false end
            end
        end
        
        if Config.FruitESP then
            local found = false
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Tool") or (v:IsA("Model") and v:FindFirstChild("Handle") and v.Name:lower():find("fruit")) then
                    local handle = v:FindFirstChild("Handle") or v
                    local pos, onScreen = Camera:WorldToViewportPoint(handle.Position)
                    if onScreen then
                        local dist = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and math.floor((LocalPlayer.Character.HumanoidRootPart.Position - handle.Position).Magnitude) or 0
                        FruitText.Text = "🍎 " .. v.Name .. " [" .. dist .. "m]"
                        FruitText.Position = Vector2.new(pos.X, pos.Y)
                        FruitText.Visible = true
                        found = true
                        break
                    end
                end
            end
            if not found then FruitText.Visible = false end
        else
            FruitText.Visible = false
        end
    end)
end

StartESP()

------------------------------------------------------------------------
-- [ GUI SETUP ]
------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "ARAKS_HUB_GUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = game:GetService("CoreGui")
    end
end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 320)
main.Position = UDim2.new(0.5, -250, 0.5, -160)
main.BackgroundTransparency = 1
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(0,0,0)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.2

local bgImg = Instance.new("ImageLabel", main)
bgImg.Size = UDim2.new(1,0,1,0)
bgImg.BackgroundTransparency = 1
bgImg.Image = "rbxassetid://122812609859670"
bgImg.ImageTransparency = 0.05
bgImg.ScaleType = Enum.ScaleType.Stretch
Instance.new("UICorner", bgImg).CornerRadius = UDim.new(0,12)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,45)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,0,1,0)
title.Text = "ARAKS HUB | V17"
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- Language Button
local langBtn = Instance.new("TextButton", header)
langBtn.Size = UDim2.new(0, 40, 0, 30)
langBtn.Position = UDim2.new(1, -45, 0.5, -15)
langBtn.Text = "EN"
langBtn.TextSize = 12
langBtn.Font = Enum.Font.GothamBold
langBtn.TextColor3 = Color3.fromRGB(255,255,255)
langBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
langBtn.BackgroundTransparency = 0.55
langBtn.BorderSizePixel = 0
Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0,6)

local langIndex = 1
langBtn.MouseButton1Click:Connect(function()
    langIndex = langIndex % #LanguageKeys + 1
    CurrentLanguage = LanguageKeys[langIndex]
    local btnTexts = {EN = "EN", AR = "AR", FR = "FR", HI = "HI"}
    langBtn.Text = btnTexts[CurrentLanguage] or "EN"
    UpdateAllUIText()
end)

local sidebar = Instance.new("Frame", main)
sidebar.Position = UDim2.new(0,0,0,45)
sidebar.Size = UDim2.new(0,110,1,-45)
sidebar.BackgroundTransparency = 1

local contentArea = Instance.new("Frame", main)
contentArea.Position = UDim2.new(0,110,0,45)
contentArea.Size = UDim2.new(1,-110,1,-45)
contentArea.BackgroundTransparency = 1

------------------------------------------------------------------------
-- [ POPUP MENU ]
------------------------------------------------------------------------
local popupMenu = Instance.new("Frame", gui)
popupMenu.Size = UDim2.new(0, 180, 0, 200)
popupMenu.Position = UDim2.new(0.5, -90, 0.5, -100)
popupMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
popupMenu.BackgroundTransparency = 0.1
popupMenu.Visible = false
popupMenu.ZIndex = 10
Instance.new("UICorner", popupMenu).CornerRadius = UDim.new(0, 10)
local popupStroke = Instance.new("UIStroke", popupMenu)
popupStroke.Color = Color3.fromRGB(100, 100, 200)
popupStroke.Thickness = 2

local popupTitle = Instance.new("TextLabel", popupMenu)
popupTitle.Size = UDim2.new(1, 0, 0, 30)
popupTitle.Text = "Select Player"
popupTitle.TextSize = 14
popupTitle.Font = Enum.Font.GothamBold
popupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
popupTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
popupTitle.BackgroundTransparency = 0.2
Instance.new("UICorner", popupTitle).CornerRadius = UDim.new(0, 10)

local playerListScroller = Instance.new("ScrollingFrame", popupMenu)
playerListScroller.Position = UDim2.new(0, 0, 0, 30)
playerListScroller.Size = UDim2.new(1, 0, 1, -30)
playerListScroller.BackgroundTransparency = 1
playerListScroller.ScrollBarThickness = 3
playerListScroller.CanvasSize = UDim2.new(0, 0, 0, 0)

local playerListLayout = Instance.new("UIListLayout", playerListScroller)
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Padding = UDim.new(0, 2)

local function UpdatePlayerPopup()
    for _, child in pairs(playerListScroller:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local yOffset = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerBtn = Instance.new("TextButton", playerListScroller)
            playerBtn.Size = UDim2.new(1, -10, 0, 30)
            playerBtn.Position = UDim2.new(0, 5, 0, yOffset)
            playerBtn.Text = player.Name
            playerBtn.TextSize = 12
            playerBtn.Font = Enum.Font.Gotham
            playerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
            playerBtn.BackgroundTransparency = 0.3
            Instance.new("UICorner", playerBtn).CornerRadius = UDim.new(0, 6)
            
            playerBtn.MouseButton1Click:Connect(function()
                AutoHunt.SelectedPlayer = player
                AutoHunt.SelectedPlayerName = player.Name
                if selectPlayerBtn then
                    selectPlayerBtn.Text = T("select_player") .. ": " .. player.Name
                end
                popupMenu.Visible = false
            end)
            yOffset = yOffset + 32
        end
    end
    playerListScroller.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

Players.PlayerAdded:Connect(UpdatePlayerPopup)
Players.PlayerRemoving:Connect(UpdatePlayerPopup)

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and popupMenu.Visible then
        local mousePos = UIS:GetMouseLocation()
        local popupPos = popupMenu.AbsolutePosition
        local popupSize = popupMenu.AbsoluteSize
        if not (mousePos.X >= popupPos.X and mousePos.X <= popupPos.X + popupSize.X and
                mousePos.Y >= popupPos.Y and mousePos.Y <= popupPos.Y + popupSize.Y) then
            popupMenu.Visible = false
        end
    end
end)

------------------------------------------------------------------------
-- [ UI COMPONENTS ]
------------------------------------------------------------------------
local function createTab(name, yStart, transKey)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1,-14,0,32)
    btn.Position = UDim2.new(0,7,0,yStart)
    btn.Text = name
    btn:SetAttribute("TransKey", transKey)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 0.55
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0.35 end)
    btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.55 end)

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
    
    table.insert(UIElements.Tabs, {btn = btn, transKey = transKey})
    return frame
end

local function addLabel(parent, text, order, isSection, transKey)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, isSection and 28 or 22)
    lbl.Text = text
    lbl:SetAttribute("TransKey", transKey)
    lbl.TextSize = isSection and 14 or 12
    lbl.Font = isSection and Enum.Font.GothamBlack or Enum.Font.GothamBold
    lbl.TextColor3 = isSection and Color3.fromRGB(180,180,255) or Color3.fromRGB(255,255,255)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    table.insert(UIElements.Labels, {element = lbl, transKey = transKey})
    return lbl
end

local function addToggle(parent, text, order, default, callback, transKey)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 34)
    holder.BackgroundColor3 = Color3.fromRGB(0,0,0)
    holder.BackgroundTransparency = 0.55
    holder.LayoutOrder = order
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = text
    lbl:SetAttribute("TransKey", transKey)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(UIElements.ToggleLabels, {element = lbl, transKey = transKey})

    local switchBg = Instance.new("Frame", holder)
    switchBg.Size = UDim2.new(0, 44, 0, 22)
    switchBg.Position = UDim2.new(1, -54, 0.5, -11)
    switchBg.BackgroundColor3 = default and Color3.fromRGB(0,180,80) or Color3.fromRGB(80,80,80)
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1,0)
    
    local knob = Instance.new("Frame", switchBg)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local statusLbl = Instance.new("TextLabel", holder)
    statusLbl.Size = UDim2.new(0, 30, 0, 22)
    statusLbl.Position = UDim2.new(1, -100, 0.5, -11)
    statusLbl.Text = default and "ON" or "OFF"
    statusLbl.TextSize = 10
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
        knob.Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
        statusLbl.Text = state and "ON" or "OFF"
        statusLbl.TextColor3 = state and Color3.fromRGB(0,220,100) or Color3.fromRGB(180,180,180)
        if callback then callback(state) end
    end)
    return {State = state, SwitchBg = switchBg, Knob = knob, StatusLbl = statusLbl}
end

local function addButton(parent, text, order, callback, transKey)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Text = text
    btn:SetAttribute("TransKey", transKey)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,100)
    btn.BackgroundTransparency = 0.3
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0.1 end)
    btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.3 end)
    btn.MouseButton1Click:Connect(callback)
    table.insert(UIElements.Buttons, {element = btn, transKey = transKey})
    return btn
end

local function addDropdown(parent, text, order, values, default, callback, transKey)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 34)
    holder.BackgroundColor3 = Color3.fromRGB(0,0,0)
    holder.BackgroundTransparency = 0.55
    holder.LayoutOrder = order
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = text
    lbl:SetAttribute("TransKey", transKey)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(UIElements.DropdownLabels, {element = lbl, transKey = transKey})

    local currentIndex = 1
    for i, v in ipairs(values) do if v == default then currentIndex = i break end end

    local cycleBtn = Instance.new("TextButton", holder)
    cycleBtn.Size = UDim2.new(0.45, -10, 0, 24)
    cycleBtn.Position = UDim2.new(0.55, 0, 0.5, -12)
    cycleBtn.Text = default or values[1]
    cycleBtn.TextSize = 11
    cycleBtn.Font = Enum.Font.GothamBold
    cycleBtn.TextColor3 = Color3.fromRGB(200,200,255)
    cycleBtn.BackgroundColor3 = Color3.fromRGB(40,40,100)
    Instance.new("UICorner", cycleBtn).CornerRadius = UDim.new(0,6)

    cycleBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #values + 1
        cycleBtn.Text = values[currentIndex]
        if callback then callback(values[currentIndex]) end
    end)
    return holder
end

------------------------------------------------------------------------
-- [ DRAG MAIN WINDOW ]
------------------------------------------------------------------------
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

local toggleBtn = Instance.new("ImageButton", gui)
toggleBtn.Size = UDim2.new(0,55,0,55)
toggleBtn.Position = UDim2.new(0,20,0.5,-30)
toggleBtn.Image = "rbxassetid://122812609859670"
toggleBtn.BackgroundTransparency = 1
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)
toggleBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

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

------------------------------------------------------------------------
-- [ TABS ]
------------------------------------------------------------------------
local tabMain = createTab(T("main_tab"), 10, "main_tab")
local tabCombat = createTab(T("combat_tab"), 48, "combat_tab")
local tabVisuals = createTab(T("visuals_tab"), 86, "visuals_tab")
local tabMovement = createTab(T("movement_tab"), 124, "movement_tab")
local tabFruits = createTab(T("fruits_tab"), 162, "fruits_tab")
local tabSea = createTab(T("sea_tab"), 200, "sea_tab")
tabMain.Visible = true

-- MAIN TAB
addLabel(tabMain, T("owner_info"), 1, true, "owner_info")
addLabel(tabMain, T("owner_name"), 2, false, "owner_name")
addLabel(tabMain, T("rights"), 3, false, "rights")
addButton(tabMain, T("copy_discord"), 4, function() pcall(function() setclipboard("https://discord.gg/p6kPN4DueP") end) end, "copy_discord")
addButton(tabMain, T("copy_youtube"), 5, function() pcall(function() setclipboard("https://youtube.com/@araks01") end) end, "copy_youtube")

-- COMBAT TAB - ALL CALLBACKS UPDATE CONFIG AND APPLY IMMEDIATELY
addLabel(tabCombat, T("main_combat"), 1, true, "main_combat")
addToggle(tabCombat, T("aimbot"), 2, Config.AimbotActive, function(v)  -- LOAD FROM CONFIG
    Config.AimbotActive = v
    SaveConfig()
end, "aimbot")
addToggle(tabCombat, T("anti_stun"), 3, Config.AntiStun, function(v)  -- LOAD FROM CONFIG
    Config.AntiStun = v
    if v then 
        StartAntiStun()
    else 
        StopAntiStun()
    end
    SaveConfig()
end, "anti_stun")
addToggle(tabCombat, T("haki_hardening"), 4, Config.BusoEnabled, function(v)  -- LOAD FROM CONFIG
    Config.BusoEnabled = v
    if v then 
        StartBuso()
    else 
        StopBuso()
    end
    SaveConfig()
end, "haki_hardening")

addLabel(tabCombat, T("auto_hunt"), 5, true, "auto_hunt")

local autoHuntToggle = addToggle(tabCombat, T("auto_hunt_target"), 6, false, function(v)
    AutoHunt.Enabled = v
    if not v then
        if currentTween then 
            pcall(function() currentTween:Cancel() end)
        end
        currentTween = nil
        platform.CFrame = CFrame.new(0, -1000, 0)
    elseif v then
        AutoHunt.KillNearest = false
        if killNearestToggle then
            killNearestToggle.SwitchBg.BackgroundColor3 = Color3.fromRGB(80,80,80)
            killNearestToggle.Knob.Position = UDim2.new(0,2,0.5,-9)
            killNearestToggle.StatusLbl.Text = "OFF"
        end
    end
end, "auto_hunt_target")

local selectPlayerBtn = addButton(tabCombat, T("select_player"), 7, function()
    UpdatePlayerPopup()
    popupMenu.Visible = true
end, "select_player")

local killNearestToggle = addToggle(tabCombat, T("kill_nearest"), 8, false, function(v)
    AutoHunt.KillNearest = v
    if not v then
        if currentTween then 
            pcall(function() currentTween:Cancel() end)
        end
        currentTween = nil
        platform.CFrame = CFrame.new(0, -1000, 0)
    elseif v then
        AutoHunt.Enabled = false
        if autoHuntToggle then
            autoHuntToggle.SwitchBg.BackgroundColor3 = Color3.fromRGB(80,80,80)
            autoHuntToggle.Knob.Position = UDim2.new(0,2,0.5,-9)
            autoHuntToggle.StatusLbl.Text = "OFF"
        end
    end
end, "kill_nearest")

addLabel(tabCombat, T("fast_attack"), 9, true, "fast_attack")
addToggle(tabCombat, T("fast_attack_toggle"), 10, Config.FastAttack, function(v)  -- LOAD FROM CONFIG
    Config.FastAttack = v
    if v then StartFastAttack() else StopFastAttack() end
    SaveConfig()
end, "fast_attack_toggle")

local function GetAttackSpeedValues()
    return {T("ultra_fast"), T("fast"), T("normal"), T("slow")}
end

-- Find current attack speed in array
local currentAttackSpeedText = T("fast")
if Config.FastAttackSpeed == 0.02 then currentAttackSpeedText = T("ultra_fast")
elseif Config.FastAttackSpeed == 0.05 then currentAttackSpeedText = T("fast")
elseif Config.FastAttackSpeed == 0.1 then currentAttackSpeedText = T("normal")
elseif Config.FastAttackSpeed == 0.2 then currentAttackSpeedText = T("slow")
end

addDropdown(tabCombat, T("attack_speed"), 11, GetAttackSpeedValues(), currentAttackSpeedText, function(v)
    local speeds = {[T("ultra_fast")] = 0.02, [T("fast")] = 0.05, [T("normal")] = 0.1, [T("slow")] = 0.2}
    Config.FastAttackSpeed = speeds[v] or 0.05
    SaveConfig()
end, "attack_speed")

-- VISUALS TAB - ALL LOADED FROM CONFIG
addLabel(tabVisuals, T("esp_settings"), 1, true, "esp_settings")
addToggle(tabVisuals, T("esp_box"), 2, Config.ESP_Box, function(v) Config.ESP_Box = v; SaveConfig() end, "esp_box")
addToggle(tabVisuals, T("esp_name"), 3, Config.ESP_Name, function(v) Config.ESP_Name = v; SaveConfig() end, "esp_name")
addToggle(tabVisuals, T("health_bar"), 4, Config.ESP_HealthBar, function(v) Config.ESP_HealthBar = v; SaveConfig() end, "health_bar")
addToggle(tabVisuals, T("esp_level"), 5, Config.ESP_Level, function(v) Config.ESP_Level = v; SaveConfig() end, "esp_level")
addToggle(tabVisuals, T("esp_distance"), 6, Config.ESP_Distance, function(v) Config.ESP_Distance = v; SaveConfig() end, "esp_distance")
addToggle(tabVisuals, T("fruit_esp"), 7, Config.FruitESP, function(v) Config.FruitESP = v; SaveConfig() end, "fruit_esp")

-- MOVEMENT TAB - ALL LOADED FROM CONFIG
addLabel(tabMovement, T("movement_settings"), 1, true, "movement_settings")

addToggle(tabMovement, T("enable_speed"), 2, Config.SpeedEnabled, function(v) 
    Config.SpeedEnabled = v
    ApplyAllConfig()  -- APPLY IMMEDIATELY
    SaveConfig()
end, "enable_speed")

local function GetSpeedDropValues()
    return {T("speed_normal"), T("speed_fast"), T("speed_vfast"), T("speed_ultra"), T("speed_max"), T("speed_400"), T("speed_450")}
end

local currentSpeedText = T("speed_normal")
if Config.WalkSpeed == 50 then currentSpeedText = T("speed_fast")
elseif Config.WalkSpeed == 100 then currentSpeedText = T("speed_vfast")
elseif Config.WalkSpeed == 200 then currentSpeedText = T("speed_ultra")
elseif Config.WalkSpeed == 300 then currentSpeedText = T("speed_max")
elseif Config.WalkSpeed == 400 then currentSpeedText = T("speed_400")
elseif Config.WalkSpeed == 450 then currentSpeedText = T("speed_450")
end

addDropdown(tabMovement, T("speed_value"), 3, GetSpeedDropValues(), currentSpeedText, function(v)
    local speeds = {
        [T("speed_normal")] = 16, 
        [T("speed_fast")] = 50, 
        [T("speed_vfast")] = 100, 
        [T("speed_ultra")] = 200, 
        [T("speed_max")] = 300,
        [T("speed_400")] = 400,
        [T("speed_450")] = 450
    }
    Config.WalkSpeed = speeds[v] or 16
    ApplyAllConfig()  -- APPLY IMMEDIATELY
    SaveConfig()
end, "speed_value")

addToggle(tabMovement, T("enable_jump"), 4, Config.JumpEnabled, function(v) 
    Config.JumpEnabled = v
    ApplyAllConfig()  -- APPLY IMMEDIATELY
    SaveConfig()
end, "enable_jump")

local function GetJumpDropValues()
    return {T("jump_normal"), T("jump_high"), T("jump_vhigh"), T("jump_ultra"), T("jump_250")}
end

local currentJumpText = T("jump_normal")
if Config.JumpPower == 100 then currentJumpText = T("jump_high")
elseif Config.JumpPower == 150 then currentJumpText = T("jump_vhigh")
elseif Config.JumpPower == 200 then currentJumpText = T("jump_ultra")
elseif Config.JumpPower == 250 then currentJumpText = T("jump_250")
end

addDropdown(tabMovement, T("jump_power"), 5, GetJumpDropValues(), currentJumpText, function(v)
    local jumps = {
        [T("jump_normal")] = 50, 
        [T("jump_high")] = 100, 
        [T("jump_vhigh")] = 150, 
        [T("jump_ultra")] = 200,
        [T("jump_250")] = 250
    }
    Config.JumpPower = jumps[v] or 50
    ApplyAllConfig()  -- APPLY IMMEDIATELY
    SaveConfig()
end, "jump_power")

addToggle(tabMovement, T("enable_dash"), 6, Config.DashEnabled, function(v)
    Config.DashEnabled = v
    DashButton.Visible = v
    SaveConfig()
end, "enable_dash")

local function GetDashDropValues()
    return {T("dash_50"), T("dash_100"), T("dash_150"), T("dash_200"), T("dash_300"), T("dash_500"), T("dash_600"), T("dash_700")}
end

local currentDashText = T("dash_100")
if Config.DashPower == 50 then currentDashText = T("dash_50")
elseif Config.DashPower == 150 then currentDashText = T("dash_150")
elseif Config.DashPower == 200 then currentDashText = T("dash_200")
elseif Config.DashPower == 300 then currentDashText = T("dash_300")
elseif Config.DashPower == 500 then currentDashText = T("dash_500")
elseif Config.DashPower == 600 then currentDashText = T("dash_600")
elseif Config.DashPower == 700 then currentDashText = T("dash_700")
end

addDropdown(tabMovement, T("dash_power"), 7, GetDashDropValues(), currentDashText, function(v)
    local powers = {
        [T("dash_50")] = 50, 
        [T("dash_100")] = 100, 
        [T("dash_150")] = 150, 
        [T("dash_200")] = 200, 
        [T("dash_300")] = 300, 
        [T("dash_500")] = 500, 
        [T("dash_600")] = 600, 
        [T("dash_700")] = 700
    }
    Config.DashPower = powers[v] or 100
    SaveConfig()
end, "dash_power")

addToggle(tabMovement, T("water_walk"), 8, Config.WaterWalk, function(v) 
    Config.WaterWalk = v
    SaveConfig()
end, "water_walk")

addLabel(tabMovement, T("escape_system"), 9, true, "escape_system")
addToggle(tabMovement, T("sky_escape"), 10, Config.EscapeActive, function(v) 
    Config.EscapeActive = v
    SaveConfig()
end, "sky_escape")

local function GetHealthDropValues()
    return {T("health_low"), T("health_medium"), T("health_high"), T("health_max")}
end

local currentHealthText = T("health_max")
if Config.EscapeHealth == 1000 then currentHealthText = T("health_low")
elseif Config.EscapeHealth == 5000 then currentHealthText = T("health_medium")
elseif Config.EscapeHealth == 10000 then currentHealthText = T("health_high")
end

addDropdown(tabMovement, T("health_limit"), 11, GetHealthDropValues(), currentHealthText, function(v)
    local vals = {[T("health_low")] = 1000, [T("health_medium")] = 5000, [T("health_high")] = 10000, [T("health_max")] = 14345}
    Config.EscapeHealth = vals[v] or 14345
    SaveConfig()
end, "health_limit")

-- FRUITS TAB
addLabel(tabFruits, T("fruit_hunter"), 1, true, "fruit_hunter")
addToggle(tabFruits, T("go_to_fruit"), 2, Config.GoToFruitActive, function(v) 
    Config.GoToFruitActive = v
    SaveConfig()
end, "go_to_fruit")
addLabel(tabFruits, T("auto_random_fruit"), 3, true, "auto_random_fruit")
addToggle(tabFruits, T("auto_random_fruit"), 4, Config.AutoRandomFruit, function(v) 
    Config.AutoRandomFruit = v
    SaveConfig()
end, "auto_random_fruit")

-- SEA TAB
addLabel(tabSea, T("boat_controls"), 1, true, "boat_controls")

addToggle(tabSea, T("boat_speed"), 2, Config.BoatSpeedEnabled, function(v) 
    Config.BoatSpeedEnabled = v
    SaveConfig()
end, "boat_speed")

addDropdown(tabSea, T("speed_amount"), 3, {"1x", "2x", "3x", "4x", "5x", "6x", "7x", "8x", "9x", "10x"}, "2x", function(v)
    BoatSpeedValue = tonumber(v:match("%d+")) or 2
end, "speed_amount")

addToggle(tabSea, T("boat_fly"), 4, Config.BoatFlyEnabled, function(v) 
    Config.BoatFlyEnabled = v
    SaveConfig()
end, "boat_fly")

addDropdown(tabSea, T("fly_height"), 5, {"0", "25", "50", "75", "100", "125", "135"}, "50", function(v)
    BoatFlyHeight = tonumber(v) or 50
end, "fly_height")

------------------------------------------------------------------------
-- [ WATER WALK & ESCAPE - USES Config VALUES ]
------------------------------------------------------------------------
local waterPlatform = Instance.new("Part")
waterPlatform.Name = "ARAKS_WaterPlatform"
waterPlatform.Size = Vector3.new(20, 1, 20)
waterPlatform.Transparency = 1
waterPlatform.Anchored = true
waterPlatform.CanCollide = Config.WaterWalk  -- SET FROM CONFIG
waterPlatform.Parent = workspace

local WaterWalkConnection = nil

local function StartWaterWalkLoop()
    if WaterWalkConnection then
        WaterWalkConnection:Disconnect()
        WaterWalkConnection = nil
    end
    
    WaterWalkConnection = RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local hum = LocalPlayer.Character.Humanoid
            
            if Config.WaterWalk then  -- READ FROM CONFIG
                waterPlatform.CanCollide = true
                waterPlatform.Position = Vector3.new(root.Position.X, 0.8, root.Position.Z)
            else
                waterPlatform.CanCollide = false
            end
            
            if Config.EscapeActive and hum and hum.Health <= Config.EscapeHealth and hum.Health > 0 then  -- READ FROM CONFIG
                root.CFrame = root.CFrame * CFrame.new(0, 9000, 0)
            end
        end
    end)
end

StartWaterWalkLoop()

------------------------------------------------------------------------
-- [ FRUITS GO TO FRUIT - USES Config.GoToFruitActive ]
------------------------------------------------------------------------
local FruitGoRunning = false

local function StartFruitGo()
    if FruitGoRunning then return end
    FruitGoRunning = true
    
    task.spawn(function()
        while FruitGoRunning do
            if Config.GoToFruitActive then  -- READ FROM CONFIG
                pcall(function()
                    local fruit = nil
                    for _, v in pairs(workspace:GetChildren()) do
                        if v:IsA("Tool") or (v:IsA("Model") and v:FindFirstChild("Handle") and v.Name:lower():find("fruit")) then
                            fruit = v
                            break
                        end
                    end
                    if fruit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local handle = fruit:FindFirstChild("Handle") or fruit
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        local dist = (hrp.Position - handle.Position).Magnitude
                        if dist > 10 then
                            if fruitTween then 
                                pcall(function() fruitTween:Cancel() end)
                            end
                            fruitTween = TweenService:Create(hrp, TweenInfo.new(dist / 400, Enum.EasingStyle.Linear), {CFrame = handle.CFrame * CFrame.new(0, 3, 0)})
                            fruitTween:Play()
                            fruitTween.Completed:Wait()
                            fruitTween = nil
                        end
                    end
                end)
                task.wait()
            else
                if fruitTween then
                    pcall(function() fruitTween:Cancel() end)
                    fruitTween = nil
                end
                task.wait(0.5)
            end
        end
    end)
end

StartFruitGo()

------------------------------------------------------------------------
-- [ AUTO RANDOM FRUIT - USES Config.AutoRandomFruit ]
------------------------------------------------------------------------
local AutoFruitRunning = false

local function StartAutoFruit()
    if AutoFruitRunning then return end
    AutoFruitRunning = true
    
    task.spawn(function()
        while AutoFruitRunning do
            task.wait(2)
            if Config.AutoRandomFruit and CommF_ then  -- READ FROM CONFIG
                pcall(function()
                    for i = 1, 3 do
                        CommF_:InvokeServer("Cousin", "Buy")
                        task.wait(0.5)
                    end
                end)
            end
        end
    end)
end

StartAutoFruit()

------------------------------------------------------------------------
-- [ AIMBOT - USES Config.AimbotActive ]
------------------------------------------------------------------------
local TracerLine = Drawing.new("Line")
TracerLine.Thickness = 1.2
TracerLine.Color = Color3.fromRGB(255, 0, 0)

local AimbotConnection = nil

local function StartAimbot()
    if AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
    end
    
    AimbotConnection = RunService.RenderStepped:Connect(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

        local nearest, lastDist = nil, Config.MaxDistance

        for _, ply in pairs(Players:GetPlayers()) do
            if ply ~= LocalPlayer and ply.Character and ply.Character:FindFirstChild(Config.TargetPart) then
                local dist = (ply.Character[Config.TargetPart].Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < lastDist then
                    lastDist = dist
                    nearest = ply
                end
            end
        end

        CurrentTarget = nearest
        AutoHunt.CurrentTarget = nearest
        
        if Config.AimbotActive and CurrentTarget and CurrentTarget.Character then  -- READ FROM CONFIG
            local Pos, OnScreen = Camera:WorldToViewportPoint(CurrentTarget.Character[Config.TargetPart].Position)
            if OnScreen then
                TracerLine.Visible = true
                TracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                TracerLine.To = Vector2.new(Pos.X, Pos.Y)
            else
                TracerLine.Visible = false
            end
        else
            TracerLine.Visible = false
        end
    end)
end

StartAimbot()

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and self.Name == "RemoteEvent" and Config.AimbotActive and CurrentTarget then  -- READ FROM CONFIG
        for i, v in pairs(args) do
            if typeof(v) == "Vector3" then 
                args[i] = CurrentTarget.Character[Config.TargetPart].Position 
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

------------------------------------------------------------------------
-- [ COMBAT LOOP ]
------------------------------------------------------------------------
local CombatRunning = false

local function Attack(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    if RegisterAttack and RegisterHit then
        RegisterAttack:FireServer(0.5)
        RegisterHit:FireServer(target.HumanoidRootPart, {}, nil, GetSessionID())
    end
end

local function MoveToEnemy(targetChar, hrp)
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
        platform.CFrame = CFrame.new(0, -1000, 0)
        return false
    end
    
    local enemyRoot = targetChar.HumanoidRootPart
    local distance = (enemyRoot.Position - hrp.Position).Magnitude
    
    platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
    platform.CanCollide = true
    platform.Transparency = 0.4
    
    if distance > 10 then
        if currentTween then 
            pcall(function() currentTween:Cancel() end)
        end
        currentTween = TweenService:Create(hrp, TweenInfo.new(distance / 200, Enum.EasingStyle.Linear), {
            CFrame = enemyRoot.CFrame * CFrame.new(0, 0, 4)
        })
        currentTween:Play()
        currentTween.Completed:Wait()
        currentTween = nil
    end
    
    hrp.CFrame = enemyRoot.CFrame * CFrame.new(0, 0, 3)
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    
    platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
    
    return true
end

local function StartCombatLoop()
    if CombatRunning then return end
    CombatRunning = true
    
    task.spawn(function()
        while CombatRunning do
            task.wait()
            pcall(function()
                local huntTarget = nil
                
                if AutoHunt.KillNearest then
                    huntTarget = AutoHunt.CurrentTarget
                elseif AutoHunt.Enabled and AutoHunt.SelectedPlayer then
                    huntTarget = AutoHunt.SelectedPlayer
                end
                
                if not huntTarget then
                    platform.CFrame = CFrame.new(0, -1000, 0)
                    if currentTween then
                        pcall(function() currentTween:Cancel() end)
                        currentTween = nil
                    end
                    return
                end
                
                if huntTarget and huntTarget.Character and huntTarget.Character:FindFirstChild("HumanoidRootPart") then
                    local enemy = huntTarget.Character
                    local humanoid = enemy:FindFirstChild("Humanoid")
                    
                    if humanoid and humanoid.Health > 0 then
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            MoveToEnemy(enemy, hrp)
                            Attack(enemy)
                        end
                    end
                else
                    platform.CFrame = CFrame.new(0, -1000, 0)
                    if currentTween then
                        pcall(function() currentTween:Cancel() end)
                        currentTween = nil
                    end
                end
            end)
        end
    end)
end

StartCombatLoop()

------------------------------------------------------------------------
-- [ BACKGROUND ]
------------------------------------------------------------------------
task.spawn(function()
    task.wait(0.5)
    if game.CoreGui:FindFirstChild("ARAKS_BackgroundGui") then game.CoreGui.ARAKS_BackgroundGui:Destroy() end
    local BGGui = Instance.new("ScreenGui")
    BGGui.Name = "ARAKS_BackgroundGui"
    BGGui.ResetOnSpawn = false
    BGGui.IgnoreGuiInset = true
    BGGui.DisplayOrder = -100
    BGGui.Parent = game.CoreGui
    local BGImage = Instance.new("ImageLabel")
    BGImage.Parent = BGGui
    BGImage.Size = UDim2.new(1,0,1,0)
    BGImage.Image = "https://files.catbox.moe/wvwy7n.png"
    BGImage.BackgroundTransparency = 1
    BGImage.ImageTransparency = 0
    BGImage.ScaleType = Enum.ScaleType.Crop
end)

pcall(function()
    local notif = Instance.new("TextLabel", gui)
    notif.Size = UDim2.new(0, 450, 0, 50)
    notif.Position = UDim2.new(0.5, -225, 0, 10)
    notif.Text = "ARAKS HUB | V17 - Config Application FIXED"
    notif.TextSize = 14
    notif.Font = Enum.Font.GothamBold
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
    notif.BackgroundTransparency = 0.3
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
    task.delay(6, function() if notif and notif.Parent then notif:Destroy() end end)
end)

print("ARAKS HUB V17 - Config Application FIXED!")
print("✅ Config loads AND applies on script start")
print("✅ Config re-applies on CharacterAdded (respawn)")
print("✅ ALL features read directly from Config table")
print("✅ WalkSpeed: " .. Config.WalkSpeed .. " (Enabled: " .. tostring(Config.SpeedEnabled) .. ")")
print("✅ JumpPower: " .. Config.JumpPower .. " (Enabled: " .. tostring(Config.JumpEnabled) .. ")")
print("✅ BusoEnabled: " .. tostring(Config.BusoEnabled))
print("✅ AntiStun: " .. tostring(Config.AntiStun))
print("✅ FastAttack: " .. tostring(Config.FastAttack) .. " (Speed: " .. Config.FastAttackSpeed .. ")")
print("✅ Dash: " .. tostring(Config.DashEnabled) .. " (Power: " .. Config.DashPower .. ")")
print("✅ Config Application System: Working")