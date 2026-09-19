--[[
    MixWare.lol v2.6 (register-limit fix)
--]]

--=====================================================================
-- API ОБЁРТКИ
--=====================================================================
local cloneref = cloneref or function(o) return o end
local gethui = gethui or function() return game:GetService("CoreGui") end
local protect_gui = (syn and syn.protect_gui) or function() end
local getgenv = getgenv or function() return _G end

local Drawing = Drawing or setmetatable({}, {
    __index = function() return function()
        return setmetatable({}, {
            __index = function() return nil end,
            __newindex = function() end,
        })
    end end
})

local mouse1click = mouse1click or function() end
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local UIS = cloneref(game:GetService("UserInputService"))
local Workspace = cloneref(game:GetService("Workspace"))
local Lighting = cloneref(game:GetService("Lighting"))
local HttpService = cloneref(game:GetService("HttpService"))
local Stats = cloneref(game:GetService("Stats"))
local SoundService = cloneref(game:GetService("SoundService"))
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--=====================================================================
-- ГЛОБАЛЬНЫЙ ОБЪЕКТ
--=====================================================================
local M = {}
M.U = {}
U = M.U
M.ESPData = {}
M.AllDrawings = {}
M.ItemDrawings = {}
M.WorldDrawings = {}
M.Connections = {}
M.ActiveConfigName = "none"

--=====================================================================
-- THEME
--=====================================================================
M.Themes = {
    Purple = {Bg=Color3.fromRGB(18,14,26),Bg2=Color3.fromRGB(26,18,38),Panel=Color3.fromRGB(38,26,54),Row=Color3.fromRGB(44,30,62),Title=Color3.fromRGB(40,26,58),Accent=Color3.fromRGB(160,90,255),Accent2=Color3.fromRGB(220,120,255),Text=Color3.fromRGB(235,225,250),TextDim=Color3.fromRGB(160,140,190),Good=Color3.fromRGB(180,100,255),Bad=Color3.fromRGB(220,70,130),Stroke=Color3.fromRGB(85,55,130)},
    Dark = {Bg=Color3.fromRGB(15,15,18),Bg2=Color3.fromRGB(22,22,26),Panel=Color3.fromRGB(32,32,38),Row=Color3.fromRGB(38,38,44),Title=Color3.fromRGB(34,34,40),Accent=Color3.fromRGB(90,140,240),Accent2=Color3.fromRGB(140,180,255),Text=Color3.fromRGB(230,230,240),TextDim=Color3.fromRGB(140,140,150),Good=Color3.fromRGB(90,140,240),Bad=Color3.fromRGB(210,70,90),Stroke=Color3.fromRGB(60,60,70)},
    Blue = {Bg=Color3.fromRGB(12,18,30),Bg2=Color3.fromRGB(18,26,42),Panel=Color3.fromRGB(26,40,62),Row=Color3.fromRGB(32,48,74),Title=Color3.fromRGB(28,44,68),Accent=Color3.fromRGB(60,140,255),Accent2=Color3.fromRGB(120,190,255),Text=Color3.fromRGB(220,235,255),TextDim=Color3.fromRGB(140,170,210),Good=Color3.fromRGB(60,140,255),Bad=Color3.fromRGB(220,80,110),Stroke=Color3.fromRGB(60,100,150)},
    Red = {Bg=Color3.fromRGB(20,12,14),Bg2=Color3.fromRGB(30,16,20),Panel=Color3.fromRGB(46,22,26),Row=Color3.fromRGB(56,28,32),Title=Color3.fromRGB(50,24,30),Accent=Color3.fromRGB(230,70,90),Accent2=Color3.fromRGB(255,130,150),Text=Color3.fromRGB(250,230,235),TextDim=Color3.fromRGB(200,150,160),Good=Color3.fromRGB(230,70,90),Bad=Color3.fromRGB(255,50,60),Stroke=Color3.fromRGB(120,50,60)},
    Pink = {Bg=Color3.fromRGB(24,14,22),Bg2=Color3.fromRGB(36,20,32),Panel=Color3.fromRGB(54,28,48),Row=Color3.fromRGB(66,34,58),Title=Color3.fromRGB(58,30,52),Accent=Color3.fromRGB(255,110,180),Accent2=Color3.fromRGB(255,170,220),Text=Color3.fromRGB(250,225,240),TextDim=Color3.fromRGB(200,150,180),Good=Color3.fromRGB(255,110,180),Bad=Color3.fromRGB(230,60,120),Stroke=Color3.fromRGB(140,70,110)},
}
local Theme = M.Themes.Purple
M.Theme = Theme

M.ITEM_ESP_PATHS = {
    "Workspace.Spawned.MouselgnoreFolder.Loot",
    "Workspace.Spawned.Destructibles",
}

--=====================================================================
-- SETTINGS
--=====================================================================
local Settings = {
    ESP = {
        Enabled=false, ChamsEnabled=false, ChamsColor=Color3.fromRGB(160,90,255), ChamsTransp=0.5,
        ChamsTargetColor=Color3.fromRGB(255,60,130),
        BoxEnabled=false, BoxColor=Color3.fromRGB(200,170,255), BoxThickness=1,
        CornerEnabled=false, CornerColor=Color3.fromRGB(180,100,255), CornerLength=10, CornerThickness=1,
        Box3DEnabled=false, Box3DColor=Color3.fromRGB(220,120,255),
        TracerEnabled=false, TracerColor=Color3.fromRGB(200,100,255), TracerOrigin="Bottom",
        NameEnabled=true, NameShadow=false, DistanceEnabled=true, MaxDistance=1000,
        VisibleCheck=false, VisibleColor=Color3.fromRGB(200,130,255),
        PulseEnabled=false, PulseSpeed=1.5, PulseMin=0.35, PulseMax=0.85,
        SkeletonEnabled=false, SkeletonColor=Color3.fromRGB(200,130,255), SkeletonThickness=1,
        HealthBarEnabled=false, HealthBarWidth=4, HealthBarOffset=6,
        NametagsEnabled=false, NametagsShowHP=true, NametagsShowDist=true,
        ArrowsEnabled=false, ArrowsColor=Color3.fromRGB(200,130,255), ArrowsSize=14,
        WeaponNameEnabled=false, WeaponNameColor=Color3.fromRGB(255,180,220), WeaponNameSize=12,
        DistanceFade=false, DistanceFadeStart=0.7,
    },
    Crosshair = {Enabled=false,Style="Cross",Color=Color3.fromRGB(255,255,255),OutlineColor=Color3.fromRGB(0,0,0),Gap=4,Length=8,Thickness=1,Dot=true,DotSize=2,CircleRadius=12,Outline=true,Rainbow=false},
    ItemESP = {Enabled=false,Color=Color3.fromRGB(220,180,100),MaxDistance=500,TextEnabled=true,RefreshRate=0.2,SelectedItems={}},
    WorldESP = {Enabled=false,Color=Color3.fromRGB(120,220,200),MaxDistance=500,TextEnabled=true},
    World = {FullBright=false,NoFog=false,CustomTimeEnabled=false,CustomTime=14,CustomAmbientEnabled=false,AmbientColor=Color3.fromRGB(178,178,178),CameraFOVEnabled=false,CameraFOV=70,DisableSunRays=false,DisableAtmosphere=false,RemoveGrass=false},
    InvESP = {Enabled=false,Transparency=0.35,ShowLocal=true,FontSize=14,ShowTools=true,ShowHealth=true,RefreshInterval=0.25},
    Aim = {
        Enabled=false, FOV=120, ShowFOV=true, Instant=false, Smoothness=0.15,
        SmoothCurve="Linear", Bone="Head", KeyName="MouseButton2",
        WallCheck=false, TeamCheck=true, AimAtHitPoint=true, StickyMultiplier=2.0,
        Prediction=false, PredictionFactor=1.0,
        HeadMover=false, HeadMoverDistance=30, HeadMoverOnlyAimKey=true, HeadMoverSpeed=1.0,
        TargetLine=false, TargetLineColor=Color3.fromRGB(255,100,200),
        TargetLineThickness=1, TargetLineTransparency=0.2, TargetLineOnlyAiming=true,
        TargetLineStyle="Solid", TargetLineDashCount=8,
        GroundOnly=false, DebugVisuals=false,
    },
    Trigger = {Enabled=false,Delay=0.05,TeamCheck=true,WallCheck=false,OnlyAimKey=true},
    Misc = {TPWalkEnabled=false,TPWalkSpeed=20,InfJump=false,WalkSpeed=16,JumpPower=50,AntiFling=false},
    Sound = {KillSound=true,TargetLockSound=true,KillSoundId="rbxassetid://5275866553",TargetLockSoundId="rbxassetid://876939830"},
    UI = {Open=true,MenuKey=Enum.KeyCode.RightShift,UnloadKey=Enum.KeyCode.End,Watermark=true,Notifications=true,Theme="Purple",Scale="Medium"},
}
M.Settings = Settings

--=====================================================================
-- УТИЛИТЫ (в таблице U)
--=====================================================================
local U = M.U

function U.addConn(c) table.insert(M.Connections, c); return c end
function U.disconnectAll()
    for _, c in ipairs(M.Connections) do pcall(function() c:Disconnect() end) end
    M.Connections = {}
end

function U.worldToScreen(pos)
    local sp, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), on, sp.Z
end
function U.getFOVOrigin() return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) end

function U.isAimKeyDown()
    local kn = Settings.Aim.KeyName
    if kn == "MouseButton2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
    if kn == "MouseButton1" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
    local kc = Enum.KeyCode[kn]
    if kc then return UIS:IsKeyDown(kc) end
    return false
end

function U.isVisibleFromCam(part, targetModel)
    if not part then return false end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    p.IgnoreWater = true
    local res = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, p)
    if not res or not res.Instance then return true end
    if targetModel and res.Instance:IsDescendantOf(targetModel) then return true end
    if res.Instance == part then return true end
    return false
end

function U.getVisibleStateForModel(model)
    if not model then return false end
    local head = model:FindFirstChild("Head")
    local torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
        or model:FindFirstChild("Chest") or model:FindFirstChild("HumanoidRootPart")
    if head and U.isVisibleFromCam(head, model) then return true end
    if torso and U.isVisibleFromCam(torso, model) then return true end
    return false
end

function U.belongsToLocalPlayer(inst)
    if not inst then return false end
    local ch = LocalPlayer.Character
    if not ch then return false end
    if inst == ch then return true end
    if inst:IsDescendantOf(ch) then return true end
    return false
end

function U.applyCurve(t, curve)
    if curve == "EaseOut" then return 1 - (1 - t) * (1 - t)
    elseif curve == "Sine" then return math.sin(t * math.pi / 2) end
    return t
end

function U.getCharacterForPlayer(plr)
    if not plr then return nil, nil, nil end
    local ch = plr.Character
    if not ch then return nil, nil, nil end
    return ch, ch:FindFirstChild("HumanoidRootPart"), ch:FindFirstChildOfClass("Humanoid")
end

function U.getModelCFrame(model)
    if not model or not model.Parent then return nil end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.CFrame end
    local ok, piv = pcall(function() return model:GetPivot() end)
    if ok then return piv end
    return nil
end

function U.getModelBounds(model)
    local head = model:FindFirstChild("Head")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if head and hrp then
        return head.CFrame.Position + Vector3.new(0, 0.5, 0),
               hrp.CFrame.Position - Vector3.new(0, 3, 0)
    end
    local ok, cf, size = pcall(function()
        local c, s = model:GetBoundingBox()
        return c, s
    end)
    if ok and cf and size then
        return cf.Position + Vector3.new(0, size.Y/2, 0),
               cf.Position - Vector3.new(0, size.Y/2, 0)
    end
    return nil, nil
end

function U.colorToHex(c) if typeof(c) ~= "Color3" then return c end return "#"..c:ToHex() end
function U.hexToColor(s)
    if type(s) ~= "string" or string.sub(s,1,1) ~= "#" then return s end
    local ok, c = pcall(function() return Color3.fromHex(s) end)
    return ok and c or Color3.new(1,1,1)
end

function U.serializeSettings(tbl)
    local out = {}
    for k, v in pairs(tbl) do
        if typeof(v) == "Color3" then out[k] = U.colorToHex(v)
        elseif type(v) == "table" then out[k] = U.serializeSettings(v)
        else out[k] = v end
    end
    return out
end

function U.deserializeSettings(dst, src)
    for k, v in pairs(src) do
        if type(v) == "string" and string.sub(v,1,1) == "#" then dst[k] = U.hexToColor(v)
        elseif type(v) == "table" and type(dst[k]) == "table" then U.deserializeSettings(dst[k], v)
        else dst[k] = v end
    end
end

