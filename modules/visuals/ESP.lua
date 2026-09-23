return function(ctx)
    local M, U, Settings, Theme = ctx.M, ctx.U, ctx.Settings, ctx.Theme
    local cloneref, gethui, protect_gui, getgenv = ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv
    local Drawing = ctx.Drawing
    local RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager = ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager
    local LocalPlayer, Camera = ctx.LocalPlayer, ctx.Camera
--=====================================================================
function U.createESPStruct()
    local d = {}
    d.box = U.newDrawing("Square")
    d.corners = {}
    for i = 1, 8 do d.corners[i] = U.newDrawing("Line") end
    d.box3d = {}
    for i = 1, 12 do d.box3d[i] = U.newDrawing("Line") end
    d.tracer = U.newDrawing("Line")
    d.name = U.newDrawing("Text")
    d.dist = U.newDrawing("Text")
    d.nameShadow = U.newDrawing("Text")
    d.name.Center = true; d.name.Outline = true; d.name.Size = 14
    d.nameShadow.Center = true; d.nameShadow.Outline = false; d.nameShadow.Size = 14
    d.dist.Center = true; d.dist.Outline = true; d.dist.Size = 12
    d.skeleton = {}
    for i = 1, 20 do d.skeleton[i] = U.newDrawing("Line") end
    d.hpBg = U.newDrawing("Square")
    d.hpFill = U.newDrawing("Square")
    d.nametag = U.newDrawing("Text")
    d.nametag.Center = true; d.nametag.Outline = true; d.nametag.Size = 12
    -- FIX: используем Square вместо Triangle
    d.arrow = U.newDrawing("Square")
    d.arrow.Filled = true
    d.weapon = U.newDrawing("Text")
    d.weapon.Center = true; d.weapon.Outline = true
    d.highlights = {}
    return d
end

function U.destroyESPStruct(d)
    if not d then return end
    if d.box then pcall(function() d.box:Remove() end) end
    if d.corners then
        for _, c in pairs(d.corners) do pcall(function() c:Remove() end) end
    end
    if d.box3d then
        for _, l in pairs(d.box3d) do pcall(function() l:Remove() end) end
    end
    if d.skeleton then
        for _, l in pairs(d.skeleton) do pcall(function() l:Remove() end) end
    end
    if d.tracer then pcall(function() d.tracer:Remove() end) end
    if d.name then pcall(function() d.name:Remove() end) end
    if d.dist then pcall(function() d.dist:Remove() end) end
    if d.nameShadow then pcall(function() d.nameShadow:Remove() end) end
    if d.hpBg then pcall(function() d.hpBg:Remove() end) end
    if d.hpFill then pcall(function() d.hpFill:Remove() end) end
    if d.nametag then pcall(function() d.nametag:Remove() end) end
    if d.arrow then pcall(function() d.arrow:Remove() end) end
    if d.weapon then pcall(function() d.weapon:Remove() end) end
    if d.highlights then
        for _, h in pairs(d.highlights) do pcall(function() h:Destroy() end) end
        d.highlights = nil
    end
end

function U.hideAllESP(d)
    if not d then return end
    if d.box then pcall(function() d.box.Visible = false end) end
    if d.corners then for _, c in pairs(d.corners) do c.Visible = false end end
    if d.box3d then for _, l in pairs(d.box3d) do l.Visible = false end end
    if d.skeleton then for _, l in pairs(d.skeleton) do l.Visible = false end end
    if d.tracer then d.tracer.Visible = false end
    if d.name then d.name.Visible = false end
    if d.dist then d.dist.Visible = false end
    if d.nameShadow then d.nameShadow.Visible = false end
    if d.hpBg then d.hpBg.Visible = false end
    if d.hpFill then d.hpFill.Visible = false end
    if d.nametag then d.nametag.Visible = false end
    if d.arrow then d.arrow.Visible = false end
    if d.weapon then d.weapon.Visible = false end
end

