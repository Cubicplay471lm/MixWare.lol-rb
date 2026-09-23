return function(ctx)
    local M, U, Settings, Theme = ctx.M, ctx.U, ctx.Settings, ctx.Theme
    local cloneref, gethui, protect_gui, getgenv = ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv
    local Drawing = ctx.Drawing
    local RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager = ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager
    local LocalPlayer, Camera = ctx.LocalPlayer, ctx.Camera
--=====================================================================
M.CurrentTarget = nil
M.StickyTarget = nil
M.PrevSticky = nil
M.AimArrow = U.newDrawing("Square")
M.AimArrow.Visible = false
M.AimArrow.Filled = true

M.FovCircle = U.newDrawing("Circle")
M.FovCircle.Thickness = 2
M.FovCircle.NumSides = 64
M.FovCircle.Filled = false
M.FovCircle.Transparency = 1
M.FovCircle.Color = Color3.fromRGB(160,90,255)
M.FovCircle.Visible = false

M.FovFillCircles = {}
M.FovFillMaxCount = 8

function U.initFovFill()
    for i = 1, M.FovFillMaxCount do
        local c = U.newDrawing("Circle")
        c.Thickness = 1
        c.NumSides = 64
        c.Filled = true
        c.Transparency = 1
        c.Visible = false
        M.FovFillCircles[i] = c
    end
end
U.initFovFill()

function U.hideFovFill()
    for i = 1, #M.FovFillCircles do
        M.FovFillCircles[i].Visible = false
    end
end

function U.drawFovFill()
    if not Settings.Aim.FOVFillEnabled or not Settings.Aim.Enabled or not Settings.Aim.ShowFOV then
        U.hideFovFill(); return
    end
    local center = U.getFOVOrigin()
    local radius = Settings.Aim.FOV
    local centerColor = Settings.Aim.FOVFillCenterColor
    local edgeColor = Settings.Aim.FOVColor or Color3.fromRGB(160,90,255)
    local totalTransp = Settings.Aim.FOVFillTransparency
    local count = M.FovFillMaxCount

    for i = 1, count do
        local c = M.FovFillCircles[i]
        local t = i / count
        c.Position = center
        c.Radius = radius * t
        c.Color = centerColor:Lerp(edgeColor, t)
        c.Transparency = 1 - (1 - totalTransp) * t
        c.Visible = true
    end
end

M.TargetLinePool = {}
M.TargetLineSingle = U.newDrawing("Line")

M.DebugLine = U.newDrawing("Line")
M.DebugDot = U.newDrawing("Circle")
M.DebugDot.NumSides = 24
M.DebugDot.Filled = true
M.DebugDot.Radius = 3
M.DebugReactionText = U.newDrawing("Text")
M.DebugReactionText.Center = true
M.DebugReactionText.Outline = true
M.DebugReactionText.Size = 12
M.LastTargetTime = 0

function U.getAimPartForModel(model)
    if not model then return nil end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local bone = Settings.Aim.Bone
    if bone == "Head" then return model:FindFirstChild("Head") or hrp
    elseif bone == "Torso" then
        return model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
            or model:FindFirstChild("Chest") or hrp
    else
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local bp, bd = nil, math.huge
        local pref = {Head=true, UpperTorso=true, Torso=true, Chest=true, LowerTorso=true}
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                local sp, on = U.worldToScreen(p.CFrame.Position)
                if on then
                    local d = (sp - center).Magnitude
                    if not pref[p.Name] then d = d + 10000 end
                    if d < bd then bd, bp = d, p end
                end
            end
        end
        return bp or hrp
    end
end

function U.getAimPoint(part)
    if not part then return nil end
    local center = part.CFrame.Position
    if Settings.Aim.Prediction then
        local vel = part.AssemblyLinearVelocity
        if not vel or vel.Magnitude < 1 then vel = Vector3.zero end
        local ping = 0.05
        pcall(function()
            ping = math.clamp(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000, 0.01, 0.5)
        end)
        center = center + vel * ping * Settings.Aim.PredictionFactor
    end
    if Settings.Aim.AimAtHitPoint and not Settings.Aim.Prediction then
        local p = RaycastParams.new()
        p.FilterType = Enum.RaycastFilterType.Exclude
        p.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
        local res = Workspace:Raycast(Camera.CFrame.Position, center - Camera.CFrame.Position, p)
        if res and res.Instance and res.Instance:IsDescendantOf(part.Parent) then
            return res.Position
        end
    end
    return center
end

function U.resolveAimTarget(plr)
    local model = U.getCharacterForPlayer(plr)
    if not model then return nil end
    return model, U.getAimPartForModel(model)
end

function U.isOnGround(model)
    if not model then return true end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return true end
    if hum.FloorMaterial ~= Enum.Material.Air then return true end
    if math.abs(hrp.AssemblyLinearVelocity.Y) < 2 then return true end
    return false