function U.setPath(path, value)
    local keys = {}
    for k in string.gmatch(path, "[^%.]+") do table.insert(keys, k) end
    local target = Settings
    for i = 1, #keys - 1 do
        target = target[keys[i]]
        if type(target) ~= "table" then return end
    end
    target[keys[#keys]] = value
end

function U.getPath(path)
    local keys = {}
    for k in string.gmatch(path, "[^%.]+") do table.insert(keys, k) end
    local target = Settings
    for i = 1, #keys do
        if type(target) ~= "table" then return nil end
        target = target[keys[i]]
    end
    return target
end

function U.resolveFolderPath(pathStr)
    if not pathStr or pathStr == "" then return nil end
    local ok, result = pcall(function()
        local parts = {}
        for p in string.gmatch(pathStr, "[^%.]+") do table.insert(parts, p) end
        local cur = game
        for i, name in ipairs(parts) do
            if i == 1 and name == "Workspace" then cur = Workspace
            elseif i == 1 and name == "game" then cur = game
            else
                if cur:IsA("DataModel") then cur = cur:GetService(name)
                else cur = cur:FindFirstChild(name) end
            end
            if not cur then return nil end
        end
        return cur
    end)
    if ok then return result end
    return nil
end

function U.playSound(id)
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = id; s.Volume = 0.5
        s.Parent = SoundService
        s:Play()
        task.delay(3, function() s:Destroy() end)
    end)
end

function U.newDrawing(kind)
    local ok, obj = pcall(function() return Drawing.new(kind) end)
    if ok and obj then table.insert(M.AllDrawings, obj); return obj end
    return {
        Remove=function() end,Visible=false,Color=Color3.new(),Thickness=1,Transparency=1,
        From=Vector2.new(),To=Vector2.new(),Position=Vector2.new(),Size=Vector2.new(),
        Text="",Center=false,Outline=false,
        PointA=Vector2.new(),PointB=Vector2.new(),PointC=Vector2.new(),
        Filled=false,Radius=0,NumSides=64,
    }
end

--=====================================================================
-- NOTIFICATIONS
--=====================================================================
U.NotifyHolder = nil
function U.setupNotifyHolder(screenGui)
    local h = Instance.new("Frame")
    h.Size = UDim2.new(0, 280, 1, -40)
    h.Position = UDim2.new(1, -300, 0, 20)
    h.BackgroundTransparency = 1
    h.Parent = screenGui
    local l = Instance.new("UIListLayout", h)
    l.Padding = UDim.new(0, 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.VerticalAlignment = Enum.VerticalAlignment.Bottom
    U.NotifyHolder = h
end

function U.notify(text, color)
    if not Settings.UI.Notifications or not U.NotifyHolder then return end
    color = color or Theme.Accent
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 34)
    toast.BackgroundColor3 = Theme.Title
    toast.BackgroundTransparency = 0.1
    toast.BorderSizePixel = 0
    toast.Parent = U.NotifyHolder
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", toast)
    stroke.Color = color; stroke.Thickness = 1; stroke.Transparency = 0.3
    local accent = Instance.new("Frame", toast)
    accent.Size = UDim2.new(0, 3, 1, -8)
    accent.Position = UDim2.new(0, 4, 0, 4)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)
    local lbl = Instance.new("TextLabel", toast)
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    task.spawn(function()
        task.wait(3)
        for i = 1, 20 do
            toast.BackgroundTransparency = toast.BackgroundTransparency + 0.045
            stroke.Transparency = stroke.Transparency + 0.035
            lbl.TextTransparency = i / 20
            accent.BackgroundTransparency = i / 20
            task.wait(0.02)
        end
        toast:Destroy()
    end)
end

--=====================================================================
-- ESP STRUCTS
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
    d.arrow = U.newDrawing("Triangle")
    d.arrow.Filled = true
    d.weapon = U.newDrawing("Text")
    d.weapon.Center = true; d.weapon.Outline = true
    return d
end

function U.destroyESPStruct(d)
    pcall(function() d.box:Remove() end)
    for _, c in pairs(d.corners) do pcall(function() c:Remove() end) end
    for _, l in pairs(d.box3d) do pcall(function() l:Remove() end) end
    for _, l in pairs(d.skeleton) do pcall(function() l:Remove() end) end
    pcall(function() d.tracer:Remove() end)
    pcall(function() d.name:Remove() end)
    pcall(function() d.dist:Remove() end)
    pcall(function() d.nameShadow:Remove() end)
    pcall(function() d.hpBg:Remove() end)
    pcall(function() d.hpFill:Remove() end)
    pcall(function() d.nametag:Remove() end)
    pcall(function() d.arrow:Remove() end)
    pcall(function() d.weapon:Remove() end)
    if d.highlight then pcall(function() d.highlight:Destroy() end) end
end

function U.hideAllESP(d)
    pcall(function() d.box.Visible = false end)
    for _, c in pairs(d.corners) do c.Visible = false end
    for _, l in pairs(d.box3d) do l.Visible = false end
    for _, l in pairs(d.skeleton) do l.Visible = false end
    d.tracer.Visible = false
    d.name.Visible = false
    d.dist.Visible = false
    d.nameShadow.Visible = false
    d.hpBg.Visible = false
    d.hpFill.Visible = false
    d.nametag.Visible = false
    d.arrow.Visible = false
    d.weapon.Visible = false
    if d.highlight then d.highlight.Enabled = false end
end

--=====================================================================
-- ESP RENDER
--=====================================================================
local ESP_INTERVAL = 1/60
M.LastESPUpdate = 0

function U.updateChamsForModel(model, isTarget)
    local d = M.ESPData[model]
    if not d then return end
    if not Settings.ESP.ChamsEnabled then
        if d.highlight then d.highlight.Enabled = false end
        return
    end
    if not model or not model.Parent then return end
    if not d.highlight or not d.highlight.Parent then
        local existing = model:FindFirstChild("MixWareChams")
        if existing and existing:IsA("Highlight") then
            d.highlight = existing
        else
            local h = Instance.new("Highlight")
            h.Name = "MixWareChams"
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Adornee = model
            h.Parent = model
            d.highlight = h
        end
    end
    local color
    if isTarget then color = Settings.ESP.ChamsTargetColor
    elseif Settings.ESP.VisibleCheck and U.getVisibleStateForModel(model) then color = Settings.ESP.VisibleColor
    else color = Settings.ESP.ChamsColor end
    d.highlight.FillColor = color
    d.highlight.OutlineColor = color
    d.highlight.FillTransparency = Settings.ESP.ChamsTransp
    d.highlight.OutlineTransparency = Settings.ESP.ChamsTransp * 0.5
    d.highlight.Enabled = true
end

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

function U.drawArrow(d, worldPos, color, size)
    local sp, on = U.worldToScreen(worldPos)
    if on then d.arrow.Visible = false; return end
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local rel = worldPos - Camera.CFrame.Position
    local x = rel:Dot(Camera.CFrame.RightVector)
    local y = rel:Dot(Camera.CFrame.UpVector)
    local mag = math.sqrt(x*x + y*y)
    if mag < 0.01 then d.arrow.Visible = false; return end
    local dir = Vector2.new(x/mag, -y/mag)
    local radius = math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) * 0.35
    local tip = center + dir * radius
    local perp = Vector2.new(-dir.Y, dir.X) * (size/2)
    d.arrow.PointA = tip
    d.arrow.PointB = center + dir * (radius - size) + perp
    d.arrow.PointC = center + dir * (radius - size) - perp
    d.arrow.Color = color; d.arrow.Filled = true; d.arrow.Visible = true
end

function U.getFadeAlpha(dist, maxDist)
    if not Settings.ESP.DistanceFade then return 1 end
    local fs = maxDist * math.clamp(Settings.ESP.DistanceFadeStart, 0.1, 1)
    if dist <= fs then return 1 end
    if dist >= maxDist then return 0 end
    return 1 - ((dist - fs) / (maxDist - fs))
end

function U.getPulseAlpha(now)
    if not Settings.ESP.PulseEnabled then return 1 end
    local s = Settings.ESP.PulseSpeed
    local minA = Settings.ESP.PulseMin
    local maxA = Settings.ESP.PulseMax
    local t = (math.sin(now * s * math.pi * 2) + 1) * 0.5
    return minA + (maxA - minA) * t
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
    local visible = true
    if Settings.ESP.VisibleCheck then visible = U.getVisibleStateForModel(model) end
    if Settings.ESP.PulseEnabled and Settings.ESP.VisibleCheck and not visible then
        alpha = alpha * U.getPulseAlpha(tick())
    end
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

    -- Box
    if Settings.ESP.BoxEnabled then
        d.box.Size = Vector2.new(width, height)
        d.box.Position = Vector2.new(x, y)
        d.box.Color = override or Settings.ESP.BoxColor
        d.box.Thickness = Settings.ESP.BoxThickness
        d.box.Transparency = alpha
        d.box.Filled = false; d.box.Visible = true
    else d.box.Visible = false end

    -- Corners
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

    -- 3D Box
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

    -- Tracer
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

    -- Name + shadow
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

    -- Distance
    d.dist.Text = string.format("[%d]", math.floor(dist))
    d.dist.Position = Vector2.new(x + width/2, y + height + 2)
    d.dist.Color = override or Color3.fromRGB(200,200,200)
    d.dist.Transparency = alpha
    d.dist.Visible = Settings.ESP.DistanceEnabled

    -- Weapon name
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

    -- Skeleton
    if Settings.ESP.SkeletonEnabled then
        U.drawSkeleton(model, d, override or Settings.ESP.SkeletonColor, Settings.ESP.SkeletonThickness)
        for _, l in pairs(d.skeleton) do l.Transparency = alpha end
    else for _, l in pairs(d.skeleton) do l.Visible = false end end

    -- Health bar (vertical left)
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

    -- Nametag
    if Settings.ESP.NametagsEnabled and hum then
        local parts = {}
        if Settings.ESP.NametagsShowHP then table.insert(parts, string.format("[%d HP]", math.floor(hum.Health))) end
        if Settings.ESP.NametagsShowDist then table.insert(parts, string.format("[%dm]", math.floor(dist))) end
        d.nametag.Text = table.concat(parts, " ")
        d.nametag.Position = Vector2.new(x + width/2, y - 44)
        d.nametag.Color = nameColor
        d.nametag.Transparency = alpha; d.nametag.Visible = true
    else d.nametag.Visible = false end

    -- Arrows
    if Settings.ESP.ArrowsEnabled then
        local hp = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
        if hp then U.drawArrow(d, hp.Position, override or Settings.ESP.ArrowsColor, Settings.ESP.ArrowsSize) end
        if d.arrow.Visible then d.arrow.Transparency = alpha end
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
M.CrosshairParts = nil
do
    local cp = {
        line1 = U.newDrawing("Line"), line2 = U.newDrawing("Line"),
        line3 = U.newDrawing("Line"), line4 = U.newDrawing("Line"),
        dot = U.newDrawing("Square"), circle = U.newDrawing("Circle"),
        o1 = U.newDrawing("Line"), o2 = U.newDrawing("Line"),
        o3 = U.newDrawing("Line"), o4 = U.newDrawing("Line"),
        sunLines = {},
    }
    for i = 1, 8 do cp.sunLines[i] = U.newDrawing("Line") end
    M.CrosshairParts = cp
end

function U.hideCrosshair()
    local cp = M.CrosshairParts
    if not cp then return end
    for k, obj in pairs(cp) do
        if type(obj) == "table" then
            for _, o in pairs(obj) do pcall(function() o.Visible = false end) end
        else pcall(function() obj.Visible = false end) end
    end
end

function U.getCrosshairColor()
    if not Settings.Crosshair.Rainbow then return Settings.Crosshair.Color end
    return Color3.fromHSV((tick() * 0.3) % 1, 1, 1)
end