--=====================================================================
-- CHAMS для врагов
--=====================================================================
function U.updateChamsForModel(model, isTarget)
    if not model or not model.Parent then return end
    local d = M.ESPData[model]
    if not d then
        d = U.createESPStruct()
        M.ESPData[model] = d
    end
    if not d.highlights then d.highlights = {} end

    if not Settings.ESP.ChamsEnabled then
        if d.highlights and d.highlights.main then
            d.highlights.main.Enabled = false
        end
        return
    end

    local color
    if isTarget then color = Settings.ESP.ChamsTargetColor
    elseif Settings.ESP.VisibleCheck and U.getVisibleStateForModel(model) then color = Settings.ESP.VisibleColor
    else color = Settings.ESP.ChamsColor end

    local h = d.highlights.main
    if not h or not h.Parent then
        h = Instance.new("Highlight")
        h.Name = "MixWareChams_main"
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = model
        h.Parent = model
        d.highlights.main = h
    end
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = Settings.ESP.ChamsTransp
    h.OutlineTransparency = Settings.ESP.ChamsTransp * 0.5
    h.Enabled = true
end

function U.updateChamsAll()
    if not Settings.ESP.ChamsEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local ch = plr.Character
            if ch then U.updateChamsForModel(ch, plr == M.CurrentTarget) end
        end
    end
end

--=====================================================================
-- HAND / WEAPON CHAMS для LocalPlayer
--=====================================================================
M.LocalMatOriginal = {}

function U.clearLocalMaterial()
    for part, orig in pairs(M.LocalMatOriginal) do
        if part and part.Parent then
            pcall(function()
                part.Material = orig.material
                part.Color = orig.color
                part.Transparency = orig.transparency
            end)
        end
    end
    M.LocalMatOriginal = {}
end

function U.collectLocalMaterialParts()
    local w = Settings.World
    local char = LocalPlayer.Character
    if not char then return {} end
    local parts = {}

    if w.HandChamsEnabled then
        local handNames = {"LeftHand","RightHand","LeftLowerArm","RightLowerArm",
                           "Left Arm","Right Arm","LeftUpperArm","RightUpperArm"}
        for _, name in ipairs(handNames) do
            local part = char:FindFirstChild(name)
            if part and part:IsA("BasePart") then
                table.insert(parts, {part = part, kind = "hands"})
            end
        end
    end

    if w.WeaponChamsEnabled then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                for _, d in ipairs(child:GetDescendants()) do
                    if d:IsA("BasePart") then
                        table.insert(parts, {part = d, kind = "weapon"})
                    end
                end
            end
            if child:IsA("Model") and not child:FindFirstChildOfClass("Humanoid") then
                local isWeapon = false
                for _, d in ipairs(child:GetDescendants()) do
                    if d:IsA("BasePart") then isWeapon = true; break end
                end
                if isWeapon then
                    local rh = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
                    local lh = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
                    local attached = false
                    for _, d in ipairs(child:GetDescendants()) do
                        if d:IsA("BasePart") then
                            if rh and (d.Position - rh.Position).Magnitude < 5 then attached = true; break end
                            if lh and (d.Position - lh.Position).Magnitude < 5 then attached = true; break end
                        end
                    end
                    if attached then
                        for _, d in ipairs(child:GetDescendants()) do
                            if d:IsA("BasePart") then
                                table.insert(parts, {part = d, kind = "weapon"})
                            end
                        end
                    end
                end
            end
        end
    end
    return parts
end

function U.applyLocalMaterial()
    local w = Settings.World
    if not w.HandChamsEnabled and not w.WeaponChamsEnabled then
        if next(M.LocalMatOriginal) ~= nil then U.clearLocalMaterial() end
        return
    end

    local parts = U.collectLocalMaterialParts()

    for _, entry in ipairs(parts) do
        local part = entry.part
        if part and part.Parent then
            if not M.LocalMatOriginal[part] then
                M.LocalMatOriginal[part] = {
                    material = part.Material,
                    color = part.Color,
                    transparency = part.Transparency,
                }
            end
            local mat, col, tr
            if entry.kind == "hands" then
                mat = Enum.Material[w.HandChamsMaterial] or Enum.Material.Neon
                col = w.HandChamsColor
                tr = w.HandChamsTransparency
            else
                mat = Enum.Material[w.WeaponChamsMaterial] or Enum.Material.Neon
                col = w.WeaponChamsColor
                tr = w.WeaponChamsTransparency
            end
            pcall(function()
                part.Material = mat
                part.Color = col
                part.Transparency = tr
            end)
        end
    end

    for part, orig in pairs(M.LocalMatOriginal) do
        local stillValid = false
        for _, entry in ipairs(parts) do
            if entry.part == part then stillValid = true; break end
        end
        if not stillValid then
            if part.Parent then
                pcall(function()
                    part.Material = orig.material
                    part.Color = orig.color
                    part.Transparency = orig.transparency
                end)
            end
            M.LocalMatOriginal[part] = nil
        end
    end
