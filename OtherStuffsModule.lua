-- Add these keys to your DefaultSettings table:
local DefaultSettings = {
    -- ... your existing keys ...
    AntiStun           = false,
    WaterWalk          = false,
    KillAuraEnabled    = false,
    KillAuraRange      = 300,
    KillAuraPlayers    = true,
    KillAuraNPCs       = true,
    OneShotEnabled     = false,
    TpNearestPlayer    = false,
    TpNearestNPC       = false,
    TpRange            = 250,
    SkyEscape          = false,
    EscapeHealth       = 1000,
    BoatSpeedEnabled   = false,
    BoatSpeedMult      = 2,
    BoatFlyEnabled     = false,
    BoatFlyHeight      = 50,
    FastAttack         = false,
    FastAttackSpeed    = 50,
    SpeedEnabled       = false,
    WalkSpeed          = 16,
    JumpEnabled        = false,
    JumpPower          = 50,
    DashEnabled        = false,
    DashPower          = 100,
    BusoEnabled        = false,
    SilentAimPlayers   = false,
    SilentAimNPC       = false,
    SilentAimPrediction = false,
    SilentAimPredictionAmount = 5,
    SilentAimDistance  = 1000,
    AimlockPlayers     = false,
    AimlockNPC         = false,
    ESPEnabled         = false,
    ESPBox             = false,
    ESPName            = false,
    ESPHealth          = false,
    ESPLevel           = false,
    ESPDistance        = false,
    FruitESP           = false,
    GoToFruit          = false,
    AutoRandomFruit    = false,
}

-- ApplySettings function (call on CharacterAdded and on load)
function OtherStuffs.ApplySettings(s, modules)
    local M = modules
    task.wait(1)
    pcall(function() M.Stuffs:SetAntiStun(s.AntiStun) end)
    pcall(function() M.Stuffs:SetWaterWalk(s.WaterWalk) end)
    pcall(function() M.Stuffs:SetFastAttack(s.FastAttack) end)
    pcall(function() M.Stuffs:SetFastAttackSpeed((s.FastAttackSpeed or 50) / 1000) end)
    pcall(function() M.Stuffs:SetDashEnabled(s.DashEnabled) end)
    pcall(function() M.Stuffs:SetDashPower(s.DashPower or 100) end)
    pcall(function() M.Stuffs:SetSkyEscape(s.SkyEscape) end)
    pcall(function() M.Stuffs:SetEscapeHealth(s.EscapeHealth or 1000) end)
    pcall(function() M.Stuffs:SetBoatSpeed(s.BoatSpeedEnabled) end)
    pcall(function() M.Stuffs:SetBoatSpeedMult(s.BoatSpeedMult or 2) end)
    pcall(function() M.Stuffs:SetBoatFly(s.BoatFlyEnabled) end)
    pcall(function() M.Stuffs:SetBoatFlyHeight(s.BoatFlyHeight or 50) end)
    pcall(function() M.ESPModule:SetBuso(s.BusoEnabled) end)
    pcall(function() M.ESPModule:SetESP(s.ESPEnabled) end)
    pcall(function() M.ESPModule:SetFruitESP(s.FruitESP) end)
    pcall(function() M.AimLock:SetPlayerAimlock(s.AimlockPlayers) end)
    pcall(function() M.AimLock:SetNpcAimlock(s.AimlockNPC) end)
    pcall(function() M.SilentAim:SetPlayerSilentAim(s.SilentAimPlayers) end)
    pcall(function() M.SilentAim:SetNPCSilentAim(s.SilentAimNPC) end)
    pcall(function() M.SilentAim:SetPrediction(s.SilentAimPrediction) end)
    pcall(function() M.SilentAim:SetPredictionAmount((s.SilentAimPredictionAmount or 5) / 100) end)
    pcall(function() M.SilentAim:SetDistanceLimit(s.SilentAimDistance or 1000) end)
    pcall(function() M.KillAura:SetEnabled(s.KillAuraEnabled) end)
    pcall(function() M.KillAura:SetRange(s.KillAuraRange or 300) end)
    pcall(function() M.KillAura:SetIncludePlayers(s.KillAuraPlayers ~= false) end)
    pcall(function() M.KillAura:SetIncludeNPCs(s.KillAuraNPCs ~= false) end)
    pcall(function() M.OneShot:SetEnabled(s.OneShotEnabled) end)
    pcall(function() M.TPModule:SetTpNearestPlayer(s.TpNearestPlayer) end)
    pcall(function() M.TPModule:SetTpNearestNPC(s.TpNearestNPC) end)
    pcall(function() M.TPModule:SetRange(s.TpRange or 250) end)
    pcall(function() M.UiSettings:SetGoToFruit(s.GoToFruit) end)
    pcall(function() M.UiSettings:SetAutoRandomFruit(s.AutoRandomFruit) end)
    -- Speed/jump applied directly
    local char = game:GetService("Players").LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if s.SpeedEnabled then hum.WalkSpeed = s.WalkSpeed or 16 end
            if s.JumpEnabled  then hum.JumpPower  = s.JumpPower  or 50 end
        end
    end
end