function U.drawCrosshair()
    if not Settings.Crosshair.Enabled then U.hideCrosshair(); return end
    local c = Settings.Crosshair
    local cp = M.CrosshairParts
    local center = U.getFOVOrigin()
    local gap, len, thick = c.Gap, c.Length, c.Thickness
    local color = U.getCrosshairColor()

    for k, obj in pairs(cp) do
        if type(obj) == "table" then
            for _, o in pairs(obj) do o.Visible = false end
        else obj.Visible = false end
    end

    local function setLine(ln, from, to, col, th)
        ln.From = from; ln.To = to
        ln.Color = col; ln.Thickness = th
        ln.Transparency = 0; ln.Visible = true
    end

    if c.Style == "Sun" then
        local rayLen = len * 1.5
        local startR = gap + 2
        local endR = startR + rayLen
        for i = 1, 8 do
            local angle = (i - 1) * (math.pi / 4)
            local dx, dy = math.cos(angle), math.sin(angle)
            local ln = cp.sunLines[i]
            ln.From = Vector2.new(center.X + dx*startR, center.Y + dy*startR)
            ln.To = Vector2.new(center.X + dx*endR, center.Y + dy*endR)
            ln.Color = color; ln.Thickness = thick
            ln.Transparency = 0; ln.Visible = true
        end
        cp.circle.Position = center
        cp.circle.Radius = c.DotSize * 1.5
        cp.circle.Thickness = thick; cp.circle.NumSides = 32
        cp.circle.Color = color; cp.circle.Filled = false
        cp.circle.Transparency = 0; cp.circle.Visible = true
        if c.Dot then
            cp.dot.Size = Vector2.new(c.DotSize, c.DotSize)
            cp.dot.Position = Vector2.new(center.X - c.DotSize/2, center.Y - c.DotSize/2)
            cp.dot.Color = color; cp.dot.Filled = true; cp.dot.Visible = true
        end
        return
    end

    if c.Style == "Cross" then
        setLine(cp.line1, Vector2.new(center.X, center.Y-gap-len), Vector2.new(center.X, center.Y-gap), color, thick)
        setLine(cp.line2, Vector2.new(center.X, center.Y+gap), Vector2.new(center.X, center.Y+gap+len), color, thick)
        setLine(cp.line3, Vector2.new(center.X-gap-len, center.Y), Vector2.new(center.X-gap, center.Y), color, thick)
        setLine(cp.line4, Vector2.new(center.X+gap, center.Y), Vector2.new(center.X+gap+len, center.Y), color, thick)
        if c.Outline then
            local oc = c.OutlineColor
            setLine(cp.o1, Vector2.new(center.X-1, center.Y-gap-len), Vector2.new(center.X-1, center.Y-gap), oc, thick+2)
            setLine(cp.o2, Vector2.new(center.X-1, center.Y+gap), Vector2.new(center.X-1, center.Y+gap+len), oc, thick+2)
            setLine(cp.o3, Vector2.new(center.X-gap-len, center.Y-1), Vector2.new(center.X-gap, center.Y-1), oc, thick+2)
            setLine(cp.o4, Vector2.new(center.X+gap, center.Y-1), Vector2.new(center.X+gap+len, center.Y-1), oc, thick+2)
        end
    elseif c.Style == "Crosshair" then
        local sl = len * 0.6
        setLine(cp.line1, Vector2.new(center.X, center.Y-gap), Vector2.new(center.X, center.Y-gap-sl), color, thick)
        setLine(cp.line2, Vector2.new(center.X, center.Y+gap), Vector2.new(center.X, center.Y+gap+sl), color, thick)
        setLine(cp.line3, Vector2.new(center.X-gap, center.Y), Vector2.new(center.X-gap-sl, center.Y), color, thick)
        setLine(cp.line4, Vector2.new(center.X+gap, center.Y), Vector2.new(center.X+gap+sl, center.Y), color, thick)
    elseif c.Style == "Circle" then
        cp.circle.Position = center
        cp.circle.Radius = c.CircleRadius
        cp.circle.Thickness = thick; cp.circle.NumSides = 64
        cp.circle.Color = color; cp.circle.Filled = false
        cp.circle.Transparency = 0; cp.circle.Visible = true
    end

    if c.Dot then
        local s = c.DotSize
        cp.dot.Size = Vector2.new(s, s)
        cp.dot.Position = Vector2.new(center.X-s/2, center.Y-s/2)
        cp.dot.Color = color; cp.dot.Filled = true
        cp.dot.Transparency = 0; cp.dot.Visible = true
    end
end

--=====================================================================
-- AIMBOT
--=====================================================================
M.CurrentTarget = nil
M.StickyTarget = nil
M.PrevSticky = nil
M.AimArrow = U.newDrawing("Triangle")
M.AimArrow.Visible = false
M.AimArrow.Filled = true

M.FovCircle = U.newDrawing("Circle")
M.FovCircle.Thickness = 1
M.FovCircle.NumSides = 64
M.FovCircle.Filled = false
M.FovCircle.Transparency = 1
M.FovCircle.Color = Theme.Accent
M.FovCircle.Visible = false

-- Target line pool
M.TargetLinePool = {}
M.TargetLineSingle = U.newDrawing("Line")

-- Debug visuals
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
        if Camera.CameraType ~= Enum.CameraType.Custom then
            Camera.CameraType = Enum.CameraType.Custom
        end
    end)
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
    if not Settings.Aim.Enabled then
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

M.MouseLocked = false
function U.setMouseLock(state)
    if state == M.MouseLocked then return end
    M.MouseLocked = state
    pcall(function()
        UIS.MouseBehavior = state and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
    end)
end

function U.drawAimVisuals(target)
    if Settings.Aim.ShowFOV and Settings.Aim.Enabled then
        M.FovCircle.Position = U.getFOVOrigin()
        M.FovCircle.Radius = Settings.Aim.FOV
        M.FovCircle.Visible = true
    else M.FovCircle.Visible = false end

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
                M.AimArrow.PointA = origin + dir
                M.AimArrow.PointB = origin + perp
                M.AimArrow.PointC = origin - perp
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
    else
        M.LastTargetTime = 0
    end
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
    if not Settings.Aim.TargetLine then
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
M.ItemCache = {objects = {}, lastRefresh = 0, uniqueNames = {}, listChanged = false}
M.OnItemListChanged = nil

function U.newItemDrawing()
    return {square = U.newDrawing("Square"), text = U.newDrawing("Text")}
end

function U.destroyItemStruct(st)
    pcall(function() st.square:Remove() end)
    pcall(function() st.text:Remove() end)
end

function U.findAnyBasePart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") or obj:IsA("Folder") then
        for _, c in ipairs(obj:GetChildren()) do
            if c:IsA("BasePart") then return c end
        end
        for _, c in ipairs(obj:GetChildren()) do
            local bp = U.findAnyBasePart(c)
            if bp then return bp end
        end
    end
    return nil
end

function U.getObjectPosition(obj)
    if obj:IsA("BasePart") then return obj.Position end
    local bp = U.findAnyBasePart(obj)
    if bp then return bp.Position end
    local ok, piv = pcall(function() return obj:GetPivot().Position end)
    if ok then return piv end
    return nil
end

function U.refreshItemCache()
    local cache = M.ItemCache
    cache.objects = {}
    local namesSet = {}
    for _, path in ipairs(M.ITEM_ESP_PATHS) do
        local folder = U.resolveFolderPath(path)
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                table.insert(cache.objects, obj)
                namesSet[obj.Name] = true
            end
        end
    end
    local changed = false
    for name in pairs(namesSet) do
        if not cache.uniqueNames[name] then
            changed = true
            cache.uniqueNames[name] = true
            if Settings.ItemESP.SelectedItems[name] == nil then
                Settings.ItemESP.SelectedItems[name] = true
            end
        end
    end
    for name in pairs(cache.uniqueNames) do
        if not namesSet[name] then
            cache.uniqueNames[name] = nil
            Settings.ItemESP.SelectedItems[name] = nil
            changed = true
        end
    end
    cache.lastRefresh = tick()
    cache.listChanged = changed
    if changed and M.OnItemListChanged then M.OnItemListChanged() end
end

function U.drawItemESP()
    if not Settings.ItemESP.Enabled then
        for inst, st in pairs(M.ItemDrawings) do
            if typeof(inst) == "Instance" then
                st.square.Visible = false; st.text.Visible = false
            end
        end
        return
    end
    if tick() - M.ItemCache.lastRefresh > Settings.ItemESP.RefreshRate then
        U.refreshItemCache()
    end
    for inst, st in pairs(M.ItemDrawings) do
        if typeof(inst) == "Instance" and not inst.Parent then
            U.destroyItemStruct(st); M.ItemDrawings[inst] = nil
        end
    end
    local camPos = Camera.CFrame.Position
    local color = Settings.ItemESP.Color
    local maxDist = Settings.ItemESP.MaxDistance
    local textOn = Settings.ItemESP.TextEnabled
    local seen = {}
    for _, obj in ipairs(M.ItemCache.objects) do
        if obj.Parent and Settings.ItemESP.SelectedItems[obj.Name] then
            local pos = U.getObjectPosition(obj)
            if pos then
                local d = (camPos - pos).Magnitude
                if d <= maxDist then
                    local screen, on = U.worldToScreen(pos)
                    if on then
                        seen[obj] = true
                        local st = M.ItemDrawings[obj]
                        if not st then st = U.newItemDrawing(); M.ItemDrawings[obj] = st end
                        st.square.Size = Vector2.new(8, 8)
                        st.square.Position = Vector2.new(screen.X-4, screen.Y-4)
                        st.square.Color = color
                        st.square.Thickness = 1
                        st.square.Filled = false
                        st.square.Visible = true
                        if textOn then
                            st.text.Text = obj.Name
                            st.text.Position = Vector2.new(screen.X, screen.Y + 8)
                            st.text.Color = color
                            st.text.Size = 11
                            st.text.Center = true
                            st.text.Outline = true
                            st.text.Visible = true
                        else st.text.Visible = false end
                    end
                end
            end
        end
    end
    for inst, st in pairs(M.ItemDrawings) do
        if typeof(inst) == "Instance" and not seen[inst] then
            st.square.Visible = false; st.text.Visible = false
        end
    end
end

--=====================================================================
-- WORLD
--=====================================================================
M.OriginalLighting = {Ambient=nil,OutdoorAmbient=nil,Brightness=nil,FogEnd=nil,FogStart=nil,ClockTime=nil,GlobalShadows=nil,EnvironmentDiffuseScale=nil,EnvironmentSpecularScale=nil}
M.WorldBackup = false

function U.backupLighting()
    if M.WorldBackup then return end
    local o = M.OriginalLighting
    o.Ambient = Lighting.Ambient
    o.OutdoorAmbient = Lighting.OutdoorAmbient
    o.Brightness = Lighting.Brightness
    o.FogEnd = Lighting.FogEnd
    o.FogStart = Lighting.FogStart
    o.ClockTime = Lighting.ClockTime
    o.GlobalShadows = Lighting.GlobalShadows
    o.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
    o.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
    M.WorldBackup = true
end

function U.keepWorldValues()
    local w = Settings.World
    if w.FullBright then U.backupLighting()
        if Lighting.Brightness ~= 2 then pcall(function() Lighting.Brightness = 2 end) end
        if Lighting.Ambient ~= Color3.fromRGB(178,178,178) then
            pcall(function()
                Lighting.Ambient = Color3.fromRGB(178,178,178)
                Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
            end)
        end
        if Lighting.GlobalShadows then pcall(function() Lighting.GlobalShadows = false end) end
        if Lighting.FogEnd ~= math.huge then
            pcall(function() Lighting.FogEnd = math.huge; Lighting.FogStart = 0 end)
        end
    end
    if w.NoFog and Lighting.FogEnd ~= math.huge then
        pcall(function() Lighting.FogEnd = math.huge end)
    end
    if w.CustomTimeEnabled and math.abs(Lighting.ClockTime - w.CustomTime) > 0.05 then
        pcall(function() Lighting.ClockTime = w.CustomTime end)
    end
    if w.CustomAmbientEnabled and Lighting.Ambient ~= w.AmbientColor then
        pcall(function()
            Lighting.Ambient = w.AmbientColor
            Lighting.OutdoorAmbient = w.AmbientColor
        end)
    end
end

function U.applyRemoveGrass()
    if Settings.World.RemoveGrass then
        pcall(function() Workspace.Terrain.Decoration = false end)
    end
end

function U.keepCameraFOV()
    if Settings.World.CameraFOVEnabled then
        if math.abs(Camera.FieldOfView - Settings.World.CameraFOV) > 0.01 then
            pcall(function() Camera.FieldOfView = Settings.World.CameraFOV end)
        end
    end
end

