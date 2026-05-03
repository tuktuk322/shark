-- Arkxi Hub - MainScript.lua
-- Loads all modules via raw GitHub URLs
if _G.ArkxiLoaded then return end
_G.ArkxiLoaded = true

local BASE = "https://raw.githubusercontent.com/tuktuk322/Arkxi/main/"

local function Load(file)
    return loadstring(game:HttpGet(BASE .. file, true))()
end

-- Core UI Library
local Library       = Load("Ui.txt")
local UiSettings    = Load("UiSettingsModule.txt")
local OtherStuffs   = Load("OtherStuffsModule.txt")
local ESPModule     = Load("EspModule.txt")
local AimLock       = Load("AimLockModule.txt")
local SilentAim     = Load("SilentAimModule.txt")
local Stuffs        = Load("StuffsModule.txt")
local ZSkill        = Load("ZSKillModule.txt")
local TPModule      = Load("TPModule.lua")
local KillAura      = Load("KillAuraModule.lua")
local OneShot       = Load("OneShotModule.lua")

-- Services
local Players       = game:GetService("Players")
local LocalPlayer   = Players.LocalPlayer

-- Executor detection
local executor = "Unknown"
if syn then executor = "Synapse X"
elseif KRNL_LOADED then executor = "KRNL"
elseif fluxus then executor = "Fluxus"
elseif getexecutorname then
    local ok, name = pcall(getexecutorname)
    if ok and type(name) == "string" then executor = name end
end

local execStatus = (executor == "Xeno" or executor:lower():find("solara") or executor:lower():find("krnl"))
    and "Not Working" or "Working"

-- Load saved settings
local Settings = OtherStuffs.LoadSettings()

-- Create Window
local Window = Library.CreateLib("Arkxi Hub | " .. executor, UiSettings.currentTheme)

-- ── EXECUTOR STATUS TAB ──────────────────────────────────────────────────────
local TabExec    = Window:NewTab("◇・Executor Status")
local SecInfo    = TabExec:NewSection("◈・Information")
SecInfo:NewLabel("Executor: " .. executor)
SecInfo:NewLabel("Status: "   .. execStatus)

-- ── CHANGELOGS TAB ───────────────────────────────────────────────────────────
local TabLog  = Window:NewTab("・・ChangesLogs")
local SecLog  = TabLog:NewSection("✏・Updated")
SecLog:NewLabel("• Kill Aura + Range Slider")
SecLog:NewLabel("• OneShot (Saishi/Spikey stun → sea)")
SecLog:NewLabel("• WaterWalk V2 (platform follow)")
SecLog:NewLabel("• TP to Nearest Player / NPC")
SecLog:NewLabel("• Anti-Stun improved")
SecLog:NewLabel("• Silent Aim + Prediction")
SecLog:NewLabel("• Auto Hunt")
SecLog:NewLabel("• Buso Heartbeat")

-- ── COMBAT TAB ───────────────────────────────────────────────────────────────
local TabCombat = Window:NewTab("⚔・Combat")
local SecAim    = TabCombat:NewSection("🎯・Aimbot / Silent Aim")

