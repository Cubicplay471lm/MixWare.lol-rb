return function(ctx)
    local M, U, Settings, Theme = ctx.M, ctx.U, ctx.Settings, ctx.Theme
    local cloneref, gethui, protect_gui, getgenv = ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv
    local Drawing = ctx.Drawing
    local RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager = ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager
    local LocalPlayer, Camera = ctx.LocalPlayer, ctx.Camera
M.LastTrigger = 0
M.TriggerBusy = false

function U.fireTriggerClick(center)
    if M.TriggerBusy then return false end
    M.TriggerBusy = true
    local fired = false
    if type(injectedMouse1Click) == "function" then
        fired = pcall(injectedMouse1Click)
    end
    if not fired and VirtualInputManager then
        fired = pcall(function()
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
        end)
    end
    M.TriggerBusy = false
    return fired
end

function U.updateTrigger()
    local cfg = Settings.Trigger
    if not cfg.Enabled or M.TriggerBusy then return end
    if cfg.OnlyAimKey and not U.isAimKeyDown() then return end
    local now = os.clock()
    if now - M.LastTrigger < math.max(0, cfg.Delay) then return end
    local center = U.getFOVOrigin()
    local myTeam = LocalPlayer.Team
    local bestPart, bestModel, bestDist = nil, nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not (cfg.TeamCheck and myTeam ~= nil and plr.Team == myTeam) then
            local model, part = U.resolveAimTarget(plr)
            if model and part then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local sp, onScreen = U.worldToScreen(part.Position)
                    if onScreen then
                        local dist = (sp - center).Magnitude
                        if dist <= Settings.Aim.FOV and dist < bestDist and (not cfg.WallCheck or U.isVisibleFromCam(part, model)) then
                            bestDist, bestPart, bestModel = dist, part, model
                        end
                    end
                end
            end
        end
    end
    if bestPart and bestModel and U.fireTriggerClick(center) then
        M.LastTrigger = now
        if Settings.Sound.KillSound then U.playSound(Settings.Sound.KillSoundId) end
    end
end
--=====================================================================
-- HITBOX EXPANDER
--=====================================================================

end