--=====================================================================
-- MISC
--=====================================================================
M.InfJumpConn = nil
function U.setInfJump(state)
    if M.InfJumpConn then
        pcall(function() M.InfJumpConn:Disconnect() end)
        M.InfJumpConn = nil
    end
    if not state then return end
    M.InfJumpConn = UIS.JumpRequest:Connect(function()
        local ch = LocalPlayer.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end

M.TPWalkConn = nil
function U.setTPWalk(state)
    if M.TPWalkConn then M.TPWalkConn:Disconnect(); M.TPWalkConn = nil end
    if not state then return end
    M.TPWalkConn = RunService.Heartbeat:Connect(function()
        local ch = LocalPlayer.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + hum.MoveDirection * (Settings.Misc.TPWalkSpeed / 60)
        end
    end)
end

M.AntiFlingConn = nil
function U.setAntiFling(state)
    if M.AntiFlingConn then M.AntiFlingConn:Disconnect(); M.AntiFlingConn = nil end
    if not state then return end
    M.AntiFlingConn = RunService.Heartbeat:Connect(function()
        local ch = LocalPlayer.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local vel = hrp.AssemblyLinearVelocity
        if vel.Magnitude > 300 then hrp.AssemblyLinearVelocity = vel.Unit * 300 end
        pcall(function() hrp.AssemblyAngularVelocity = Vector3.new(0,0,0) end)
    end)
end

function U.applyWalkSpeed(v)
    local ch = LocalPlayer.Character
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end

function U.applyJumpPower(v)
    local ch = LocalPlayer.Character
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = v end
    end
end

U.addConn(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    U.applyWalkSpeed(Settings.Misc.WalkSpeed)
    U.applyJumpPower(Settings.Misc.JumpPower)
    if Settings.Misc.InfJump then U.setInfJump(true) end
    if Settings.Misc.TPWalkEnabled then U.setTPWalk(true) end
    if Settings.Misc.AntiFling then U.setAntiFling(true) end
end))

--=====================================================================
-- HEAD MOVER
--=====================================================================
M.HeadMoverConn = nil
M.OriginalHeadCFrames = {}

function U.restoreAllHeads()
    for head, cf in pairs(M.OriginalHeadCFrames) do
        if head and head.Parent then pcall(function() head.CFrame = cf end) end
    end
    M.OriginalHeadCFrames = {}
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
-- GUI (после инициализации логики)
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

--=====================================================================
-- INVENTORY PANEL
--=====================================================================
M.InvPanel = Instance.new("Frame")
M.InvPanel.Size = UDim2.new(0, 280, 0, 260)
M.InvPanel.Position = UDim2.new(0.72, 0, 0.25, 0)
M.InvPanel.BackgroundColor3 = Theme.Bg
M.InvPanel.BackgroundTransparency = Settings.InvESP.Transparency
M.InvPanel.BorderSizePixel = 0
M.InvPanel.Active = true
M.InvPanel.Draggable = true
M.InvPanel.Visible = false
M.InvPanel.Parent = ScreenGui
Instance.new("UICorner", M.InvPanel).CornerRadius = UDim.new(0, 10)
local InvStroke = Instance.new("UIStroke", M.InvPanel)
InvStroke.Color = Theme.Accent; InvStroke.Thickness = 1; InvStroke.Transparency = 0.3

local InvHeader = Instance.new("TextLabel", M.InvPanel)
InvHeader.Size = UDim2.new(1, 0, 0, 28)
InvHeader.BackgroundColor3 = Theme.Title
InvHeader.BackgroundTransparency = 0.15
InvHeader.BorderSizePixel = 0
InvHeader.Text = "  Inventory ESP — нет цели"
InvHeader.TextColor3 = Theme.Text
InvHeader.Font = Enum.Font.GothamBold
InvHeader.TextSize = 13
InvHeader.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", InvHeader).CornerRadius = UDim.new(0, 10)

local HealthBarBg = Instance.new("Frame", M.InvPanel)
HealthBarBg.Size = UDim2.new(1, -12, 0, 6)
HealthBarBg.Position = UDim2.new(0, 6, 0, 32)
HealthBarBg.BackgroundColor3 = Color3.fromRGB(50, 40, 70)
HealthBarBg.BorderSizePixel = 0
Instance.new("UICorner", HealthBarBg).CornerRadius = UDim.new(1, 0)

local HealthBarFill = Instance.new("Frame", HealthBarBg)
HealthBarFill.Size = UDim2.new(0, 0, 1, 0)
HealthBarFill.BackgroundColor3 = Theme.Good
HealthBarFill.BorderSizePixel = 0
Instance.new("UICorner", HealthBarFill).CornerRadius = UDim.new(1, 0)

local InvSub = Instance.new("TextLabel", M.InvPanel)
InvSub.Size = UDim2.new(1, -12, 0, 16)
InvSub.Position = UDim2.new(0, 6, 0, 42)
InvSub.BackgroundTransparency = 1
InvSub.TextColor3 = Theme.TextDim
InvSub.Font = Enum.Font.Gotham
InvSub.TextSize = 12
InvSub.TextXAlignment = Enum.TextXAlignment.Left

M.InvList = Instance.new("ScrollingFrame", M.InvPanel)
M.InvList.Size = UDim2.new(1, -12, 1, -70)
M.InvList.Position = UDim2.new(0, 6, 0, 62)
M.InvList.BackgroundTransparency = 1
M.InvList.BorderSizePixel = 0
M.InvList.ScrollBarThickness = 4
M.InvList.CanvasSize = UDim2.new(0, 0, 0, 0)
M.InvList.AutomaticCanvasSize = Enum.AutomaticSize.Y
local InvListLayout = Instance.new("UIListLayout", M.InvList)
InvListLayout.Padding = UDim.new(0, 4)
InvListLayout.SortOrder = Enum.SortOrder.LayoutOrder

M.InvRows = {}
function U.clearInvList()
    for _, r in ipairs(M.InvRows) do r:Destroy() end
    M.InvRows = {}
end

function U.gatherAllTools(plr)
    local seen, tools = {}, {}
    local function addItem(t)
        if t and not seen[t] then
            if t:IsA("Tool") or t:IsA("Model") or t:IsA("Accessory") then
                seen[t] = true; table.insert(tools, t)
            end
        end
    end
    local ch = plr.Character
    if ch then for _, d in ipairs(ch:GetChildren()) do addItem(d) end end
    local bp = plr:FindFirstChild("Backpack")
    if not bp then
        local ok, cls = pcall(function() return plr:FindFirstChildOfClass("Backpack") end)
        if ok then bp = cls end
    end
    if bp then for _, d in ipairs(bp:GetChildren()) do addItem(d) end end
    return tools
end

function U.refreshInvList(tools)
    local needRebuild = (#tools ~= #M.InvRows)
    if not needRebuild then
        for i, t in ipairs(tools) do
            local r = M.InvRows[i]
            if not r or r:GetAttribute("ToolName") ~= t.Name then needRebuild = true; break end
        end
    end
    if needRebuild then
        U.clearInvList()
        for i, tool in ipairs(tools) do
            local row = Instance.new("Frame", M.InvList)
            row.Size = UDim2.new(1, -4, 0, 22)
            row.BackgroundColor3 = Theme.Row
            row.BackgroundTransparency = 0.2
            row.BorderSizePixel = 0
            row:SetAttribute("ToolName", tool.Name)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
            local dot = Instance.new("TextLabel", row)
            dot.Size = UDim2.new(0, 20, 1, 0); dot.Position = UDim2.new(0, 4, 0, 0)
            dot.BackgroundTransparency = 1; dot.Text = "•"
            dot.TextColor3 = Theme.Accent; dot.Font = Enum.Font.GothamBold
            dot.TextSize = 16
            local name = Instance.new("TextLabel", row)
            name.Name = "ItemName"
            name.Size = UDim2.new(1, -30, 1, 0); name.Position = UDim2.new(0, 24, 0, 0)
            name.BackgroundTransparency = 1; name.Text = tool.Name
            name.TextColor3 = Theme.Text; name.Font = Enum.Font.Gotham
            name.TextSize = Settings.InvESP.FontSize
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.TextTruncate = Enum.TextTruncate.AtEnd
            M.InvRows[i] = row
        end
    else
        for _, r in ipairs(M.InvRows) do r.ItemName.TextSize = Settings.InvESP.FontSize end
    end
end

M.LastInvRefresh = 0
M.CurrentInvTarget = nil
function U.updateInventoryESP()
    if not Settings.InvESP.Enabled then
        if M.InvPanel.Visible then M.InvPanel.Visible = false end
        return
    end
    M.InvPanel.Visible = true
    local now = tick()
    if now - M.LastInvRefresh < Settings.InvESP.RefreshInterval then return end
    M.LastInvRefresh = now
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestD = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer or Settings.InvESP.ShowLocal then
            local _, hrp = U.getCharacterForPlayer(plr)
            if hrp then
                local sp, on = U.worldToScreen(hrp.CFrame.Position)
                if on then
                    local d = (sp - center).Magnitude
                    if d < bestD then bestD, best = d, plr end
                end
            end
        end
    end
    if not best then
        InvHeader.Text = "  Inventory ESP — нет цели"
        InvSub.Text = ""
        HealthBarFill.Size = UDim2.new(0, 0, 1, 0)
        if M.CurrentInvTarget ~= nil then M.CurrentInvTarget = nil; U.clearInvList() end
        return
    end
    M.CurrentInvTarget = best
    local _, hrp, hum = U.getCharacterForPlayer(best)
    if not hrp then return end
    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
    InvHeader.Text = "  " .. best.Name .. "  [" .. math.floor(dist) .. "m]"
    if hum and Settings.InvESP.ShowHealth then
        local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        HealthBarFill.Size = UDim2.new(hp, 0, 1, 0)
        local r = 1 - hp
        HealthBarFill.BackgroundColor3 = Color3.fromRGB(math.floor(60+r*180), math.floor(200-r*160), 100)
        InvSub.Text = string.format("HP: %d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))
    else
        HealthBarFill.Size = UDim2.new(0, 0, 1, 0); InvSub.Text = ""
    end
    if Settings.InvESP.ShowTools then
        U.refreshInvList(U.gatherAllTools(best))
    else
        if #M.InvRows > 0 then U.clearInvList() end
    end
end

--=====================================================================
-- UI HELPERS
--=====================================================================
M.UIRefs = {}
function U.registerUI(path, applyFn) M.UIRefs[path] = {apply = applyFn} end
function U.syncAllUI()
    for path, ref in pairs(M.UIRefs) do
        local v = U.getPath(path)
        if v ~= nil then pcall(function() ref.apply(v) end) end
    end
end

function U.makeRow(parent, height)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -8, 0, height or 28)
    f.BackgroundColor3 = Theme.Row
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    return f
end

function U.makeToggle(parent, text, path, cb)
    local row = U.makeRow(parent)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local state = U.getPath(path) and true or false
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0, 40, 0, 20); btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = state and Theme.Good or Theme.Panel
    btn.Text = state and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local function apply(v)
        state = v and true or false
        btn.BackgroundColor3 = state and Theme.Good or Theme.Panel
        btn.Text = state and "ON" or "OFF"
    end
    btn.MouseButton1Click:Connect(function()
        state = not state
        apply(state)
        U.setPath(path, state)
        if cb then cb(state) end
    end)
    U.registerUI(path, function(v) apply(v); if cb then cb(v) end end)
    return row
end

function U.makeSlider(parent, text, min, max, path, cb)
    local row = U.makeRow(parent, 40)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -20, 0, 18); lbl.Position = UDim2.new(0, 10, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local initial = U.getPath(path) or min
    lbl.Text = text .. ": " .. tostring(initial)
    local barBg = Instance.new("Frame", row)
    barBg.Size = UDim2.new(1, -20, 0, 8); barBg.Position = UDim2.new(0, 10, 0, 24)
    barBg.BackgroundColor3 = Theme.Panel; barBg.BorderSizePixel = 0
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new(math.clamp((initial-min)/(max-min), 0, 1), 0, 1, 0)
    barFill.BackgroundColor3 = Theme.Accent
    barFill.BorderSizePixel = 0
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
    local range = max - min
    local step
    if range <= 1 then step = 0.01
    elseif range <= 3 then step = 0.05
    elseif range <= 10 then step = 0.1
    elseif range <= 50 then step = 0.5
    elseif range <= 200 then step = 1
    elseif range <= 1000 then step = 5
    else step = 10 end
    local function fmt(v)
        if step < 1 then
            local dec = math.max(0, math.ceil(-math.log10(step)))
            return string.format("%."..dec.."f", v)
        end
        return tostring(v)
    end
    local function apply(v)
        local rel = math.clamp((v-min)/(max-min), 0, 1)
        barFill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = text .. ": " .. fmt(v)
    end
    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local v = min + (max - min) * rel
        v = math.floor((v / step) + 0.5) * step
        v = math.clamp(v, min, max)
        U.setPath(path, v)
        apply(v)
        if cb then cb(v) end
    end
    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; setFromX(input.Position.X)
        end
    end)
    U.addConn(UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(input.Position.X)
        end
    end))
    U.addConn(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    U.registerUI(path, function(v) apply(v); if cb then cb(v) end end)
    return row
end

function U.makeButton(parent, text, cb)
    local row = U.makeRow(parent)
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, -20, 1, -6); btn.Position = UDim2.new(0, 10, 0, 3)
    btn.BackgroundColor3 = Theme.Accent
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(cb)
    return row
end

