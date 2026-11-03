return function(ctx)
    local M, U, Settings, Theme = ctx.M, ctx.U, ctx.Settings, ctx.Theme
    local cloneref, gethui, protect_gui, getgenv = ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv
    local Drawing = ctx.Drawing
    local RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager = ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager
    local LocalPlayer, Camera = ctx.LocalPlayer, ctx.Camera
        if plr ~= LocalPlayer then
            local skip = false
            if Settings.Trigger.TeamCheck and plr.Team == myTeam and myTeam ~= nil then skip = true end
            if not skip then
                local model, part = U.resolveAimTarget(plr)
                if model and part then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local sp, on = U.worldToScreen(part.CFrame.Position)
                        if on then
                            local d = (sp - center).Magnitude
                            if d <= Settings.Aim.FOV then
                                if (not Settings.Trigger.WallCheck) or U.isVisibleFromCam(part, model) then
                                    M.LastTrigger = tick()
                                    pcall(function() mouse1click() end)
                                    pcall(function()
                                        VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
                                        task.wait(0.02)
                                        VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
                                    end)
                                    if Settings.Sound.KillSound then U.playSound(Settings.Sound.KillSoundId) end
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

--=====================================================================
-- GUI
--=====================================================================
local parentGui = (function()
    local ok, hui = pcall(gethui)
    if ok and hui then return hui end
    return LocalPlayer:WaitForChild("PlayerGui")
end)()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MixWareUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(protect_gui, ScreenGui)
ScreenGui.Parent = parentGui
M.ScreenGui = ScreenGui

U.setupNotifyHolder(ScreenGui)

-- WATERMARK
do
    local wm = Instance.new("Frame", ScreenGui)

end