end

function U.getClosestTarget()
    local origin = U.getFOVOrigin()
    local myTeam = LocalPlayer.Team
    local keyDown = U.isAimKeyDown()
    if M.StickyTarget and keyDown then
        local model, part = U.resolveAimTarget(M.StickyTarget)
        if model and part then
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local sp, on = U.worldToScreen(part.CFrame.Position)
                if on then
                    local d = (sp - origin).Magnitude
                    if d <= Settings.Aim.FOV * Settings.Aim.StickyMultiplier then
                        if (not Settings.Aim.GroundOnly) or U.isOnGround(model) then
                            return M.StickyTarget
                        end
                    end
                end
            end
        end
        M.StickyTarget = nil
    end
    if not keyDown then M.StickyTarget = nil end
    local best, bestScore = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local skip = false
            if Settings.Aim.TeamCheck and plr.Team == myTeam and myTeam ~= nil then skip = true end
            if not skip then
                local model, part = U.resolveAimTarget(plr)
                if model and part then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        if (not Settings.Aim.GroundOnly) or U.isOnGround(model) then
                            local sp, on = U.worldToScreen(part.CFrame.Position)
                            if on then
                                local d = (sp - origin).Magnitude
                                if d <= Settings.Aim.FOV and d < bestScore then
                                    if (not Settings.Aim.WallCheck) or U.isVisibleFromCam(part, model) then
                                        bestScore, best = d, plr
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if best and keyDown then M.StickyTarget = best end
    return best
end

function U.aimAt(plr)
    local model, part = U.resolveAimTarget(plr)
    if not part then return end
    local tp = U.getAimPoint(part)
    if not tp then return end
    pcall(function()
        if Camera.CameraType ~= Enum.CameraType.Custom and not M.FreecamActive then
            Camera.CameraType = Enum.CameraType.Custom
        end
    end)
    if M.FreecamActive then return end
    local camPos = Camera.CFrame.Position
    local targetCF = CFrame.lookAt(camPos, tp)
    if Settings.Aim.Instant then
        Camera.CFrame = targetCF
    else
        local a = math.clamp(Settings.Aim.Smoothness, 0.01, 1)
        a = U.applyCurve(a, Settings.Aim.SmoothCurve)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, a)
    end
end

function U.heartbeatAimbot()
    if not Settings.Aim.Enabled or M.FreecamActive then
        M.CurrentTarget = nil; M.StickyTarget = nil
        return
    end
    local keyDown = U.isAimKeyDown()
    local t = U.getClosestTarget()
    if t and t ~= M.PrevSticky and keyDown and Settings.Sound.TargetLockSound then
        U.playSound(Settings.Sound.TargetLockSoundId)
    end
    M.PrevSticky = t
    M.CurrentTarget = t
    if keyDown and t then U.aimAt(t) end
end

-- FIX: надёжная блокировка мыши
M.MouseLocked = false
function U.setMouseLock(state)
    if M.FreecamActive then
        if M.MouseLocked then
            pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.Default end)
            M.MouseLocked = false
        end
        return
    end
    if state == M.MouseLocked then return end
    M.MouseLocked = state
    pcall(function()
        if state then
            UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        else
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)
end

function U.drawAimVisuals(target)
    if Settings.Aim.ShowFOV and Settings.Aim.Enabled and not M.FreecamActive then
        M.FovCircle.Position = U.getFOVOrigin()
        M.FovCircle.Radius = Settings.Aim.FOV
        M.FovCircle.Color = Settings.Aim.FOVColor
        M.FovCircle.Visible = true
    else M.FovCircle.Visible = false end
    U.drawFovFill()

    if target and Settings.Aim.Enabled then
        local model, part = U.resolveAimTarget(target)
        local wp = part and part.CFrame.Position
        if wp then
            local sp, on = U.worldToScreen(wp)
            if on then
                local origin = U.getFOVOrigin()
                local dir = (sp - origin)
                if dir.Magnitude < 1 then dir = Vector2.new(0, 1) end
                dir = dir.Unit * 40
                local perp = Vector2.new(-dir.Y, dir.X).Unit * 8
                -- Square вместо Triangle
                M.AimArrow.Size = Vector2.new(10, 10)
                M.AimArrow.Position = Vector2.new(origin.X + dir.X - 5, origin.Y + dir.Y - 5)
                M.AimArrow.Color = Settings.ESP.ChamsTargetColor
                M.AimArrow.Filled = true
                M.AimArrow.Visible = true
                return
            end
        end
    end
    M.AimArrow.Visible = false
end