function U.makeColorPicker(parent, text, path, cb)
    local row = U.makeRow(parent, 40)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -60, 0, 18); lbl.Position = UDim2.new(0, 10, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local initial = U.getPath(path) or Color3.new(1,1,1)
    local swatch = Instance.new("Frame", row)
    swatch.Size = UDim2.new(0, 40, 0, 20); swatch.Position = UDim2.new(1, -50, 0, 2)
    swatch.BackgroundColor3 = initial; swatch.BorderSizePixel = 0
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 5)
    local hueBar = Instance.new("Frame", row)
    hueBar.Size = UDim2.new(0, 200, 0, 14); hueBar.Position = UDim2.new(0, 10, 0, 22)
    hueBar.BorderSizePixel = 0
    Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0, 3)
    local grad = Instance.new("UIGradient", hueBar)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
    })
    local marker = Instance.new("Frame", hueBar)
    marker.Size = UDim2.new(0, 3, 1, 2); marker.Position = UDim2.new(0, 0, 0, -1)
    marker.BackgroundColor3 = Color3.new(1,1,1); marker.BorderSizePixel = 0
    Instance.new("UICorner", marker).CornerRadius = UDim.new(0, 2)
    local h, s, v = Color3.toHSV(initial)
    local dragging = false
    local function apply(c)
        local nh, ns, nv = Color3.toHSV(c)
        h, s, v = nh, ns, nv
        marker.Position = UDim2.new(h, -1, 0, -1)
        swatch.BackgroundColor3 = Color3.fromHSV(h, s, v)
    end
    local function applyHue(x)
        local rel = math.clamp((x - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
        h = rel
        marker.Position = UDim2.new(rel, -1, 0, -1)
        local c = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = c
        U.setPath(path, c)
        if cb then cb(c) end
    end
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; applyHue(input.Position.X)
        end
    end)
    U.addConn(UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            applyHue(input.Position.X)
        end
    end))
    U.addConn(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    marker.Position = UDim2.new(h, -1, 0, -1)
    swatch.BackgroundColor3 = Color3.fromHSV(h, s, v)
    U.registerUI(path, function(c)
        if typeof(c) == "Color3" then apply(c); if cb then cb(c) end end
    end)
    return row
end

function U.makeDropdown(parent, text, options, path, cb)
    local row = U.makeRow(parent, 32)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0, 120, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local current = U.getPath(path) or options[1]
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0, 120, 0, 22); btn.Position = UDim2.new(1, -130, 0.5, -11)
    btn.BackgroundColor3 = Theme.Accent
    btn.Text = tostring(current)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham; btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local function apply(v) current = v; btn.Text = tostring(v) end
    btn.MouseButton1Click:Connect(function()
        local idx = table.find(options, current) or 1
        idx = idx % #options + 1
        current = options[idx]
        btn.Text = tostring(current)
        U.setPath(path, current)
        if cb then cb(current) end
    end)
    U.registerUI(path, function(v) apply(v); if cb then cb(v) end end)
    return row
end

--=====================================================================
-- MAIN WINDOW
--=====================================================================
M.Main = Instance.new("Frame")
M.Main.Size = UDim2.new(0, 700, 0, 440)
M.Main.Position = UDim2.new(0.5, -350, 0.5, -220)
M.Main.BackgroundColor3 = Theme.Bg
M.Main.BorderSizePixel = 0
M.Main.Active = true
M.Main.Draggable = true
M.Main.Parent = ScreenGui
Instance.new("UICorner", M.Main).CornerRadius = UDim.new(0, 10)
local MainGrad = Instance.new("UIGradient", M.Main)
MainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Bg),
    ColorSequenceKeypoint.new(1, Theme.Bg2),
})
MainGrad.Rotation = 90
local Stroke = Instance.new("UIStroke", M.Main)
Stroke.Color = Theme.Stroke; Stroke.Thickness = 1

M.TitleBar = Instance.new("Frame", M.Main)
M.TitleBar.Size = UDim2.new(1, 0, 0, 34)
M.TitleBar.BackgroundColor3 = Theme.Title
M.TitleBar.BorderSizePixel = 0
Instance.new("UICorner", M.TitleBar).CornerRadius = UDim.new(0, 10)
local TitleLine = Instance.new("Frame", M.TitleBar)
TitleLine.Size = UDim2.new(1, 0, 0, 2)
TitleLine.Position = UDim2.new(0, 0, 1, -2)
TitleLine.BackgroundColor3 = Theme.Accent
TitleLine.BorderSizePixel = 0
local TitleGrad = Instance.new("UIGradient", TitleLine)
TitleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(1, Theme.Accent2),
})
M.Title = Instance.new("TextLabel", M.TitleBar)
M.Title.Size = UDim2.new(1, -80, 1, 0); M.Title.Position = UDim2.new(0, 14, 0, 0)
M.Title.BackgroundTransparency = 1
M.Title.Text = "MixWare.lol  •  v2.6"
M.Title.TextColor3 = Theme.Text
M.Title.Font = Enum.Font.GothamBold
M.Title.TextSize = 13
M.Title.TextXAlignment = Enum.TextXAlignment.Left

M.MinBtn = Instance.new("TextButton", M.TitleBar)
M.MinBtn.Size = UDim2.new(0, 24, 0, 24); M.MinBtn.Position = UDim2.new(1, -60, 0, 5)
M.MinBtn.BackgroundColor3 = Theme.Panel
M.MinBtn.Text = "—"; M.MinBtn.TextColor3 = Theme.TextM.MinBtn.Font = Enum.Font.GothamBold; M.MinBtn.TextSize = 12
M.MinBtn.BorderSizePixel = 0
Instance.new("UICorner", M.MinBtn).CornerRadius = UDim.new(0, 5)

M.CloseBtn = Instance.new("TextButton", M.TitleBar)
M.CloseBtn.Size = UDim2.new(0, 24, 0, 24); M.CloseBtn.Position = UDim2.new(1, -32, 0, 5)
M.CloseBtn.BackgroundColor3 = Theme.Bad
M.CloseBtn.Text = "X"; M.CloseBtn.TextColor3 = Theme.Text
M.CloseBtn.Font = Enum.Font.GothamBold; M.CloseBtn.TextSize = 12
M.CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", M.CloseBtn).CornerRadius = UDim.new(0, 5)

M.SearchBar = Instance.new("TextBox", M.Main)
M.SearchBar.Size = UDim2.new(1, -20, 0, 24)
M.SearchBar.Position = UDim2.new(0, 10, 0, 40)
M.SearchBar.BackgroundColor3 = Theme.Panel
M.SearchBar.TextColor3 = Theme.Text
M.SearchBar.PlaceholderText = "Search..."
M.SearchBar.Text = ""
M.SearchBar.Font = Enum.Font.Gotham
M.SearchBar.TextSize = 12
M.SearchBar.BorderSizePixel = 0
M.SearchBar.ClearTextOnFocus = false
Instance.new("UICorner", M.SearchBar).CornerRadius = UDim.new(0, 6)

M.Sidebar = Instance.new("Frame", M.Main)
M.Sidebar.Size = UDim2.new(0, 130, 1, -110)
M.Sidebar.Position = UDim2.new(0, 10, 0, 72)
M.Sidebar.BackgroundTransparency = 1

M.ContentHolder = Instance.new("Frame", M.Main)
M.ContentHolder.Size = UDim2.new(1, -160, 1, -110)
M.ContentHolder.Position = UDim2.new(0, 150, 0, 72)
M.ContentHolder.BackgroundTransparency = 1

M.TabButtons = {}
M.TabPages = {}

function U.selectTab(name)
    for k, b in pairs(M.TabButtons) do
        if k == name then
            b.BackgroundColor3 = Theme.Accent
            b.TextColor3 = Color3.new(1,1,1)
        else
            b.BackgroundColor3 = Theme.Panel
            b.TextColor3 = Theme.TextDim
        end
    end
    for k, p in pairs(M.TabPages) do p.Visible = (k == name) end
end

local SideY = 0
local function catHeader(text)
    local h = Instance.new("TextLabel", M.Sidebar)
    h.Size = UDim2.new(1, -8, 0, 20)
    h.Position = UDim2.new(0, 4, 0, SideY)
    h.BackgroundTransparency = 1
    h.Text = text
    h.TextColor3 = Theme.Accent2
    h.Font = Enum.Font.GothamBold
    h.TextSize = 11
    h.TextXAlignment = Enum.TextXAlignment.Left
    SideY = SideY + 22
end

local function subBtn(name)
    local btn = Instance.new("TextButton", M.Sidebar)
    btn.Position = UDim2.new(0, 4, 0, SideY)
    btn.Size = UDim2.new(1, -8, 0, 26)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    SideY = SideY + 28

    local page = Instance.new("ScrollingFrame", M.ContentHolder)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    M.TabButtons[name] = btn
    M.TabPages[name] = page
    btn.MouseButton1Click:Connect(function() U.selectTab(name) end)
    return page
end

catHeader("COMBAT")
local AimPage = subBtn("AimBot")
local TrgPage = subBtn("Trigger")
SideY = SideY + 8
catHeader("VISUALS")
local EnemiesPage = subBtn("Enemies")
local ItemsPage = subBtn("Items")
local InventoryPage = subBtn("Inventory")
local WorldPage = subBtn("World")
local CrosshairPage = subBtn("Crosshair")
SideY = SideY + 8
catHeader("MISC")
local MiscPage = subBtn("Misc")
local ConfigPage = subBtn("Config")
local MenuPage = subBtn("Menu")
U.selectTab("AimBot")

--=====================================================================
-- AIM PAGE
--=====================================================================
U.makeToggle(AimPage, "AimBot Enabled", "Aim.Enabled")
U.makeSlider(AimPage, "FOV", 10, 500, "Aim.FOV")
U.makeToggle(AimPage, "Show FOV", "Aim.ShowFOV")
U.makeToggle(AimPage, "Instant Snap", "Aim.Instant")
U.makeSlider(AimPage, "Smoothness", 0.01, 1, "Aim.Smoothness")
U.makeDropdown(AimPage, "Smooth Curve", {"Linear","EaseOut","Sine"}, "Aim.SmoothCurve")
U.makeDropdown(AimPage, "Bone", {"Head","Torso","Nearest"}, "Aim.Bone")
U.makeToggle(AimPage, "Wall Check", "Aim.WallCheck")
U.makeToggle(AimPage, "Team Check", "Aim.TeamCheck")
U.makeToggle(AimPage, "Aim At Hit Point", "Aim.AimAtHitPoint")
U.makeToggle(AimPage, "Prediction", "Aim.Prediction")
U.makeSlider(AimPage, "Prediction Factor", 0.5, 3, "Aim.PredictionFactor")
U.makeSlider(AimPage, "Sticky Multiplier", 1, 4, "Aim.StickyMultiplier")
U.makeToggle(AimPage, "Ground Only", "Aim.GroundOnly")
U.makeToggle(AimPage, "Debug Visuals", "Aim.DebugVisuals")

U.makeToggle(AimPage, "Target Line", "Aim.TargetLine")
U.makeColorPicker(AimPage, "Target Line Color", "Aim.TargetLineColor")
U.makeSlider(AimPage, "Target Line Thickness", 1, 5, "Aim.TargetLineThickness")
U.makeSlider(AimPage, "Target Line Transparency", 0, 1, "Aim.TargetLineTransparency")
U.makeDropdown(AimPage, "Target Line Style", {"Solid","Dashed"}, "Aim.TargetLineStyle")
U.makeSlider(AimPage, "Dash Count", 2, 20, "Aim.TargetLineDashCount")
U.makeToggle(AimPage, "Target Line Only When Aiming", "Aim.TargetLineOnlyAiming")

U.makeToggle(AimPage, "Head Mover (silent)", "Aim.HeadMover", function(v)
    if v then U.startHeadMover() else U.stopHeadMover() end
end)
U.makeSlider(AimPage, "Head Mover Distance", 5, 200, "Aim.HeadMoverDistance")
U.makeSlider(AimPage, "Head Mover Speed", 0.05, 1, "Aim.HeadMoverSpeed")
U.makeToggle(AimPage, "Head Mover Only When Aiming", "Aim.HeadMoverOnlyAimKey")

