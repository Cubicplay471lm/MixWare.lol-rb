return function(ctx)
    local M, U, Settings, Theme = ctx.M, ctx.U, ctx.Settings, ctx.Theme
    local cloneref, gethui, protect_gui, getgenv = ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv
    local Drawing = ctx.Drawing
    local RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager = ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager
    local LocalPlayer, Camera = ctx.LocalPlayer, ctx.Camera
end

function U.startHeadMover()
    if M.HeadMoverConn then M.HeadMoverConn:Disconnect() end
    M.HeadMoverConn = RunService.RenderStepped:Connect(function()
        if not Settings.Aim.HeadMover then U.restoreAllHeads(); return end
        if Settings.Aim.HeadMoverOnlyAimKey and not U.isAimKeyDown() then U.restoreAllHeads(); return end
        local targetPlr = M.CurrentTarget
        if not targetPlr or targetPlr == LocalPlayer then targetPlr = U.getClosestTarget() end
        if not targetPlr or targetPlr == LocalPlayer then U.restoreAllHeads(); return end
        local model = U.getCharacterForPlayer(targetPlr)
        if not model then U.restoreAllHeads(); return end
        if U.belongsToLocalPlayer(model) then U.restoreAllHeads(); return end
        local head = model:FindFirstChild("Head")
        if not head then U.restoreAllHeads(); return end
        if U.belongsToLocalPlayer(head) then U.restoreAllHeads(); return end
        local camCF = Camera.CFrame
        local dist = Settings.Aim.HeadMoverDistance
        local targetPoint = camCF.Position + camCF.LookVector * dist
        if not M.OriginalHeadCFrames[head] then M.OriginalHeadCFrames[head] = head.CFrame end
        local speed = math.clamp(Settings.Aim.HeadMoverSpeed, 0.05, 1)
        local desired = CFrame.new(targetPoint, camCF.Position)
        local newCF = head.CFrame:Lerp(desired, speed)
        pcall(function() head.CFrame = newCF end)
    end)
end

function U.stopHeadMover()
    if M.HeadMoverConn then M.HeadMoverConn:Disconnect(); M.HeadMoverConn = nil end
    U.restoreAllHeads()
end

--=====================================================================
-- TRIGGERBOT
--=====================================================================
M.LastTrigger = 0
function U.updateTrigger()
    if not Settings.Trigger.Enabled then return end
    if Settings.Trigger.OnlyAimKey and not U.isAimKeyDown() then return end
    if tick() - M.LastTrigger < Settings.Trigger.Delay then return end
    local center = U.getFOVOrigin()
    local myTeam = LocalPlayer.Team
    for _, plr in ipairs(Players:GetPlayers()) do

end