end

--=====================================================================
-- TARGET PULSE
--=====================================================================
function U.getTargetPulseAlpha()
    if not Settings.Aim.TargetPulseEnabled then return 1 end
    local s = Settings.Aim.TargetPulseSpeed
    local minA = Settings.Aim.TargetPulseMin
    local maxA = Settings.Aim.TargetPulseMax
    local t = (math.sin(tick() * s * math.pi * 2) + 1) * 0.5
    return minA + (maxA - minA) * t
end

--=====================================================================
-- ESP DRAW
--=====================================================================
local ESP_INTERVAL = 1/60
M.LastESPUpdate = 0

U.SkeletonJoints = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    {"Head","Torso"},{"Torso","Left Arm"},{"Left Arm","LeftLeg"},
    {"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"},
}

function U.drawSkeleton(model, d, color, thick)
    local idx = 0
    for _, joint in ipairs(U.SkeletonJoints) do
        local a = model:FindFirstChild(joint[1])
        local b = model:FindFirstChild(joint[2])
        if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
            idx = idx + 1
            if idx > #d.skeleton then break end
            local ln = d.skeleton[idx]
            local aS, aOn = U.worldToScreen(a.CFrame.Position)
            local bS, bOn = U.worldToScreen(b.CFrame.Position)
            if aOn and bOn then
                ln.From = aS; ln.To = bS
                ln.Color = color; ln.Thickness = thick
                ln.Transparency = 0.2; ln.Visible = true
            else ln.Visible = false end
        end
    end
    for i = idx + 1, #d.skeleton do d.skeleton[i].Visible = false end
end

-- FIX: drawArrow через Square
function U.drawArrow(d, worldPos, color, size)
    if not d or not d.arrow then return end
    local sp, on = U.worldToScreen(worldPos)
    if on then
        d.arrow.Visible = false
        return
    end
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local rel = worldPos - Camera.CFrame.Position
    local x = rel:Dot(Camera.CFrame.RightVector)
    local y = rel:Dot(Camera.CFrame.UpVector)
    local mag = math.sqrt(x*x + y*y)
    if mag < 0.01 then
        d.arrow.Visible = false
        return
    end
    local dir = Vector2.new(x/mag, -y/mag)
    local radius = math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) * 0.35
    local tip = center + dir * radius
    d.arrow.Size = Vector2.new(size, size)
    d.arrow.Position = Vector2.new(tip.X - size/2, tip.Y - size/2)
    d.arrow.Color = color
    d.arrow.Filled = true
    d.arrow.Visible = true
end

function U.getFadeAlpha(dist, maxDist)
    if not Settings.ESP.DistanceFade then return 1 end
    local fs = maxDist * math.clamp(Settings.ESP.DistanceFadeStart, 0.1, 1)
    if dist <= fs then return 1 end
    if dist >= maxDist then return 0 end
    return 1 - ((dist - fs) / (maxDist - fs))
end

function U.getWeaponName(model)
    local tool = model:FindFirstChildWhichIsA("Tool")
    if tool then return tool.Name end
    local rh = model:FindFirstChild("RightHand") or model:FindFirstChild("Right Arm")
    if rh then
        for _, c in ipairs(rh:GetChildren()) do
            if c:IsA("Tool") or c:IsA("Model") then return c.Name end
        end
    end
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Model") and not child:FindFirstChildOfClass("Humanoid") then
            return child.Name
        end
    end
    return nil
end