do
    local keyRow = U.makeRow(AimPage)
    local keyLbl = Instance.new("TextLabel", keyRow)
    keyLbl.Size = UDim2.new(1, -60, 1, 0); keyLbl.Position = UDim2.new(0, 10, 0, 0)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Text = "Aim Key: " .. Settings.Aim.KeyName
    keyLbl.TextColor3 = Theme.Text
    keyLbl.Font = Enum.Font.Gotham; keyLbl.TextSize = 13
    keyLbl.TextXAlignment = Enum.TextXAlignment.Left
    local keyBtn = Instance.new("TextButton", keyRow)
    keyBtn.Size = UDim2.new(0, 60, 0, 20); keyBtn.Position = UDim2.new(1, -70, 0.5, -10)
    keyBtn.BackgroundColor3 = Theme.Panel
    keyBtn.Text = "Set"; keyBtn.TextColor3 = Theme.Text
    keyBtn.Font = Enum.Font.Gotham; keyBtn.TextSize = 11
    keyBtn.BorderSizePixel = 0
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 5)
    keyBtn.MouseButton1Click:Connect(function()
        keyLbl.Text = "Нажми клавишу..."
        local conn
        conn = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Settings.Aim.KeyName = input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                Settings.Aim.KeyName = "MouseButton1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                Settings.Aim.KeyName = "MouseButton2"
            end
            keyLbl.Text = "Aim Key: " .. Settings.Aim.KeyName
            conn:Disconnect()
            U.notify("Aim Key set to " .. Settings.Aim.KeyName)
        end)
    end)
end

--=====================================================================
-- TRIGGER PAGE
--=====================================================================
U.makeToggle(TrgPage, "TriggerBot Enabled", "Trigger.Enabled")
U.makeSlider(TrgPage, "Delay", 0.01, 1, "Trigger.Delay")
U.makeToggle(TrgPage, "Team Check", "Trigger.TeamCheck")
U.makeToggle(TrgPage, "Wall Check", "Trigger.WallCheck")
U.makeToggle(TrgPage, "Only When Aim Key Down", "Trigger.OnlyAimKey")

--=====================================================================
-- ENEMIES PAGE
--=====================================================================
U.makeToggle(EnemiesPage, "ESP Master Toggle", "ESP.Enabled", function(v)
    if not v then for _, d in pairs(M.ESPData) do U.hideAllESP(d) end end
end)
U.makeToggle(EnemiesPage, "Chams (Highlight)", "ESP.ChamsEnabled")
U.makeColorPicker(EnemiesPage, "Chams Color", "ESP.ChamsColor")
U.makeColorPicker(EnemiesPage, "Chams Target Color", "ESP.ChamsTargetColor")
U.makeSlider(EnemiesPage, "Chams Transparency", 0, 1, "ESP.ChamsTransp")
U.makeToggle(EnemiesPage, "Box ESP", "ESP.BoxEnabled")
U.makeColorPicker(EnemiesPage, "Box Color", "ESP.BoxColor")
U.makeSlider(EnemiesPage, "Box Thickness", 1, 5, "ESP.BoxThickness")
U.makeToggle(EnemiesPage, "Corner ESP", "ESP.CornerEnabled")
U.makeColorPicker(EnemiesPage, "Corner Color", "ESP.CornerColor")
U.makeSlider(EnemiesPage, "Corner Length", 4, 40, "ESP.CornerLength")
U.makeSlider(EnemiesPage, "Corner Thickness", 1, 4, "ESP.CornerThickness")
U.makeToggle(EnemiesPage, "3D Box ESP", "ESP.Box3DEnabled")
U.makeColorPicker(EnemiesPage, "3D Box Color", "ESP.Box3DColor")
U.makeToggle(EnemiesPage, "Tracers", "ESP.TracerEnabled")
U.makeColorPicker(EnemiesPage, "Tracer Color", "ESP.TracerColor")
U.makeDropdown(EnemiesPage, "Tracer Origin", {"Top","Center","Bottom"}, "ESP.TracerOrigin")
U.makeToggle(EnemiesPage, "Show Name", "ESP.NameEnabled")
U.makeToggle(EnemiesPage, "Name Shadow", "ESP.NameShadow")
U.makeToggle(EnemiesPage, "Show Distance", "ESP.DistanceEnabled")
U.makeSlider(EnemiesPage, "Max Distance", 50, 3000, "ESP.MaxDistance")
U.makeToggle(EnemiesPage, "Visible Check", "ESP.VisibleCheck")
U.makeColorPicker(EnemiesPage, "Visible Color", "ESP.VisibleColor")
U.makeToggle(EnemiesPage, "Behind-Wall Pulse", "ESP.PulseEnabled")
U.makeSlider(EnemiesPage, "Pulse Speed", 0.5, 3, "ESP.PulseSpeed")
U.makeSlider(EnemiesPage, "Pulse Min Alpha", 0.1, 0.9, "ESP.PulseMin")
U.makeSlider(EnemiesPage, "Pulse Max Alpha", 0.1, 1, "ESP.PulseMax")
U.makeToggle(EnemiesPage, "Skeleton ESP", "ESP.SkeletonEnabled")
U.makeColorPicker(EnemiesPage, "Skeleton Color", "ESP.SkeletonColor")
U.makeSlider(EnemiesPage, "Skeleton Thickness", 1, 4, "ESP.SkeletonThickness")
U.makeToggle(EnemiesPage, "Health Bar", "ESP.HealthBarEnabled")
U.makeSlider(EnemiesPage, "Health Bar Width", 2, 12, "ESP.HealthBarWidth")
U.makeSlider(EnemiesPage, "Health Bar Offset", 2, 20, "ESP.HealthBarOffset")
U.makeToggle(EnemiesPage, "Custom Nametags", "ESP.NametagsEnabled")
U.makeToggle(EnemiesPage, "Nametag HP", "ESP.NametagsShowHP")
U.makeToggle(EnemiesPage, "Nametag Distance", "ESP.NametagsShowDist")
U.makeToggle(EnemiesPage, "Off-screen Arrows", "ESP.ArrowsEnabled")
U.makeColorPicker(EnemiesPage, "Arrows Color", "ESP.ArrowsColor")
U.makeSlider(EnemiesPage, "Arrows Size", 8, 24, "ESP.ArrowsSize")
U.makeToggle(EnemiesPage, "Weapon Name", "ESP.WeaponNameEnabled")
U.makeColorPicker(EnemiesPage, "Weapon Name Color", "ESP.WeaponNameColor")
U.makeSlider(EnemiesPage, "Weapon Name Size", 8, 20, "ESP.WeaponNameSize")
U.makeToggle(EnemiesPage, "Distance Fade", "ESP.DistanceFade")
U.makeSlider(EnemiesPage, "Fade Start %", 0.1, 1, "ESP.DistanceFadeStart")

--=====================================================================
-- CROSSHAIR PAGE
--=====================================================================
U.makeToggle(CrosshairPage, "Crosshair Enabled", "Crosshair.Enabled")
U.makeDropdown(CrosshairPage, "Style", {"Cross","Crosshair","Circle","Dot","Sun"}, "Crosshair.Style")
U.makeColorPicker(CrosshairPage, "Color", "Crosshair.Color")
U.makeToggle(CrosshairPage, "Rainbow", "Crosshair.Rainbow")
U.makeColorPicker(CrosshairPage, "Outline Color", "Crosshair.OutlineColor")
U.makeToggle(CrosshairPage, "Outline", "Crosshair.Outline")
U.makeSlider(CrosshairPage, "Gap", 0, 20, "Crosshair.Gap")
U.makeSlider(CrosshairPage, "Length", 2, 30, "Crosshair.Length")
U.makeSlider(CrosshairPage, "Thickness", 1, 5, "Crosshair.Thickness")
U.makeSlider(CrosshairPage, "Circle Radius", 4, 40, "Crosshair.CircleRadius")
U.makeToggle(CrosshairPage, "Dot", "Crosshair.Dot")
U.makeSlider(CrosshairPage, "Dot Size", 1, 8, "Crosshair.DotSize")

--=====================================================================
-- ITEMS PAGE (with popup selector)
--=====================================================================
U.makeToggle(ItemsPage, "Item ESP", "ItemESP.Enabled")
U.makeColorPicker(ItemsPage, "Item Color", "ItemESP.Color")
U.makeSlider(ItemsPage, "Max Distance", 50, 2000, "ItemESP.MaxDistance")
U.makeToggle(ItemsPage, "Show Text", "ItemESP.TextEnabled")
U.makeSlider(ItemsPage, "Refresh Rate", 0.05, 1, "ItemESP.RefreshRate")

M.ItemSelectorBtn = Instance.new("TextButton")
do
    local row = U.makeRow(ItemsPage, 32)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0, 130, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Selected Items:"
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    M.ItemSelectorBtn.Size = UDim2.new(0, 120, 0, 22)
    M.ItemSelectorBtn.Position = UDim2.new(1, -130, 0.5, -11)
    M.ItemSelectorBtn.BackgroundColor3 = Theme.Accent
    M.ItemSelectorBtn.Text = "0 selected"
    M.ItemSelectorBtn.TextColor3 = Color3.new(1,1,1)
    M.ItemSelectorBtn.Font = Enum.Font.Gotham; M.ItemSelectorBtn.TextSize = 12
    M.ItemSelectorBtn.BorderSizePixel = 0
    M.ItemSelectorBtn.Parent = row
    Instance.new("UICorner", M.ItemSelectorBtn).CornerRadius = UDim.new(0, 5)
end

M.ItemPopup = Instance.new("Frame", ScreenGui)
M.ItemPopup.Size = UDim2.new(0, 300, 0, 240)
M.ItemPopup.Position = UDim2.new(0.5, -150, 0.5, -120)
M.ItemPopup.BackgroundColor3 = Theme.Bg
M.ItemPopup.BorderSizePixel = 0
M.ItemPopup.Visible = false
M.ItemPopup.ZIndex = 10
Instance.new("UICorner", M.ItemPopup).CornerRadius = UDim.new(0, 10)
local popupStroke = Instance.new("UIStroke", M.ItemPopup)
popupStroke.Color = Theme.Accent; popupStroke.Thickness = 1

local popupTitle = Instance.new("TextLabel", M.ItemPopup)
popupTitle.Size = UDim2.new(1, -60, 0, 26); popupTitle.Position = UDim2.new(0, 10, 0, 4)
popupTitle.BackgroundTransparency = 1
popupTitle.Text = "Select Items to Show:"
popupTitle.TextColor3 = Theme.Text
popupTitle.Font = Enum.Font.GothamBold; popupTitle.TextSize = 12
popupTitle.TextXAlignment = Enum.TextXAlignment.Left

local popupClose = Instance.new("TextButton", M.ItemPopup)
popupClose.Size = UDim2.new(0, 24, 0, 24); popupClose.Position = UDim2.new(1, -30, 0, 4)
popupClose.BackgroundColor3 = Theme.Bad
popupClose.Text = "X"; popupClose.TextColor3 = Theme.Text
popupClose.Font = Enum.Font.GothamBold; popupClose.TextSize = 12
popupClose.BorderSizePixel = 0
Instance.new("UICorner", popupClose).CornerRadius = UDim.new(0, 5)

local popupScroll = Instance.new("ScrollingFrame", M.ItemPopup)
popupScroll.Size = UDim2.new(1, -20, 1, -70); popupScroll.Position = UDim2.new(0, 10, 0, 34)
popupScroll.BackgroundTransparency = 1
popupScroll.BorderSizePixel = 0
popupScroll.ScrollBarThickness = 4
popupScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
popupScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local popupLayout = Instance.new("UIListLayout", popupScroll)
popupLayout.Padding = UDim.new(0, 4)
popupLayout.SortOrder = Enum.SortOrder.LayoutOrder

M.PopupButtons = {}
function U.rebuildPopupList()
    for _, b in ipairs(M.PopupButtons) do b:Destroy() end
    M.PopupButtons = {}
    local names = {}
    for n in pairs(M.ItemCache.uniqueNames) do table.insert(names, n) end
    table.sort(names)
    for _, name in ipairs(names) do
        local row = Instance.new("Frame", popupScroll)
        row.Size = UDim2.new(1, -4, 0, 22)
        row.BackgroundColor3 = Theme.Row
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
        local cb = Instance.new("TextButton", row)
        cb.Size = UDim2.new(0, 18, 0, 18); cb.Position = UDim2.new(0, 4, 0.5, -9)
        local sel = Settings.ItemESP.SelectedItems[name] == true
        cb.BackgroundColor3 = sel and Theme.Good or Theme.Panel
        cb.Text = sel and "✓" or ""
        cb.TextColor3 = Color3.new(1,1,1)
        cb.Font = Enum.Font.GothamBold; cb.TextSize = 13
        cb.BorderSizePixel = 0
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)
        local nl = Instance.new("TextLabel", row)
        nl.Size = UDim2.new(1, -30, 1, 0); nl.Position = UDim2.new(0, 26, 0, 0)
        nl.BackgroundTransparency = 1
        nl.Text = name; nl.TextColor3 = Theme.Text
        nl.Font = Enum.Font.Gotham; nl.TextSize = 12
        nl.TextXAlignment = Enum.TextXAlignment.Left
        cb.MouseButton1Click:Connect(function()
            local s = Settings.ItemESP.SelectedItems[name] == true
            Settings.ItemESP.SelectedItems[name] = not s
            cb.BackgroundColor3 = (not s) and Theme.Good or Theme.Panel
            cb.Text = (not s) and "✓" or ""
            local c = 0
            for _, v in pairs(Settings.ItemESP.SelectedItems) do if v then c = c + 1 end end
            M.ItemSelectorBtn.Text = c .. " selected"
        end)
        table.insert(M.PopupButtons, row)
    end
    local c = 0
    for _, v in pairs(Settings.ItemESP.SelectedItems) do if v then c = c + 1 end end
    M.ItemSelectorBtn.Text = c .. " selected"