function U.drawAimDebug()
    if not Settings.Aim.DebugVisuals or not Settings.Aim.Enabled then
        M.DebugLine.Visible = false
        M.DebugDot.Visible = false
        M.DebugReactionText.Visible = false
        return
    end
    local t = M.CurrentTarget
    if t then
        local model, part = U.resolveAimTarget(t)
        if part then
            local camPos = Camera.CFrame.Position
            local dest = part.Position
            local p = RaycastParams.new()
            p.FilterType = Enum.RaycastFilterType.Exclude
            p.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
            local res = Workspace:Raycast(camPos, dest - camPos, p)
            local hitPos = res and res.Position or dest
            local from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            local to, on = U.worldToScreen(hitPos)
            if on then
                M.DebugLine.From = from; M.DebugLine.To = to
                M.DebugLine.Color = Color3.fromRGB(255, 220, 100)
                M.DebugLine.Thickness = 1
                M.DebugLine.Transparency = 0.4
                M.DebugLine.Visible = true
                M.DebugDot.Position = to
                M.DebugDot.Color = Color3.fromRGB(255, 100, 100)
                M.DebugDot.Transparency = 0.2
                M.DebugDot.Visible = true
                if M.LastTargetTime == 0 then M.LastTargetTime = tick() end
                local ms = math.floor((tick() - M.LastTargetTime) * 1000)
                M.DebugReactionText.Text = string.format("%dms", ms)
                M.DebugReactionText.Position = Vector2.new(to.X, to.Y - 15)
                M.DebugReactionText.Color = Color3.new(1,1,1)
                M.DebugReactionText.Visible = true
                return
            end
        end
    else M.LastTargetTime = 0 end
    M.DebugLine.Visible = false
    M.DebugDot.Visible = false
    M.DebugReactionText.Visible = false
end

--=====================================================================
-- TARGET LINE
--=====================================================================
function U.getTargetLineEndpoint(part)
    if not part then return nil end
    if Settings.Aim.AimAtHitPoint then
        local p = RaycastParams.new()
        p.FilterType = Enum.RaycastFilterType.Exclude
        p.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
        local res = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, p)
        if res and res.Instance and res.Instance:IsDescendantOf(part.Parent) then
            return res.Position
        end
    end
    return part.Position
end

function U.ensureTargetLinePool(count)
    while #M.TargetLinePool < count do
        table.insert(M.TargetLinePool, U.newDrawing("Line"))
    end
    while #M.TargetLinePool > count do
        local ln = table.remove(M.TargetLinePool)
        pcall(function() ln.Visible = false end)
    end
end

function U.drawTargetLine()
    if not Settings.Aim.TargetLine or M.FreecamActive then
        M.TargetLineSingle.Visible = false
        for _, ln in ipairs(M.TargetLinePool) do ln.Visible = false end
        return
    end
    if Settings.Aim.TargetLineOnlyAiming and not U.isAimKeyDown() then
        M.TargetLineSingle.Visible = false
        for _, ln in ipairs(M.TargetLinePool) do ln.Visible = false end
        return
    end
    local t = M.CurrentTarget
    if not t then
        M.TargetLineSingle.Visible = false
        for _, ln in ipairs(M.TargetLinePool) do ln.Visible = false end
        return
    end
    local model, part = U.resolveAimTarget(t)
    if not part then
        M.TargetLineSingle.Visible = false
        for _, ln in ipairs(M.TargetLinePool) do ln.Visible = false end
        return
    end
    local center = U.getFOVOrigin()
    local wp = U.getTargetLineEndpoint(part) or part.Position
    local screen, on = U.worldToScreen(wp)
    if not on then
        M.TargetLineSingle.Visible = false
        for _, ln in ipairs(M.TargetLinePool) do ln.Visible = false end
        return
    end
    local color = Settings.Aim.TargetLineColor
    local thick = Settings.Aim.TargetLineThickness
    local transp = Settings.Aim.TargetLineTransparency
    if Settings.Aim.TargetLineStyle == "Dashed" then
        M.TargetLineSingle.Visible = false
        local count = math.clamp(Settings.Aim.TargetLineDashCount, 2, 20)
        U.ensureTargetLinePool(count)
        local total = screen - center
        for i = 1, count do
            local ln = M.TargetLinePool[i]
            ln.From = center + total * ((i - 1) / count)
            ln.To = center + total * ((i - 0.5) / count)
            ln.Color = color; ln.Thickness = thick
            ln.Transparency = transp; ln.Visible = true
        end
    else
        for _, ln in ipairs(M.TargetLinePool) do ln.Visible = false end
        M.TargetLineSingle.From = center
        M.TargetLineSingle.To = screen
        M.TargetLineSingle.Color = color
        M.TargetLineSingle.Thickness = thick
        M.TargetLineSingle.Transparency = transp
        M.TargetLineSingle.Visible = true
    end
end

--=====================================================================
-- ITEM ESP
--=====================================================================

end