function U.drawESPForModel(model, plr)
    local d = M.ESPData[model]
    if not d then
        d = U.createESPStruct()
        M.ESPData[model] = d
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then U.hideAllESP(d); return end
    local cf = U.getModelCFrame(model)
    if not cf then U.hideAllESP(d); return end
    local dist = (Camera.CFrame.Position - cf.Position).Magnitude
    if dist > Settings.ESP.MaxDistance then U.hideAllESP(d); return end

    local alpha = U.getFadeAlpha(dist, Settings.ESP.MaxDistance)
    local isTarget = (plr == M.CurrentTarget)
    if isTarget and Settings.Aim.TargetPulseEnabled then
        alpha = alpha * U.getTargetPulseAlpha()
    end

    local visible = true
    if Settings.ESP.VisibleCheck then visible = U.getVisibleStateForModel(model) end
    local override = nil
    if Settings.ESP.VisibleCheck and visible then override = Settings.ESP.VisibleColor end

    local topPos, botPos = U.getModelBounds(model)
    if not topPos then
        topPos = cf.Position + Vector3.new(0, 3, 0)
        botPos = cf.Position - Vector3.new(0, 3, 0)
    end
    local topS, topOn = U.worldToScreen(topPos)
    local botS, botOn = U.worldToScreen(botPos)
    if not topOn and not botOn then U.hideAllESP(d); return end

    local height = botS.Y - topS.Y
    local width = height * 0.5
    local x = topS.X - width / 2
    local y = topS.Y

    if Settings.ESP.BoxEnabled then
        d.box.Size = Vector2.new(width, height)
        d.box.Position = Vector2.new(x, y)
        d.box.Color = override or Settings.ESP.BoxColor
        d.box.Thickness = Settings.ESP.BoxThickness
        d.box.Transparency = alpha
        d.box.Filled = false; d.box.Visible = true
    else d.box.Visible = false end

    if Settings.ESP.CornerEnabled then
        local L, t = Settings.ESP.CornerLength, Settings.ESP.CornerThickness
        local pts = {
            {Vector2.new(x,y),Vector2.new(x+L,y)},
            {Vector2.new(x,y),Vector2.new(x,y+L)},
            {Vector2.new(x+width,y),Vector2.new(x+width-L,y)},
            {Vector2.new(x+width,y),Vector2.new(x+width,y+L)},
            {Vector2.new(x,y+height),Vector2.new(x+L,y+height)},
            {Vector2.new(x,y+height),Vector2.new(x,y+height-L)},
            {Vector2.new(x+width,y+height),Vector2.new(x+width-L,y+height)},
            {Vector2.new(x+width,y+height),Vector2.new(x+width,y+height-L)},
        }
        for i, s in ipairs(pts) do
            local ln = d.corners[i]
            ln.From = s[1]; ln.To = s[2]
            ln.Color = override or Settings.ESP.CornerColor
            ln.Thickness = t; ln.Transparency = alpha; ln.Visible = true
        end
    else for _, c in pairs(d.corners) do c.Visible = false end end

    if Settings.ESP.Box3DEnabled then
        local edges = {{1,2},{3,4},{5,6},{7,8},{1,3},{2,4},{5,7},{6,8},{1,5},{2,6},{3,7},{4,8}}
        local corners = {}
        local ok, mcf, size = pcall(function()
            local c, s = model:GetBoundingBox()
            return c, s
        end)
        if ok and mcf and size then
            local hx, hy, hz = size.X/2, size.Y/2, size.Z/2
            for xi=-1,1,2 do for yi=-1,1,2 do for zi=-1,1,2 do
                local wp = mcf * Vector3.new(hx*xi, hy*yi, hz*zi)
                local sp, on = U.worldToScreen(wp)
                table.insert(corners, {sp, on})
            end end end
            for i, e in ipairs(edges) do
                local ln = d.box3d[i]
                local a, b = corners[e[1]], corners[e[2]]
                if a and b and a[2] and b[2] then
                    ln.From = a[1]; ln.To = b[1]
                    ln.Color = override or Settings.ESP.Box3DColor
                    ln.Thickness = 1; ln.Transparency = alpha; ln.Visible = true
                else ln.Visible = false end
            end
        else for _, l in pairs(d.box3d) do l.Visible = false end end
    else for _, l in pairs(d.box3d) do l.Visible = false end end

    if Settings.ESP.TracerEnabled then
        local vp = Camera.ViewportSize
        local origin
        if Settings.ESP.TracerOrigin == "Top" then origin = Vector2.new(vp.X/2, 0)
        elseif Settings.ESP.TracerOrigin == "Center" then origin = Vector2.new(vp.X/2, vp.Y/2)
        else origin = Vector2.new(vp.X/2, vp.Y) end
        d.tracer.From = origin; d.tracer.To = botS
        d.tracer.Color = override or Settings.ESP.TracerColor
        d.tracer.Thickness = 1; d.tracer.Transparency = alpha; d.tracer.Visible = true
    else d.tracer.Visible = false end

    local displayName = model.Name
    if plr then displayName = (plr.DisplayName ~= "" and plr.DisplayName) or plr.Name end
    local namePos = Vector2.new(x + width/2, y - 16)
    local nameColor = override or Color3.new(1,1,1)
    if Settings.ESP.NameShadow then
        d.nameShadow.Text = displayName
        d.nameShadow.Position = Vector2.new(namePos.X + 1, namePos.Y + 1)
        d.nameShadow.Color = Color3.new(0,0,0)
        d.nameShadow.Transparency = math.min(1, alpha + 0.2)
        d.nameShadow.Visible = Settings.ESP.NameEnabled
    else d.nameShadow.Visible = false end
    d.name.Text = displayName
    d.name.Position = namePos
    d.name.Color = nameColor
    d.name.Transparency = alpha
    d.name.Visible = Settings.ESP.NameEnabled

    d.dist.Text = string.format("[%d]", math.floor(dist))
    d.dist.Position = Vector2.new(x + width/2, y + height + 2)
    d.dist.Color = override or Color3.fromRGB(200,200,200)
    d.dist.Transparency = alpha
    d.dist.Visible = Settings.ESP.DistanceEnabled

    if Settings.ESP.WeaponNameEnabled then
        local w = U.getWeaponName(model)
        if w then
            d.weapon.Text = "[" .. w .. "]"
            d.weapon.Position = Vector2.new(x + width/2, y - 30)
            d.weapon.Color = Settings.ESP.WeaponNameColor
            d.weapon.Size = Settings.ESP.WeaponNameSize
            d.weapon.Transparency = alpha
            d.weapon.Visible = true
        else d.weapon.Visible = false end
    else d.weapon.Visible = false end

    if Settings.ESP.SkeletonEnabled then
        U.drawSkeleton(model, d, override or Settings.ESP.SkeletonColor, Settings.ESP.SkeletonThickness)
        for _, l in pairs(d.skeleton) do l.Transparency = alpha end
    else for _, l in pairs(d.skeleton) do l.Visible = false end end

    if Settings.ESP.HealthBarEnabled and hum then
        local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        local bw = Settings.ESP.HealthBarWidth
        local bh = height
        local off = Settings.ESP.HealthBarOffset
        local bx = x - bw - off
        d.hpBg.Size = Vector2.new(bw, bh)
        d.hpBg.Position = Vector2.new(bx, y)
        d.hpBg.Color = Color3.fromRGB(30, 20, 40)
        d.hpBg.Filled = true; d.hpBg.Transparency = math.min(1, alpha + 0.2); d.hpBg.Visible = true
        local fillH = bh * hpRatio
        d.hpFill.Size = Vector2.new(bw, fillH)
        d.hpFill.Position = Vector2.new(bx, y + (bh - fillH))
        local r, g, b
        if hpRatio > 0.5 then
            local t = (hpRatio - 0.5) / 0.5
            r = 1 - t; g = 1; b = 0.1
        elseif hpRatio > 0.2 then
            local t = (hpRatio - 0.2) / 0.3
            r = 1; g = 0.4 + t * 0.6; b = 0.1
        else
            local t = hpRatio / 0.2
            r = 1; g = 0.4 * t; b = 0.1
        end
        d.hpFill.Color = Color3.new(r, g, b)
        d.hpFill.Filled = true; d.hpFill.Transparency = alpha; d.hpFill.Visible = true
    else d.hpBg.Visible = false; d.hpFill.Visible = false end

    if Settings.ESP.NametagsEnabled and hum then
        local parts = {}
        if Settings.ESP.NametagsShowHP then table.insert(parts, string.format("[%d HP]", math.floor(hum.Health))) end
        if Settings.ESP.NametagsShowDist then table.insert(parts, string.format("[%dm]", math.floor(dist))) end
        d.nametag.Text = table.concat(parts, " ")
        d.nametag.Position = Vector2.new(x + width/2, y - 44)
        d.nametag.Color = nameColor
        d.nametag.Transparency = alpha; d.nametag.Visible = true
    else d.nametag.Visible = false end

    if Settings.ESP.ArrowsEnabled then
        local hp = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
        if hp then U.drawArrow(d, hp.Position, override or Settings.ESP.ArrowsColor, Settings.ESP.ArrowsSize) end
    else d.arrow.Visible = false end
end

function U.drawESP()
    local now = tick()
    if now - M.LastESPUpdate < ESP_INTERVAL then return end
    M.LastESPUpdate = now
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local ch, hrp = U.getCharacterForPlayer(plr)
            if ch and hrp then seen[ch] = true; U.drawESPForModel(ch, plr) end
        end
    end
    for m, d in pairs(M.ESPData) do
        if not seen[m] or not m.Parent then
            U.destroyESPStruct(d); M.ESPData[m] = nil
        end
    end
end

--=====================================================================
-- CROSSHAIR
--=====================================================================

end