end

M.ItemSelectorBtn.MouseButton1Click:Connect(function()
    M.ItemPopup.Visible = not M.ItemPopup.Visible
    if M.ItemPopup.Visible then U.rebuildPopupList() end
end)
popupClose.MouseButton1Click:Connect(function() M.ItemPopup.Visible = false end)
M.OnItemListChanged = function()
    if M.ItemPopup.Visible then U.rebuildPopupList() end
end

--=====================================================================
-- INVENTORY PAGE
--=====================================================================
U.makeToggle(InventoryPage, "Inventory ESP", "InvESP.Enabled", function(v)
    M.InvPanel.Visible = v
end)
U.makeSlider(InventoryPage, "Transparency", 0, 1, "InvESP.Transparency", function(v)
    M.InvPanel.BackgroundTransparency = v
end)
U.makeSlider(InventoryPage, "Font Size", 10, 22, "InvESP.FontSize", function(v)
    for _, r in ipairs(M.InvRows) do r.ItemName.TextSize = v end
end)
U.makeSlider(InventoryPage, "Refresh Interval", 0.05, 2, "InvESP.RefreshInterval")
U.makeToggle(InventoryPage, "Show Local Player", "InvESP.ShowLocal")
U.makeToggle(InventoryPage, "Show Health Bar", "InvESP.ShowHealth")
U.makeToggle(InventoryPage, "Show Tools", "InvESP.ShowTools")
U.makeButton(InventoryPage, "Reset Panel Position", function()
    M.InvPanel.Position = UDim2.new(0.72, 0, 0.25, 0)
end)

--=====================================================================
-- WORLD PAGE
--=====================================================================
U.makeToggle(WorldPage, "World ESP", "WorldESP.Enabled")
U.makeColorPicker(WorldPage, "World Color", "WorldESP.Color")
U.makeSlider(WorldPage, "Max Distance", 50, 2000, "WorldESP.MaxDistance")
U.makeToggle(WorldPage, "Show Text", "WorldESP.TextEnabled")
U.makeToggle(WorldPage, "FullBright", "World.FullBright")
U.makeToggle(WorldPage, "No Fog", "World.NoFog")
U.makeToggle(WorldPage, "Custom Time of Day", "World.CustomTimeEnabled")
U.makeSlider(WorldPage, "Time", 0, 24, "World.CustomTime")
U.makeToggle(WorldPage, "Custom Ambient", "World.CustomAmbientEnabled")
U.makeColorPicker(WorldPage, "Ambient Color", "World.AmbientColor")
U.makeToggle(WorldPage, "Disable Sun Rays", "World.DisableSunRays")
U.makeToggle(WorldPage, "Disable Atmosphere", "World.DisableAtmosphere")
U.makeToggle(WorldPage, "Remove Grass", "World.RemoveGrass", function() U.applyRemoveGrass() end)
U.makeToggle(WorldPage, "Custom Camera FOV", "World.CameraFOVEnabled")
U.makeSlider(WorldPage, "Camera FOV", 30, 120, "World.CameraFOV")

--=====================================================================
-- MISC PAGE
--=====================================================================
U.makeToggle(MiscPage, "TPWalk", "Misc.TPWalkEnabled", function(v) U.setTPWalk(v) end)
U.makeSlider(MiscPage, "TPWalk Speed", 1, 200, "Misc.TPWalkSpeed")
U.makeToggle(MiscPage, "Infinite Jump", "Misc.InfJump", function(v) U.setInfJump(v) end)
U.makeSlider(MiscPage, "WalkSpeed", 1, 500, "Misc.WalkSpeed", function(v) U.applyWalkSpeed(v) end)
U.makeSlider(MiscPage, "JumpPower", 1, 500, "Misc.JumpPower", function(v) U.applyJumpPower(v) end)
U.makeToggle(MiscPage, "Anti-Fling", "Misc.AntiFling", function(v) U.setAntiFling(v) end)
U.makeToggle(MiscPage, "Kill Sound", "Sound.KillSound")
U.makeToggle(MiscPage, "Target Lock Sound", "Sound.TargetLockSound")
U.makeButton(MiscPage, "Load Infinite Yield source", function()
    pcall(function()
        local src = game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
        getgenv().IY_Source = src
    end)
    U.notify("IY source загружен")
end)

--=====================================================================
-- CONFIG PAGE
--=====================================================================
M.HasFileAPI = writefile ~= nil and readfile ~= nil
M.ConfigFolder = "MixWare_Configs"
M.LastFile = M.ConfigFolder .. "/_last.txt"
M.MemStore = {}
M.MemLast = nil

function U.ensureFolder()
    if not M.HasFileAPI or not isfolder then return end
    pcall(function()
        if not isfolder(M.ConfigFolder) then
            if makefolder then makefolder(M.ConfigFolder) end
        end
    end)
end

function U.listConfigs()
    U.ensureFolder()
    if M.HasFileAPI and listfiles then
        local ok, files = pcall(function() return listfiles(M.ConfigFolder) end)
        if ok and files then
            local names = {}
            for _, f in ipairs(files) do
                local n = f:match("([^/\\]+)%.json$")
                if n then table.insert(names, n) end
            end
            return names
        end
    end
    local names = {}
    for k in pairs(M.MemStore) do table.insert(names, k) end
    return names
end

function U.saveLastConfigName(name)
    if M.HasFileAPI and writefile then
        U.ensureFolder()
        pcall(function() writefile(M.LastFile, name) end)
    else
        M.MemLast = name
    end
    M.ActiveConfigName = name
end

function U.getLastConfigName()
    if M.HasFileAPI and isfile and isfile(M.LastFile) and readfile then
        local ok, res = pcall(function() return readfile(M.LastFile) end)
        if ok and res and res ~= "" then return res end
    end
    return M.MemLast
end

function U.saveConfig(name)
    if not name or name == "" then return false end
    local data = HttpService:JSONEncode(U.serializeSettings(Settings))
    if M.HasFileAPI and writefile then
        U.ensureFolder()
        return pcall(function()
            writefile(M.ConfigFolder .. "/" .. name .. ".json", data)
        end)
    else
        M.MemStore[name] = data
        return true
    end
end

function U.loadConfig(name, silent)
    if not name or name == "" then return false end
    local data
    if M.HasFileAPI and readfile then
        U.ensureFolder()
        local ok, res = pcall(function()
            return readfile(M.ConfigFolder .. "/" .. name .. ".json")
        end)
        if ok and res then data = res end
    else
        data = M.MemStore[name]
    end
    if not data then return false end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(data) end)
    if not ok or type(decoded) ~= "table" then return false end
    U.deserializeSettings(Settings, decoded)
    M.ActiveConfigName = name
    U.syncAllUI()
    if Settings.Misc.AntiFling then U.setAntiFling(true) else U.setAntiFling(false) end
    if Settings.Misc.TPWalkEnabled then U.setTPWalk(true) else U.setTPWalk(false) end
    if Settings.Misc.InfJump then U.setInfJump(true) else U.setInfJump(false) end
    if Settings.Aim.HeadMover then U.startHeadMover() else U.stopHeadMover() end
    if not silent then U.notify("Loaded config: " .. name, Theme.Good) end
    return true
end

function U.deleteConfig(name)
    if not name or name == "" then return false end
    if M.HasFileAPI and delfile then
        return pcall(function() delfile(M.ConfigFolder .. "/" .. name .. ".json") end)
    else
        M.MemStore[name] = nil
        return true
    end
end

M.ConfigRows = {}
function U.rebuildConfigList()
    for _, r in ipairs(M.ConfigRows) do r:Destroy() end
    M.ConfigRows = {}
    local names = U.listConfigs()
    table.sort(names)
    for _, name in ipairs(names) do
        local row = Instance.new("Frame", M.ConfigList)
        row.Size = UDim2.new(1, -4, 0, 22)
        row.BackgroundColor3 = Theme.Row
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
        local lbl = Instance.new("TextButton", row)
        lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.new(0, 6, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name; lbl.TextColor3 = Theme.Text
        lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.MouseButton1Click:Connect(function() M.CfgNameBox.Text = name end)
        local loadBtn = Instance.new("TextButton", row)
        loadBtn.Size = UDim2.new(0, 24, 0, 18); loadBtn.Position = UDim2.new(1, -56, 0.5, -9)
        loadBtn.BackgroundColor3 = Theme.Good
        loadBtn.Text = "L"; loadBtn.TextColor3 = Color3.new(1,1,1)
        loadBtn.Font = Enum.Font.GothamBold; loadBtn.TextSize = 11
        loadBtn.BorderSizePixel = 0
        Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 4)
        loadBtn.MouseButton1Click:Connect(function()
            U.loadConfig(name); U.saveLastConfigName(name)
        end)
        local delBtn = Instance.new("TextButton", row)
        delBtn.Size = UDim2.new(0, 24, 0, 18); delBtn.Position = UDim2.new(1, -28, 0.5, -9)
        delBtn.BackgroundColor3 = Theme.Bad
        delBtn.Text = "X"; delBtn.TextColor3 = Color3.new(1,1,1)
        delBtn.Font = Enum.Font.GothamBold; delBtn.TextSize = 11
        delBtn.BorderSizePixel = 0
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
        delBtn.MouseButton1Click:Connect(function()
            U.deleteConfig(name); U.rebuildConfigList()
        end)
        table.insert(M.ConfigRows, row)
    end
end

do
    local cfgNameRow = U.makeRow(ConfigPage, 32)
    M.CfgNameBox = Instance.new("TextBox", cfgNameRow)
    M.CfgNameBox.Size = UDim2.new(1, -20, 1, -6); M.CfgNameBox.Position = UDim2.new(0, 10, 0, 3)
    M.CfgNameBox.BackgroundColor3 = Theme.Panel
    M.CfgNameBox.TextColor3 = Theme.Text
    M.CfgNameBox.PlaceholderText = "Имя конфига..."
    M.CfgNameBox.Text = ""
    M.CfgNameBox.Font = Enum.Font.Gotham
    M.CfgNameBox.TextSize = 13
    M.CfgNameBox.BorderSizePixel = 0
    Instance.new("UICorner", M.CfgNameBox).CornerRadius = UDim.new(0, 5)

    local cfgListRow = U.makeRow(ConfigPage, 140)
    M.ConfigList = Instance.new("ScrollingFrame", cfgListRow)
    M.ConfigList.Size = UDim2.new(1, -10, 1, -6); M.ConfigList.Position = UDim2.new(0, 5, 0, 3)
    M.ConfigList.BackgroundTransparency = 1
    M.ConfigList.BorderSizePixel = 0
    M.ConfigList.ScrollBarThickness = 4
    M.ConfigList.CanvasSize = UDim2.new(0, 0, 0, 0)
    M.ConfigList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local cl = Instance.new("UIListLayout", M.ConfigList)
    cl.Padding = UDim.new(0, 3)
    cl.SortOrder = Enum.SortOrder.LayoutOrder
end

U.makeButton(ConfigPage, "Save Current Config", function()
    local n = M.CfgNameBox.Text
    if n and n ~= "" then
        U.saveConfig(n); U.saveLastConfigName(n); U.rebuildConfigList()
        U.notify("Saved config: " .. n, Theme.Good)
    end
end)
U.makeButton(ConfigPage, "Load Config", function()
    local n = M.CfgNameBox.Text
    if n and n ~= "" then U.loadConfig(n); U.saveLastConfigName(n) end
end)
U.makeButton(ConfigPage, "Refresh List", function() U.rebuildConfigList() end)
U.makeButton(ConfigPage, "Clear Last Config", function()
    if M.HasFileAPI and delfile then pcall(function() delfile(M.LastFile) end)
    else M.MemLast = nil end
    M.ActiveConfigName = "none"
    U.notify("Last config cleared", Theme.Bad)
end)

U.rebuildConfigList()

--=====================================================================
-- MENU PAGE
--=====================================================================
U.makeToggle(MenuPage, "Watermark", "UI.Watermark")
U.makeToggle(MenuPage, "Notifications", "UI.Notifications")