SecAim:NewToggle("Aimlock Players", "", Settings.AimlockPlayers or false, function(v)
    Settings.AimlockPlayers = v
    AimLock:SetPlayerAimlock(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecAim:NewToggle("Aimlock NPC", "", Settings.AimlockNPC or false, function(v)
    Settings.AimlockNPC = v
    AimLock:SetNpcAimlock(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecAim:NewToggle("Silent Aim Players", "", Settings.SilentAimPlayers or false, function(v)
    Settings.SilentAimPlayers = v
    SilentAim:SetPlayerSilentAim(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecAim:NewToggle("Silent Aim NPC", "", Settings.SilentAimNPC or false, function(v)
    Settings.SilentAimNPC = v
    SilentAim:SetNPCSilentAim(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecAim:NewToggle("Prediction", "", Settings.SilentAimPrediction or false, function(v)
    Settings.SilentAimPrediction = v
    SilentAim:SetPrediction(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecAim:NewSlider("Prediction Amount", "", 100, 1, Settings.SilentAimPredictionAmount or 5, function(v)
    Settings.SilentAimPredictionAmount = v
    SilentAim:SetPredictionAmount(v / 100)
    OtherStuffs.SaveSettings(Settings)
end)

SecAim:NewSlider("Distance Limit", "", 2000, 50, Settings.SilentAimDistance or 1000, function(v)
    Settings.SilentAimDistance = v
    SilentAim:SetDistanceLimit(v)
    OtherStuffs.SaveSettings(Settings)
end)

local SecCombat = TabCombat:NewSection("⚡・Combat Features")

SecCombat:NewToggle("Anti-Stun", "", Settings.AntiStun or false, function(v)
    Settings.AntiStun = v
    Stuffs:SetAntiStun(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecCombat:NewToggle("Haki Hardening (Buso)", "", Settings.BusoEnabled or false, function(v)
    Settings.BusoEnabled = v
    ESPModule:SetBuso(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecCombat:NewToggle("Fast Attack", "", Settings.FastAttack or false, function(v)
    Settings.FastAttack = v
    Stuffs:SetFastAttack(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecCombat:NewSlider("Attack Speed (ms)", "", 500, 10, Settings.FastAttackSpeed or 50, function(v)
    Settings.FastAttackSpeed = v
    Stuffs:SetFastAttackSpeed(v / 1000)
    OtherStuffs.SaveSettings(Settings)
end)

local SecKA = TabCombat:NewSection("🌀・Kill Aura")

SecKA:NewToggle("Kill Aura", "", Settings.KillAuraEnabled or false, function(v)
    Settings.KillAuraEnabled = v
    KillAura:SetEnabled(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecKA:NewSlider("Kill Aura Range", "", 1000, 10, Settings.KillAuraRange or 300, function(v)
    Settings.KillAuraRange = v
    KillAura:SetRange(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecKA:NewToggle("Include Players", "", Settings.KillAuraPlayers ~= false, function(v)
    Settings.KillAuraPlayers = v
    KillAura:SetIncludePlayers(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecKA:NewToggle("Include NPCs", "", Settings.KillAuraNPCs ~= false, function(v)
    Settings.KillAuraNPCs = v
    KillAura:SetIncludeNPCs(v)
    OtherStuffs.SaveSettings(Settings)
end)

local SecOneShot = TabCombat:NewSection("💀・OneShot (Stun → Sea)")

SecOneShot:NewToggle("Enable OneShot", "", Settings.OneShotEnabled or false, function(v)
    Settings.OneShotEnabled = v
    OneShot:SetEnabled(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecOneShot:NewLabel("Weapon: Saishi / Spikey Trident")
SecOneShot:NewLabel("Keybind: H (press when enemy stunned)")

-- ── MOVEMENT TAB ─────────────────────────────────────────────────────────────
local TabMove = Window:NewTab("🏃・Movement")
local SecMove = TabMove:NewSection("💨・Speed & Jump")

SecMove:NewToggle("Enable Speed", "", Settings.SpeedEnabled or false, function(v)
    Settings.SpeedEnabled = v
    OtherStuffs.SaveSettings(Settings)
    if v then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Settings.WalkSpeed or 16 end
    else
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

SecMove:NewSlider("Walk Speed", "", 450, 16, Settings.WalkSpeed or 16, function(v)
    Settings.WalkSpeed = v
    OtherStuffs.SaveSettings(Settings)
    if Settings.SpeedEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)

SecMove:NewToggle("Enable Jump", "", Settings.JumpEnabled or false, function(v)
    Settings.JumpEnabled = v
    OtherStuffs.SaveSettings(Settings)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = v and (Settings.JumpPower or 50) or 50 end
end)

SecMove:NewSlider("Jump Power", "", 250, 50, Settings.JumpPower or 50, function(v)
    Settings.JumpPower = v
    OtherStuffs.SaveSettings(Settings)
    if Settings.JumpEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
end)

local SecDash = TabMove:NewSection("💥・Dash")

SecDash:NewToggle("Enable Dash", "", Settings.DashEnabled or false, function(v)
    Settings.DashEnabled = v
    Stuffs:SetDashEnabled(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecDash:NewSlider("Dash Power", "", 700, 50, Settings.DashPower or 100, function(v)
    Settings.DashPower = v
    Stuffs:SetDashPower(v)
    OtherStuffs.SaveSettings(Settings)
end)

local SecWater = TabMove:NewSection("🌊・Water Walk")

SecWater:NewToggle("Water Walk V2", "", Settings.WaterWalk or false, function(v)
    Settings.WaterWalk = v
    Stuffs:SetWaterWalk(v)
    OtherStuffs.SaveSettings(Settings)
end)

local SecEscape = TabMove:NewSection("☁・Sky Escape")

SecEscape:NewToggle("Sky Escape", "", Settings.SkyEscape or false, function(v)
    Settings.SkyEscape = v
    Stuffs:SetSkyEscape(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecEscape:NewSlider("Escape HP Threshold", "", 50000, 100, Settings.EscapeHealth or 1000, function(v)
    Settings.EscapeHealth = v
    Stuffs:SetEscapeHealth(v)
    OtherStuffs.SaveSettings(Settings)
end)

-- ── TELEPORT TAB ─────────────────────────────────────────────────────────────
local TabTP = Window:NewTab("✈・Teleport")
local SecTP = TabTP:NewSection("📍・Teleport Features")

SecTP:NewToggle("TP to Nearest Player", "", Settings.TpNearestPlayer or false, function(v)
    Settings.TpNearestPlayer = v
    TPModule:SetTpNearestPlayer(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecTP:NewToggle("TP to Nearest NPC", "", Settings.TpNearestNPC or false, function(v)
    Settings.TpNearestNPC = v
    TPModule:SetTpNearestNPC(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecTP:NewSlider("TP Range", "", 2000, 10, Settings.TpRange or 250, function(v)
    Settings.TpRange = v
    TPModule:SetRange(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecTP:NewButton("TP Behind Target Now", "", function()
    TPModule:TpBehindNearest()
end)

-- ── VISUALS TAB ──────────────────────────────────────────────────────────────
local TabVis = Window:NewTab("👁・Visuals")
local SecESP = TabVis:NewSection("📦・ESP")

SecESP:NewToggle("ESP Players",  "", Settings.ESPEnabled or false,    function(v) Settings.ESPEnabled = v;    ESPModule:SetESP(v);    OtherStuffs.SaveSettings(Settings) end)
SecESP:NewToggle("ESP Box",      "", Settings.ESPBox or false,        function(v) Settings.ESPBox = v;        ESPModule:SetESPBox(v); OtherStuffs.SaveSettings(Settings) end)
SecESP:NewToggle("ESP Name",     "", Settings.ESPName or false,       function(v) Settings.ESPName = v;       OtherStuffs.SaveSettings(Settings) end)
SecESP:NewToggle("Health Bar",   "", Settings.ESPHealth or false,     function(v) Settings.ESPHealth = v;     OtherStuffs.SaveSettings(Settings) end)
SecESP:NewToggle("Level ESP",    "", Settings.ESPLevel or false,      function(v) Settings.ESPLevel = v;      OtherStuffs.SaveSettings(Settings) end)
SecESP:NewToggle("Distance ESP", "", Settings.ESPDistance or false,   function(v) Settings.ESPDistance = v;   OtherStuffs.SaveSettings(Settings) end)
SecESP:NewToggle("Fruit ESP",    "", Settings.FruitESP or false,      function(v) Settings.FruitESP = v;      ESPModule:SetFruitESP(v); OtherStuffs.SaveSettings(Settings) end)

-- ── FRUITS TAB ───────────────────────────────────────────────────────────────
local TabFruits = Window:NewTab("🍎・Fruits")
local SecFruits = TabFruits:NewSection("🍑・Fruit Hunter")

SecFruits:NewToggle("Go to Fruit", "", Settings.GoToFruit or false, function(v)
    Settings.GoToFruit = v
    UiSettings:SetGoToFruit(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecFruits:NewToggle("Auto Random Fruit", "", Settings.AutoRandomFruit or false, function(v)
    Settings.AutoRandomFruit = v
    UiSettings:SetAutoRandomFruit(v)
    OtherStuffs.SaveSettings(Settings)
end)

-- ── SEA TAB ──────────────────────────────────────────────────────────────────
local TabSea = Window:NewTab("🚢・Sea")
local SecSea = TabSea:NewSection("⛵・Boat Controls")

SecSea:NewToggle("Boat Speed", "", Settings.BoatSpeedEnabled or false, function(v)
    Settings.BoatSpeedEnabled = v
    Stuffs:SetBoatSpeed(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecSea:NewSlider("Speed Multiplier", "", 10, 1, Settings.BoatSpeedMult or 2, function(v)
    Settings.BoatSpeedMult = v
    Stuffs:SetBoatSpeedMult(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecSea:NewToggle("Boat Fly", "", Settings.BoatFlyEnabled or false, function(v)
    Settings.BoatFlyEnabled = v
    Stuffs:SetBoatFly(v)
    OtherStuffs.SaveSettings(Settings)
end)

SecSea:NewSlider("Fly Height", "", 500, 0, Settings.BoatFlyHeight or 50, function(v)
    Settings.BoatFlyHeight = v
    Stuffs:SetBoatFlyHeight(v)
    OtherStuffs.SaveSettings(Settings)
end)

-- ── SETTINGS TAB ─────────────────────────────────────────────────────────────
local TabSettings = Window:NewTab("⚙・Settings")
local SecSave     = TabSettings:NewSection("💾・Config")

SecSave:NewButton("Save Settings", "", function()
    OtherStuffs.SaveSettings(Settings)
end)

SecSave:NewButton("Reset Settings", "", function()
    Settings = OtherStuffs.ResetSettings()
end)

SecSave:NewButton("Rejoin Server", "", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- Apply settings on character respawn
Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    OtherStuffs.ApplySettings(Settings, {
        Stuffs = Stuffs, ESPModule = ESPModule,
        AimLock = AimLock, SilentAim = SilentAim,
        KillAura = KillAura, OneShot = OneShot,
        TPModule = TPModule, UiSettings = UiSettings
    })
end)

-- Initial apply
OtherStuffs.ApplySettings(Settings, {
    Stuffs = Stuffs, ESPModule = ESPModule,
    AimLock = AimLock, SilentAim = SilentAim,
    KillAura = KillAura, OneShot = OneShot,
    TPModule = TPModule, UiSettings = UiSettings
})

print("[Arkxi] Loaded successfully.")