do
    local themeRow = U.makeRow(MenuPage, 32)
    local themeLbl = Instance.new("TextLabel", themeRow)
    themeLbl.Size = UDim2.new(0, 120, 1, 0); themeLbl.Position = UDim2.new(0, 10, 0, 0)
    themeLbl.BackgroundTransparency = 1
    themeLbl.Text = "Theme:"
    themeLbl.TextColor3 = Theme.Text
    themeLbl.Font = Enum.Font.Gotham; themeLbl.TextSize = 13
    themeLbl.TextXAlignment = Enum.TextXAlignment.Left
    M.ThemeBtn = Instance.new("TextButton", themeRow)
    M.ThemeBtn.Size = UDim2.new(0, 120, 0, 22); M.ThemeBtn.Position = UDim2.new(1, -130, 0.5, -11)
    M.ThemeBtn.BackgroundColor3 = Theme.Accent
    M.ThemeBtn.Text = Settings.UI.Theme
    M.ThemeBtn.TextColor3 = Color3.new(1,1,1)
    M.ThemeBtn.Font = Enum.Font.Gotham; M.ThemeBtn.TextSize = 12
    M.ThemeBtn.BorderSizePixel = 0
    Instance.new("UICorner", M.ThemeBtn).CornerRadius = UDim.new(0, 5)

    local scaleRow = U.makeRow(MenuPage, 32)
    local scaleLbl = Instance.new("TextLabel", scaleRow)
    scaleLbl.Size = UDim2.new(0, 120, 1, 0); scaleLbl.Position = UDim2.new(0, 10, 0, 0)
    scaleLbl.BackgroundTransparency = 1
    scaleLbl.Text = "UI Scale:"
    scaleLbl.TextColor3 = Theme.Text
    scaleLbl.Font = Enum.Font.Gotham; scaleLbl.TextSize = 13
    scaleLbl.TextXAlignment = Enum.TextXAlignment.Left
    M.ScaleBtn = Instance.new("TextButton", scaleRow)
    M.ScaleBtn.Size = UDim2.new(0, 120, 0, 22); M.ScaleBtn.Position = UDim2.new(1, -130, 0.5, -11)
    M.ScaleBtn.BackgroundColor3 = Theme.Accent
    M.ScaleBtn.Text = Settings.UI.Scale
    M.ScaleBtn.TextColor3 = Color3.new(1,1,1)
    M.ScaleBtn.Font = Enum.Font.Gotham; M.ScaleBtn.TextSize = 12
    M.ScaleBtn.BorderSizePixel = 0
    Instance.new("UICorner", M.ScaleBtn).CornerRadius = UDim.new(0, 5)
end

local themeOrder = {"Purple","Dark","Blue","Red","Pink"}
local scaleOrder = {"Small","Medium","Large"}
local scaleValues = {Small=0.85, Medium=1.0, Large=1.15}

function U.applyTheme(name)
    local t = M.Themes[name]
    if not t then return end
    Theme = t
    M.Theme = Theme
    Settings.UI.Theme = name
    M.ThemeBtn.Text = name
    M.Main.BackgroundColor3 = Theme.Bg
    MainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Bg),
        ColorSequenceKeypoint.new(1, Theme.Bg2),
    })
    Stroke.Color = Theme.Stroke
    M.TitleBar.BackgroundColor3 = Theme.Title
    TitleLine.BackgroundColor3 = Theme.Accent
    M.Title.TextColor3 = Theme.Text
    M.SearchBar.BackgroundColor3 = Theme.Panel
    M.SearchBar.TextColor3 = Theme.Text
    for _, b in pairs(M.TabButtons) do
        b.BackgroundColor3 = Theme.Panel
        b.TextColor3 = Theme.TextDim
    end
    local activeName
    for k, p in pairs(M.TabPages) do if p.Visible then activeName = k; break end end
    if activeName then U.selectTab(activeName) end
end

function U.applyScale(name)
    local s = scaleValues[name] or 1.0
    Settings.UI.Scale = name
    M.ScaleBtn.Text = name
    M.Main.Size = UDim2.new(0, 700 * s, 0, 440 * s)
    M.Main.Position = UDim2.new(0.5, -350 * s, 0.5, -220 * s)
end

M.ThemeBtn.MouseButton1Click:Connect(function()
    local idx = table.find(themeOrder, Settings.UI.Theme) or 1
    idx = idx % #themeOrder + 1
    U.applyTheme(themeOrder[idx])
end)
M.ScaleBtn.MouseButton1Click:Connect(function()
    local idx = table.find(scaleOrder, Settings.UI.Scale) or 1
    idx = idx % #scaleOrder + 1
    U.applyScale(scaleOrder[idx])
end)

-- Keybinds
local kbHeader = Instance.new("TextLabel", MenuPage)
kbHeader.Size = UDim2.new(1, -8, 0, 20)
kbHeader.BackgroundTransparency = 1
kbHeader.Text = "KEYBINDS"
kbHeader.TextColor3 = Theme.Accent2
kbHeader.Font = Enum.Font.GothamBold
kbHeader.TextSize = 12
kbHeader.TextXAlignment = Enum.TextXAlignment.Left

function U.makeKeybindRow(parent, text, getKey, setKey)
    local row = U.makeRow(parent)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(getKey())
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0, 60, 0, 20); btn.Position = UDim2.new(1, -70, 0.5, -10)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = "Set"; btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.Gotham; btn.TextSize = 11
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(function()
        lbl.Text = text .. ": ожидание..."
        local conn
        conn = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                setKey(input.KeyCode)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                setKey("MouseButton1")
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                setKey("MouseButton2")
            else return end
            lbl.Text = text .. ": " .. tostring(getKey())
            conn:Disconnect()
        end)
    end)
end

U.makeKeybindRow(MenuPage, "Menu Key",
    function() return Settings.UI.MenuKey.Name end,
    function(v) Settings.UI.MenuKey = (type(v) == "string") and Settings.UI.MenuKey or v end)
U.makeKeybindRow(MenuPage, "Unload Key",
    function() return Settings.UI.UnloadKey.Name end,
    function(v) Settings.UI.UnloadKey = (type(v) == "string") and Settings.UI.UnloadKey or v end)
U.makeKeybindRow(MenuPage, "Aim Key",
    function() return Settings.Aim.KeyName end,
    function(v)
        if type(v) == "string" then Settings.Aim.KeyName = v
        else Settings.Aim.KeyName = v.Name end
    end)

--=====================================================================
-- SEARCH
--=====================================================================
M.SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(M.SearchBar.Text)
    for _, page in pairs(M.TabPages) do
        for _, child in ipairs(page:GetChildren()) do
            if child:IsA("Frame") then
                local txt = ""
                for _, sub in ipairs(child:GetChildren()) do
                    if sub:IsA("TextLabel") then txt = txt .. " " .. string.lower(sub.Text) end
                end
                child.Visible = (q == "") or string.find(txt, q, 1, true) ~= nil
            end
        end
    end
end)

--=====================================================================
-- UNLOAD
--=====================================================================
function U.UNLOAD()
    pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.Default end)
    U.disconnectAll()
    M.StickyTarget = nil
    if M.InfJumpConn then pcall(function() M.InfJumpConn:Disconnect() end); M.InfJumpConn = nil end
    if M.TPWalkConn then M.TPWalkConn:Disconnect(); M.TPWalkConn = nil end
    if M.AntiFlingConn then M.AntiFlingConn:Disconnect(); M.AntiFlingConn = nil end
    U.stopHeadMover()
    if M.WorldBackup then
        local o = M.OriginalLighting
        pcall(function()
            Lighting.Ambient = o.Ambient
            Lighting.OutdoorAmbient = o.OutdoorAmbient
            Lighting.Brightness = o.Brightness
            Lighting.FogEnd = o.FogEnd
            Lighting.FogStart = o.FogStart
            Lighting.ClockTime = o.ClockTime
            Lighting.GlobalShadows = o.GlobalShadows
            Lighting.EnvironmentDiffuseScale = o.EnvironmentDiffuseScale
            Lighting.EnvironmentSpecularScale = o.EnvironmentSpecularScale
        end)
    end
    for m, d in pairs(M.ESPData) do U.destroyESPStruct(d) end
    M.ESPData = {}
    for inst, st in pairs(M.ItemDrawings) do
        if typeof(inst) == "Instance" then U.destroyItemStruct(st) end
    end
    M.ItemDrawings = {}
    for _, obj in ipairs(M.AllDrawings) do pcall(function() obj:Remove() end) end
    M.AllDrawings = {}
    M.TargetLinePool = {}
    pcall(function() ScreenGui:Destroy() end)
    if getgenv() then getgenv().MixWare_Unloaded = true end
end
getgenv().MixWare_UNLOAD = U.UNLOAD

--=====================================================================
-- AUTO-LOAD LAST CONFIG
--=====================================================================
task.spawn(function()
    task.wait(1)
    local lastName = U.getLastConfigName()
    if lastName and lastName ~= "" then
        local ok = U.loadConfig(lastName, false)
        if ok then
            M.ActiveConfigName = lastName
            U.notify("Auto-loaded: " .. lastName, Theme.Good)
        end
    end
end)

--=====================================================================
-- WATERMARK
--=====================================================================
do
    local wm = Instance.new("Frame", ScreenGui)
    wm.Size = UDim2.new(0, 100, 0, 28)
    wm.Position = UDim2.new(0, 15, 0, 15)
    wm.BackgroundColor3 = Theme.Title
    wm.BackgroundTransparency = 0.15
    wm.BorderSizePixel = 0
    wm.Visible = Settings.UI.Watermark
    wm.AutomaticSize = Enum.AutomaticSize.X
    Instance.new("UICorner", wm).CornerRadius = UDim.new(0, 8)
    local ws = Instance.new("UIStroke", wm)
    ws.Color = Theme.Accent; ws.Thickness = 1; ws.Transparency = 0.4
    local wp = Instance.new("UIPadding", wm)
    wp.PaddingLeft = UDim.new(0, 12); wp.PaddingRight = UDim.new(0, 12)
    local wt = Instance.new("TextLabel", wm)
    wt.Size = UDim2.new(0, 0, 1, 0)
    wt.BackgroundTransparency = 1
    wt.Text = "MixWare.lol"
    wt.TextColor3 = Theme.Text
    wt.Font = Enum.Font.GothamMedium
    wt.TextSize = 12
    wt.TextXAlignment = Enum.TextXAlignment.Left
    wt.AutomaticSize = Enum.AutomaticSize.X
    M.Watermark = wm
    M.WatermarkText = wt

    task.spawn(function()
        while ScreenGui.Parent do
            local fps = math.floor(1 / math.max(RunService.RenderStepped:Wait(), 1e-6))
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local time = os.date("%H:%M:%S")
            local pc = #Players:GetPlayers()
            wt.Text = string.format(
                "  MixWare.lol v2.6   |   Config: %s   |   %s   |   FPS %d   |   Ping %d   |   Players %d",
                M.ActiveConfigName, time, fps, ping, pc)
            task.wait(0.5)
        end
    end)
end

--=====================================================================
-- MAIN LOOP
--=====================================================================
U.addConn(RunService.RenderStepped:Connect(function()
    if Settings.ESP.Enabled then U.drawESP()
    else for _, d in pairs(M.ESPData) do U.hideAllESP(d) end end

    U.drawCrosshair()
    U.drawTargetLine()

    if Settings.Aim.Enabled then
        U.drawAimVisuals(M.CurrentTarget)
        if U.isAimKeyDown() and M.CurrentTarget then U.setMouseLock(true)
        else U.setMouseLock(false) end
    else
        U.drawAimVisuals(nil)
        U.setMouseLock(false)
    end
    U.drawAimDebug()

    U.drawItemESP()
    U.updateTrigger()
    U.updateInventoryESP()
    U.keepWorldValues()
    U.keepCameraFOV()
end))

U.addConn(RunService.Heartbeat:Connect(function()
    U.heartbeatAimbot()
end))

--=====================================================================
-- HOTKEYS
--=====================================================================
U.addConn(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.UI.MenuKey then
        Settings.UI.Open = not Settings.UI.Open
        M.Main.Visible = Settings.UI.Open
    elseif input.KeyCode == Settings.UI.UnloadKey then
        U.UNLOAD()
    end
end))

--=====================================================================
-- Min / Close
--=====================================================================
do
    local minimized = false
    local savedSize = M.Main.Size
    M.MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            savedSize = M.Main.Size
            M.Main.Size = UDim2.new(0, 700, 0, 34)
            M.ContentHolder.Visible = false
            M.SearchBar.Visible = false
        else
            M.Main.Size = savedSize
            M.ContentHolder.Visible = true
            M.SearchBar.Visible = true
        end
    end)
    M.CloseBtn.MouseButton1Click:Connect(function()
        Settings.UI.Open = false
        M.Main.Visible = false
    end)
end

U.notify("MixWare.lol v2.6 loaded!", Theme.Accent)
