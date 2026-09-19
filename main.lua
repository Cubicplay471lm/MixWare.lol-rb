--[[
    MixWare.lol v2.6
    ============================================================
    Combat → AimBot | Trigger
    Visuals → Enemies | Items | Inventory | World | Crosshair
    Misc → Misc | Config | Menu
    ============================================================
    Новое в 2.6:
      - Aim: Ground Only, Debug Visuals (всегда)
      - Enemies: Health Bar вертикальный слева, Behind-Wall Pulse,
                 Name Shadow
      - Items: выпадающий список с чекбоксами для выбора предметов
      - World: Remove Grass
      - Crosshair: Rainbow, Sun (8 лучей)
      - Menu: темы (5), масштаб (3), тосты снизу
      - Фикс: Infinite Jump надёжное отключение
      - Фикс: Chams с Adornee
--]]

--=====================================================================
-- API ОБЁРТКИ
--=====================================================================
local cloneref    = cloneref or function(o) return o end
local gethui      = gethui or function() return game:GetService("CoreGui") end
local protect_gui = (syn and syn.protect_gui) or function() end
local getgenv     = getgenv or function() return _G end

local Drawing = Drawing or setmetatable({}, {
    __index = function() return function()
        return setmetatable({}, {
            __index = function() return nil end,
            __newindex = function() end,
        })
    end end
})

local mouse1click = mouse1click or function() end
local RunService  = cloneref(game:GetService("RunService"))
local Players     = cloneref(game:GetService("Players"))
local UIS         = cloneref(game:GetService("UserInputService"))
local Workspace   = cloneref(game:GetService("Workspace"))
local Lighting    = cloneref(game:GetService("Lighting"))
local HttpService = cloneref(game:GetService("HttpService"))
local Stats       = cloneref(game:GetService("Stats"))
local SoundService = cloneref(game:GetService("SoundService"))
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

--=====================================================================
-- ПАЛИТРА (базовая — темы применяются поверх)
--=====================================================================
local Theme = {
    Bg      = Color3.fromRGB(18, 14, 26),
    Bg2     = Color3.fromRGB(26, 18, 38),
    Panel   = Color3.fromRGB(38, 26, 54),
    Row     = Color3.fromRGB(44, 30, 62),
    Title   = Color3.fromRGB(40, 26, 58),
    Accent  = Color3.fromRGB(160, 90, 255),
    Accent2 = Color3.fromRGB(220, 120, 255),
    Text    = Color3.fromRGB(235, 225, 250),
    TextDim = Color3.fromRGB(160, 140, 190),
    Good    = Color3.fromRGB(180, 100, 255),
    Bad     = Color3.fromRGB(220, 70, 130),
    Stroke  = Color3.fromRGB(85, 55, 130),
}

--=====================================================================
-- THEMES PRESETS
--=====================================================================
local Themes = {
    Purple = {
        Bg=Color3.fromRGB(18,14,26), Bg2=Color3.fromRGB(26,18,38),
        Panel=Color3.fromRGB(38,26,54), Row=Color3.fromRGB(44,30,62),
        Title=Color3.fromRGB(40,26,58),
        Accent=Color3.fromRGB(160,90,255), Accent2=Color3.fromRGB(220,120,255),
        Text=Color3.fromRGB(235,225,250), TextDim=Color3.fromRGB(160,140,190),
        Good=Color3.fromRGB(180,100,255), Bad=Color3.fromRGB(220,70,130),
        Stroke=Color3.fromRGB(85,55,130),
    },
    Dark = {
        Bg=Color3.fromRGB(15,15,18), Bg2=Color3.fromRGB(22,22,26),
        Panel=Color3.fromRGB(32,32,38), Row=Color3.fromRGB(38,38,44),
        Title=Color3.fromRGB(34,34,40),
        Accent=Color3.fromRGB(90,140,240), Accent2=Color3.fromRGB(140,180,255),
        Text=Color3.fromRGB(230,230,240), TextDim=Color3.fromRGB(140,140,150),
        Good=Color3.fromRGB(90,140,240), Bad=Color3.fromRGB(210,70,90),
        Stroke=Color3.fromRGB(60,60,70),
    },
    Blue = {
        Bg=Color3.fromRGB(12,18,30), Bg2=Color3.fromRGB(18,26,42),
        Panel=Color3.fromRGB(26,40,62), Row=Color3.fromRGB(32,48,74),
        Title=Color3.fromRGB(28,44,68),
        Accent=Color3.fromRGB(60,140,255), Accent2=Color3.fromRGB(120,190,255),
        Text=Color3.fromRGB(220,235,255), TextDim=Color3.fromRGB(140,170,210),
        Good=Color3.fromRGB(60,140,255), Bad=Color3.fromRGB(220,80,110),
        Stroke=Color3.fromRGB(60,100,150),
    },
    Red = {
        Bg=Color3.fromRGB(20,12,14), Bg2=Color3.fromRGB(30,16,20),
        Panel=Color3.fromRGB(46,22,26), Row=Color3.fromRGB(56,28,32),
        Title=Color3.fromRGB(50,24,30),
        Accent=Color3.fromRGB(230,70,90), Accent2=Color3.fromRGB(255,130,150),
        Text=Color3.fromRGB(250,230,235), TextDim=Color3.fromRGB(200,150,160),
        Good=Color3.fromRGB(230,70,90), Bad=Color3.fromRGB(255,50,60),
        Stroke=Color3.fromRGB(120,50,60),
    },
    Pink = {
        Bg=Color3.fromRGB(24,14,22), Bg2=Color3.fromRGB(36,20,32),
        Panel=Color3.fromRGB(54,28,48), Row=Color3.fromRGB(66,34,58),
        Title=Color3.fromRGB(58,30,52),
        Accent=Color3.fromRGB(255,110,180), Accent2=Color3.fromRGB(255,170,220),
        Text=Color3.fromRGB(250,225,240), TextDim=Color3.fromRGB(200,150,180),
        Good=Color3.fromRGB(255,110,180), Bad=Color3.fromRGB(230,60,120),
        Stroke=Color3.fromRGB(140,70,110),
    },
}

--=====================================================================
-- ЗАХАРДКОЖЕННЫЕ ПУТИ
--=====================================================================
local ITEM_ESP_PATHS = {
    "Workspace.Spawned.MouselgnoreFolder.Loot",
    "Workspace.Spawned.Destructibles",
}

--=====================================================================
-- НАСТРОЙКИ
--=====================================================================
local Settings = {
    Mode = 1,

    ESP = {
        Enabled = false, ChamsEnabled = false,
        ChamsColor = Color3.fromRGB(160, 90, 255), ChamsTransp = 0.5,
        ChamsTargetColor = Color3.fromRGB(255, 60, 130),
        BoxEnabled = false, BoxColor = Color3.fromRGB(200, 170, 255), BoxThickness = 1,
        CornerEnabled = false, CornerColor = Color3.fromRGB(180, 100, 255),
        CornerLength = 10, CornerThickness = 1,
        Box3DEnabled = false, Box3DColor = Color3.fromRGB(220, 120, 255),
        TracerEnabled = false, TracerColor = Color3.fromRGB(200, 100, 255),
        TracerOrigin = "Bottom",
        NameEnabled = true, DistanceEnabled = true, MaxDistance = 1000,
        VisibleCheck = false,
        VisibleColor = Color3.fromRGB(200, 130, 255),
        SkeletonEnabled = false,
        SkeletonColor = Color3.fromRGB(200, 130, 255),
        SkeletonThickness = 1,
        HealthBarEnabled = false,
        HealthBarWidth = 4,
        HealthBarHeight = 40,
        HealthBarOffset = 6,
        NametagsEnabled = false,
        NametagsShowHP = true,
        NametagsShowDist = true,
        ArrowsEnabled = false,
        ArrowsColor = Color3.fromRGB(200, 130, 255),
        ArrowsSize = 14,
        WeaponNameEnabled = false,
        WeaponNameColor = Color3.fromRGB(255, 180, 220),
        WeaponNameSize = 12,
        DistanceFade = false,
        DistanceFadeStart = 0.7,
        -- Behind-Wall Pulse
        PulseEnabled = false,
        PulseSpeed = 1.5,
        PulseMin = 0.35,
        PulseMax = 0.85,
        -- Name Shadow
        NameShadow = false,
    },
    Crosshair = {
        Enabled = false,
        Style = "Cross",
        Color = Color3.fromRGB(255, 255, 255),
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Gap = 4,
        Length = 8,
        Thickness = 1,
        Dot = true,
        DotSize = 2,
        CircleRadius = 12,
        Outline = true,
        Rainbow = false,
    },
    ItemESP = {
        Enabled = false,
        Color = Color3.fromRGB(220, 180, 100),
        MaxDistance = 500,
        TextEnabled = true,
        RefreshRate = 0.2,
        SelectedItems = {},  -- [name] = true/false
    },
    WorldESP = {
        Enabled = false,
        Color = Color3.fromRGB(120, 220, 200),
        MaxDistance = 500,
        TextEnabled = true,
    },
    World = {
        FullBright = false,
        NoFog = false,
        CustomTimeEnabled = false,
        CustomTime = 14,
        CustomAmbientEnabled = false,
        AmbientColor = Color3.fromRGB(178, 178, 178),
        CameraFOVEnabled = false,
        CameraFOV = 70,
        DisableSunRays = false,
        DisableAtmosphere = false,
        RemoveGrass = false,
    },
    InvESP = {
        Enabled = false, Transparency = 0.35, ShowLocal = true,
        FontSize = 14, ShowTools = true, ShowHealth = true,
        RefreshInterval = 0.25,
    },
    Aim = {
        Enabled = false, FOV = 120, ShowFOV = true,
        Instant = false, Smoothness = 0.15,
        SmoothCurve = "Linear",
        Bone = "Head", KeyName = "MouseButton2",
        WallCheck = false, TeamCheck = true,
        AimAtHitPoint = true,
        StickyMultiplier = 2.0,
        Prediction = false,
        PredictionFactor = 1.0,
        HeadMover = false,
        HeadMoverDistance = 30,
        HeadMoverOnlyAimKey = true,
        HeadMoverSpeed = 1.0,
        TargetLine = false,
        TargetLineColor = Color3.fromRGB(255, 100, 200),
        TargetLineThickness = 1,
        TargetLineTransparency = 0.2,
        TargetLineOnlyAiming = true,
        TargetLineStyle = "Solid",
        TargetLineDashCount = 8,
        -- NEW 2.6
        GroundOnly = false,
        DebugVisuals = false,
    },
    Trigger = {
        Enabled = false, Delay = 0.05,
        TeamCheck = true, WallCheck = false, OnlyAimKey = true,
    },
    Misc = {
        TPWalkEnabled = false, TPWalkSpeed = 20,
        InfJump = false, WalkSpeed = 16, JumpPower = 50,
        AntiFling = false,
    },
    Sound = {
        KillSound = true,
        TargetLockSound = true,
        KillSoundId = "rbxassetid://5275866553",
        TargetLockSoundId = "rbxassetid://876939830",
    },
    UI = {
        Open = true, MenuKey = Enum.KeyCode.RightShift, UnloadKey = Enum.KeyCode.End,
        Watermark = true,
        Notifications = true,
        Theme = "Purple",
        Scale = "Medium",
    },
}

local ActiveConfigName = "none"

--=====================================================================
-- ЦВЕТА → HEX
--=====================================================================
local function colorToHex(c)
    if typeof(c) ~= "Color3" then return c end
    return "#" .. c:ToHex()
end

local function hexToColor(s)
    if type(s) ~= "string" then return s end
    if string.sub(s, 1, 1) ~= "#" then return s end
    local ok, c = pcall(function() return Color3.fromHex(s) end)
    if ok then return c end
    return Color3.new(1,1,1)
end

local function serializeSettings(tbl)
    local out = {}
    for k, v in pairs(tbl) do
        if typeof(v) == "Color3" then
            out[k] = colorToHex(v)
        elseif type(v) == "table" then
            out[k] = serializeSettings(v)
        else
            out[k] = v
        end
    end
    return out
end

local function deserializeSettings(dst, src)
    for k, v in pairs(src) do
        if type(v) == "string" and string.sub(v, 1, 1) == "#" then
            dst[k] = hexToColor(v)
        elseif type(v) == "table" and type(dst[k]) == "table" then
            deserializeSettings(dst[k], v)
        elseif type(v) == "table" and type(dst[k]) ~= "table" then
            dst[k] = v
        else
            dst[k] = v
        end
    end
end

--=====================================================================
-- NOTIFICATIONS (снизу справа)
--=====================================================================
local NotifyHolder = nil
local function setupNotifyHolder(screenGui)
    NotifyHolder = Instance.new("Frame")
    NotifyHolder.Name = "NotifyHolder"
    NotifyHolder.Size = UDim2.new(0, 280, 1, -40)
    NotifyHolder.Position = UDim2.new(1, -300, 0, 20)
    NotifyHolder.BackgroundTransparency = 1
    NotifyHolder.Parent = screenGui
    local layout = Instance.new("UIListLayout", NotifyHolder)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

local function notify(text, color)
    if not Settings.UI.Notifications or not NotifyHolder then return end
    color = color or Theme.Accent
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 34)
    toast.BackgroundColor3 = Theme.Title
    toast.BackgroundTransparency = 0.1
    toast.BorderSizePixel = 0
    toast.Parent = NotifyHolder
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", toast)
    stroke.Color = color; stroke.Thickness = 1; stroke.Transparency = 0.3
    local accent = Instance.new("Frame", toast)
    accent.Size = UDim2.new(0, 3, 1, -8); accent.Position = UDim2.new(0, 4, 0, 4)
    accent.BackgroundColor3 = color; accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)
    local lbl = Instance.new("TextLabel", toast)
    lbl.Size = UDim2.new(1, -20, 1, 0); lbl.Position = UDim2.new(0, 14, 0, 0)
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

local function playSound(id)
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = 0.5
        s.Parent = SoundService
        s:Play()
        task.delay(3, function() s:Destroy() end)
    end)
end

--=====================================================================
-- SET/GET PATH
--=====================================================================
local function setPath(path, value)
    local keys = {}
    for k in string.gmatch(path, "[^%.]+") do table.insert(keys, k) end
    local target = Settings
    for i = 1, #keys - 1 do
        target = target[keys[i]]
        if type(target) ~= "table" then return end
    end
    target[keys[#keys]] = value
end

local function getPath(path)
    local keys = {}
    for k in string.gmatch(path, "[^%.]+") do table.insert(keys, k) end
    local target = Settings
    for i = 1, #keys do
        if type(target) ~= "table" then return nil end
        target = target[keys[i]]
    end
    return target
end

--=====================================================================
-- CONNECTIONS
--=====================================================================
local Connections = {}
local function addConn(c) table.insert(Connections, c); return c end
local function disconnectAll()
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    Connections = {}
end

--=====================================================================
-- UTILS
--=====================================================================
local function worldToScreen(pos)
    local sp, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), on, sp.Z
end

local function getFOVOrigin()
    return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end

local function isAimKeyDown()
    local kn = Settings.Aim.KeyName
    if kn == "MouseButton2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
    if kn == "MouseButton1" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
    local kc = Enum.KeyCode[kn]
    if kc then return UIS:IsKeyDown(kc) end
    return false
end

local function isVisibleFromCam(part, targetModel)
    if not part then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    params.IgnoreWater = true
    local origin = Camera.CFrame.Position
    local dest = part.Position
    local res = Workspace:Raycast(origin, dest - origin, params)
    if not res or not res.Instance then return true end
    if targetModel and res.Instance:IsDescendantOf(targetModel) then return true end
    if res.Instance == part then return true end
    return false
end

local function getVisibleStateForModel(model)
    if not model then return false end
    local head = model:FindFirstChild("Head")
    local torso = model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Chest")
        or model:FindFirstChild("HumanoidRootPart")
    if head and isVisibleFromCam(head, model) then return true end
    if torso and isVisibleFromCam(torso, model) then return true end
    return false
end

local function belongsToLocalPlayer(inst)
    if not inst then return false end
    local ch = LocalPlayer.Character
    if not ch then return false end
    if inst == ch then return true end
    if inst:IsDescendantOf(ch) then return true end
    return false
end

local function applyCurve(t, curve)
    if curve == "EaseOut" then
        return 1 - (1 - t) * (1 - t)
    elseif curve == "Sine" then
        return math.sin(t * math.pi / 2)
    end
    return t
end

--=====================================================================
-- MODE 1
--=====================================================================
local function getCharacterForPlayer(plr)
    if not plr then return nil, nil, nil end
    local ch = plr.Character
    if not ch then return nil, nil, nil end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    local hum = ch:FindFirstChildOfClass("Humanoid")
    return ch, hrp, hum
end

local function getModelCFrame(model)
    if not model or not model.Parent then return nil end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.CFrame end
    local ok, piv = pcall(function() return model:GetPivot() end)
    if ok then return piv end
    return nil
end

local function getModelBounds(model)
    local head = model:FindFirstChild("Head")
    local hrp  = model:FindFirstChild("HumanoidRootPart")
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

--=====================================================================
-- ESP
--=====================================================================
local ESPData = {}
local AllDrawings = {}

local function newDrawing(kind)
    local ok, obj = pcall(function() return Drawing.new(kind) end)
    if ok and obj then table.insert(AllDrawings, obj); return obj end
    return {
        Remove = function() end, Visible = false,
        Color = Color3.new(), Thickness = 1, Transparency = 1,
        From = Vector2.new(), To = Vector2.new(),
        Position = Vector2.new(), Size = Vector2.new(),
        Text = "", Center = false, Outline = false,
        PointA = Vector2.new(), PointB = Vector2.new(), PointC = Vector2.new(),
        Filled = false, Radius = 0, NumSides = 64,
    }
end

local function createESPStruct()
    local d = {}
    d.box = newDrawing("Square")
    d.corners = {}
    for i = 1, 8 do d.corners[i] = newDrawing("Line") end
    d.box3d = {}
    for i = 1, 12 do d.box3d[i] = newDrawing("Line") end
    d.tracer = newDrawing("Line")
    d.name   = newDrawing("Text")
    d.dist   = newDrawing("Text")
    d.nameShadow = newDrawing("Text")
    d.name.Center = true; d.name.Outline = true; d.name.Size = 14
    d.nameShadow.Center = true; d.nameShadow.Outline = false; d.nameShadow.Size = 14
    d.dist.Center = true; d.dist.Outline = true; d.dist.Size = 12
    d.skeleton = {}
    for i = 1, 20 do d.skeleton[i] = newDrawing("Line") end
    d.hpBg = newDrawing("Square")
    d.hpFill = newDrawing("Square")
    d.nametag = newDrawing("Text")
    d.nametag.Center = true; d.nametag.Outline = true; d.nametag.Size = 12
    d.arrow = newDrawing("Triangle")
    d.arrow.Filled = true
    d.weapon = newDrawing("Text")
    d.weapon.Center = true
    d.weapon.Outline = true
    return d
end

local function destroyESPStruct(d)
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

local function hideAllESP(d)
    pcall(function() d.box.Visible = false end)
    for _, c in pairs(d.corners) do c.Visible = false end
    for _, l in pairs(d.box3d) do l.Visible = false end
    for _, l in pairs(d.skeleton) do l.Visible = false end
    d.tracer.Visible = false
    d.name.Visible   = false
    d.dist.Visible   = false
    d.nameShadow.Visible = false
    d.hpBg.Visible   = false
    d.hpFill.Visible = false
    d.nametag.Visible = false
    d.arrow.Visible  = false
    d.weapon.Visible = false
    if d.highlight then d.highlight.Enabled = false end
end

local function updateChamsForModel(model, isTarget)
    local d = ESPData[model]
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
    if isTarget then
        color = Settings.ESP.ChamsTargetColor
    elseif Settings.ESP.VisibleCheck and getVisibleStateForModel(model) then
        color = Settings.ESP.VisibleColor
    else
        color = Settings.ESP.ChamsColor
    end
    d.highlight.FillColor        = color
    d.highlight.OutlineColor     = color
    d.highlight.FillTransparency = Settings.ESP.ChamsTransp
    d.highlight.OutlineTransparency = Settings.ESP.ChamsTransp * 0.5
    d.highlight.Enabled = true
end

local SkeletonJoints = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Left Arm", "LeftLeg"},
    {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local function drawSkeleton(model, d, color, thick)
    local idx = 0
    for _, joint in ipairs(SkeletonJoints) do
        local a = model:FindFirstChild(joint[1])
        local b = model:FindFirstChild(joint[2])
        if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
            idx = idx + 1
            if idx > #d.skeleton then break end
            local ln = d.skeleton[idx]
            local aScreen, aOn = worldToScreen(a.CFrame.Position)
            local bScreen, bOn = worldToScreen(b.CFrame.Position)
            if aOn and bOn then
                ln.From = aScreen; ln.To = bScreen
                ln.Color = color; ln.Thickness = thick
                ln.Transparency = 0.2; ln.Visible = true
            else ln.Visible = false end
        end
    end
    for i = idx + 1, #d.skeleton do d.skeleton[i].Visible = false end
end

local function drawArrow(d, worldPos, color, size)
    local sp, on = worldToScreen(worldPos)
    if on then d.arrow.Visible = false; return end
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local rel = worldPos - Camera.CFrame.Position
    local camRight = Camera.CFrame.RightVector
    local camUp = Camera.CFrame.UpVector
    local x = rel:Dot(camRight)
    local y = rel:Dot(camUp)
    local mag = math.sqrt(x*x + y*y)
    if mag < 0.01 then d.arrow.Visible = false; return end
    local dir = Vector2.new(x / mag, -y / mag)
    local radius = math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) * 0.35
    local tip = center + dir * radius
    local perp = Vector2.new(-dir.Y, dir.X) * (size / 2)
    d.arrow.PointA = tip
    d.arrow.PointB = center + dir * (radius - size) + perp
    d.arrow.PointC = center + dir * (radius - size) - perp
    d.arrow.Color = color; d.arrow.Filled = true; d.arrow.Visible = true
end

local function getFadeAlpha(dist, maxDist)
    if not Settings.ESP.DistanceFade then return 1 end
    local fadeStart = maxDist * math.clamp(Settings.ESP.DistanceFadeStart, 0.1, 1)
    if dist <= fadeStart then return 1 end
    if dist >= maxDist then return 0 end
    return 1 - ((dist - fadeStart) / (maxDist - fadeStart))
end

local function getWeaponName(model)
    local tool = model:FindFirstChildWhichIsA("Tool")
    if tool then return tool.Name end
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Model") then
            local rh = model:FindFirstChild("RightHand") or model:FindFirstChild("Right Arm")
            if rh and child:IsDescendantOf(rh) then return child.Name end
        end
    end
    local rh = model:FindFirstChild("RightHand") or model:FindFirstChild("Right Arm")
    if rh then
        for _, child in ipairs(rh:GetChildren()) do
            if child:IsA("Tool") or child:IsA("Model") then return child.Name end
        end
    end
    return nil
end

-- Пульсация за стеной: вычисляем альфу на основе времени
local function getPulseAlpha(now)
    if not Settings.ESP.PulseEnabled then return 1 end
    local speed = Settings.ESP.PulseSpeed
    local minA = Settings.ESP.PulseMin
    local maxA = Settings.ESP.PulseMax
    local t = (math.sin(now * speed * math.pi * 2) + 1) * 0.5  -- 0..1
    return minA + (maxA - minA) * t
end

local lastESPUpdate = 0
local ESP_INTERVAL = 1/60

local function drawESPForModel(model, plr)
    local d = ESPData[model]
    if not d then
        d = createESPStruct()
        ESPData[model] = d
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then hideAllESP(d); return end
    local cf = getModelCFrame(model)
    if not cf then hideAllESP(d); return end
    local maxDist = Settings.ESP.MaxDistance
    local dist = (Camera.CFrame.Position - cf.Position).Magnitude
    if dist > maxDist then hideAllESP(d); return end

    local alpha = getFadeAlpha(dist, maxDist)

    local visible = true
    if Settings.ESP.VisibleCheck then
        visible = getVisibleStateForModel(model)
    end

    -- Behind-Wall Pulse: если цель НЕ видна и пульсация включена — мерцаем
    local pulseMul = 1
    if Settings.ESP.PulseEnabled and Settings.ESP.VisibleCheck and not visible then
        pulseMul = getPulseAlpha(tick())
    end
    alpha = alpha * pulseMul

    local override = nil
    if Settings.ESP.VisibleCheck and visible then
        override = Settings.ESP.VisibleColor
    end

    local fBoxColor    = override or Settings.ESP.BoxColor
    local fCornerColor = override or Settings.ESP.CornerColor
    local fBox3DColor  = override or Settings.ESP.Box3DColor
    local fTracerColor = override or Settings.ESP.TracerColor
    local fNameColor   = override or Color3.new(1, 1, 1)
    local fDistColor   = override or Color3.fromRGB(200, 200, 200)
    local fSkelColor   = override or Settings.ESP.SkeletonColor
    local fArrowColor  = override or Settings.ESP.ArrowsColor
    local fWeaponColor = Settings.ESP.WeaponNameColor

    local topPos, botPos = getModelBounds(model)
    if not topPos then
        topPos = cf.Position + Vector3.new(0, 3, 0)
        botPos = cf.Position - Vector3.new(0, 3, 0)
    end
    local topScreen, topOn = worldToScreen(topPos)
    local botScreen, botOn = worldToScreen(botPos)
    if not topOn and not botOn then hideAllESP(d); return end

    local height = botScreen.Y - topScreen.Y
    local width  = height * 0.5
    local x      = topScreen.X - width / 2
    local y      = topScreen.Y

    -- BOX
    if Settings.ESP.BoxEnabled then
        d.box.Size = Vector2.new(width, height)
        d.box.Position = Vector2.new(x, y)
        d.box.Color = fBoxColor
        d.box.Thickness = Settings.ESP.BoxThickness
        d.box.Transparency = alpha
        d.box.Filled = false; d.box.Visible = true
    else d.box.Visible = false end

    -- CORNERS
    if Settings.ESP.CornerEnabled then
        local L, t = Settings.ESP.CornerLength, Settings.ESP.CornerThickness
        local pts = {
            {Vector2.new(x, y), Vector2.new(x + L, y)},
            {Vector2.new(x, y), Vector2.new(x, y + L)},
            {Vector2.new(x + width, y), Vector2.new(x + width - L, y)},
            {Vector2.new(x + width, y), Vector2.new(x + width, y + L)},
            {Vector2.new(x, y + height), Vector2.new(x + L, y + height)},
            {Vector2.new(x, y + height), Vector2.new(x, y + height - L)},
            {Vector2.new(x + width, y + height), Vector2.new(x + width - L, y + height)},
            {Vector2.new(x + width, y + height), Vector2.new(x + width, y + height - L)},
        }
        for i, seg in ipairs(pts) do
            local ln = d.corners[i]
            ln.From = seg[1]; ln.To = seg[2]
            ln.Color = fCornerColor; ln.Thickness = t
            ln.Transparency = alpha
            ln.Visible = true
        end
    else for _, c in pairs(d.corners) do c.Visible = false end end

    -- 3D BOX
    if Settings.ESP.Box3DEnabled then
        local edges = {{1,2},{3,4},{5,6},{7,8},{1,3},{2,4},{5,7},{6,8},{1,5},{2,6},{3,7},{4,8}}
        local corners = {}
        local ok, mcf, size = pcall(function()
            local c, s = model:GetBoundingBox()
            return c, s
        end)
        if ok and mcf and size then
            local hx, hy, hz = size.X/2, size.Y/2, size.Z/2
            for xi = -1, 1, 2 do for yi = -1, 1, 2 do for zi = -1, 1, 2 do
                local wp = mcf * Vector3.new(hx*xi, hy*yi, hz*zi)
                local sp, on = worldToScreen(wp)
                table.insert(corners, {sp, on})
            end end end
            for i, e in ipairs(edges) do
                local ln = d.box3d[i]
                local a, b = corners[e[1]], corners[e[2]]
                if a and b and a[2] and b[2] then
                    ln.From = a[1]; ln.To = b[1]
                    ln.Color = fBox3DColor
                    ln.Thickness = 1; ln.Transparency = alpha; ln.Visible = true
                else ln.Visible = false end
            end
        else
            for _, l in pairs(d.box3d) do l.Visible = false end
        end
    else for _, l in pairs(d.box3d) do l.Visible = false end end

    -- TRACER
    if Settings.ESP.TracerEnabled then
        local vp = Camera.ViewportSize
        local origin
        if Settings.ESP.TracerOrigin == "Top" then origin = Vector2.new(vp.X/2, 0)
        elseif Settings.ESP.TracerOrigin == "Center" then origin = Vector2.new(vp.X/2, vp.Y/2)
        else origin = Vector2.new(vp.X/2, vp.Y) end
        d.tracer.From = origin
        d.tracer.To = botScreen
        d.tracer.Color = fTracerColor
        d.tracer.Thickness = 1
        d.tracer.Transparency = alpha
        d.tracer.Visible = true
    else d.tracer.Visible = false end

    -- NAME + SHADOW
    local displayName = model.Name
    if plr then displayName = (plr.DisplayName ~= "" and plr.DisplayName) or plr.Name end
    local namePos = Vector2.new(x + width/2, y - 16)
    if Settings.ESP.NameShadow then
        d.nameShadow.Text = displayName
        d.nameShadow.Position = Vector2.new(namePos.X + 1, namePos.Y + 1)
        d.nameShadow.Color = Color3.new(0, 0, 0)
        d.nameShadow.Transparency = math.min(1, alpha + 0.2)
        d.nameShadow.Visible = Settings.ESP.NameEnabled
    else
        d.nameShadow.Visible = false
    end
    d.name.Text = displayName
    d.name.Position = namePos
    d.name.Color = fNameColor
    d.name.Transparency = alpha
    d.name.Visible = Settings.ESP.NameEnabled

    d.dist.Text = string.format("[%d]", math.floor(dist))
    d.dist.Position = Vector2.new(x + width/2, y + height + 2)
    d.dist.Color = fDistColor
    d.dist.Transparency = alpha
    d.dist.Visible = Settings.ESP.DistanceEnabled

    -- WEAPON NAME
    if Settings.ESP.WeaponNameEnabled then
        local wName = getWeaponName(model)
        if wName then
            d.weapon.Text = "[" .. wName .. "]"
            d.weapon.Position = Vector2.new(x + width/2, y - 30)
            d.weapon.Color = fWeaponColor
            d.weapon.Size = Settings.ESP.WeaponNameSize
            d.weapon.Transparency = alpha
            d.weapon.Visible = true
        else
            d.weapon.Visible = false
        end
    else
        d.weapon.Visible = false
    end

    -- SKELETON
    if Settings.ESP.SkeletonEnabled then
        drawSkeleton(model, d, fSkelColor, Settings.ESP.SkeletonThickness)
        for _, l in pairs(d.skeleton) do l.Transparency = alpha end
    else for _, l in pairs(d.skeleton) do l.Visible = false end end

    -- HEALTH BAR (вертикальный слева)
    if Settings.ESP.HealthBarEnabled and hum then
        local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        local barW = Settings.ESP.HealthBarWidth
        local barH = height  -- на всю высоту бокса
        local offset = Settings.ESP.HealthBarOffset
        local bx = x - barW - offset
        local by = y
        -- фон
        d.hpBg.Size = Vector2.new(barW, barH)
        d.hpBg.Position = Vector2.new(bx, by)
        d.hpBg.Color = Color3.fromRGB(30, 20, 40)
        d.hpBg.Filled = true; d.hpBg.Visible = true
        d.hpBg.Transparency = math.min(1, alpha + 0.2)
        -- заполнение (снизу вверх)
        local fillH = barH * hpRatio
        d.hpFill.Size = Vector2.new(barW, fillH)
        d.hpFill.Position = Vector2.new(bx, by + (barH - fillH))
        -- плавный градиент: HP 1.0 = зелёный, 0.5 = жёлтый, 0.2 = оранжевый, 0 = красный
        local r, g, b
        if hpRatio > 0.5 then
            -- зелёный → жёлтый
            local t = (hpRatio - 0.5) / 0.5  -- 1..0
            r = 1 - t
            g = 1
            b = 0.1
        elseif hpRatio > 0.2 then
            -- жёлтый → оранжевый
            local t = (hpRatio - 0.2) / 0.3  -- 1..0
            r = 1
            g = 0.4 + t * 0.6
            b = 0.1
        else
            -- оранжевый → красный
            local t = hpRatio / 0.2  -- 1..0
            r = 1
            g = 0.4 * t
            b = 0.1
        end
        d.hpFill.Color = Color3.new(r, g, b)
        d.hpFill.Filled = true; d.hpFill.Visible = true
        d.hpFill.Transparency = alpha
    else
        d.hpBg.Visible = false; d.hpFill.Visible = false
    end

    -- NAMETAG
    if Settings.ESP.NametagsEnabled and hum then
        local parts = {}
        if Settings.ESP.NametagsShowHP then
            table.insert(parts, string.format("[%d HP]", math.floor(hum.Health)))
        end
        if Settings.ESP.NametagsShowDist then
            table.insert(parts, string.format("[%dm]", math.floor(dist)))
        end
        d.nametag.Text = table.concat(parts, " ")
        d.nametag.Position = Vector2.new(x + width/2, y - 44)
        d.nametag.Color = fNameColor
        d.nametag.Transparency = alpha
        d.nametag.Visible = true
    else d.nametag.Visible = false end

    -- ARROWS
    if Settings.ESP.ArrowsEnabled then
        local headPart = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
        if headPart then drawArrow(d, headPart.Position, fArrowColor, Settings.ESP.ArrowsSize) end
        if d.arrow.Visible then d.arrow.Transparency = alpha end
    else d.arrow.Visible = false end
end

local function drawESP()
    local now = tick()
    if now - lastESPUpdate < ESP_INTERVAL then return end
    lastESPUpdate = now
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local ch, hrp = getCharacterForPlayer(plr)
            if ch and hrp then seen[ch] = true; drawESPForModel(ch, plr) end
        end
    end
    for m, d in pairs(ESPData) do
        if not seen[m] or not m.Parent then
            destroyESPStruct(d); ESPData[m] = nil
        end
    end
end

--=====================================================================
-- CROSSHAIR (Rainbow + Sun)
--=====================================================================
local CrosshairParts = nil
local function initCrosshair()
    CrosshairParts = {
        line1 = newDrawing("Line"),
        line2 = newDrawing("Line"),
        line3 = newDrawing("Line"),
        line4 = newDrawing("Line"),
        dot   = newDrawing("Square"),
        circle = newDrawing("Circle"),
        o1 = newDrawing("Line"),
        o2 = newDrawing("Line"),
        o3 = newDrawing("Line"),
        o4 = newDrawing("Line"),
        sunLines = {},
    }
    for i = 1, 8 do
        CrosshairParts.sunLines[i] = newDrawing("Line")
    end
end
initCrosshair()

local function hideCrosshair()
    if not CrosshairParts then return end
    for _, obj in pairs(CrosshairParts) do
        if type(obj) == "table" then
            for _, o in pairs(obj) do pcall(function() o.Visible = false end) end
        else
            pcall(function() obj.Visible = false end)
        end
    end
end

local function getCrosshairColor()
    if not Settings.Crosshair.Rainbow then
        return Settings.Crosshair.Color
    end
    local h = (tick() * 0.3) % 1
    return Color3.fromHSV(h, 1, 1)
end

local function drawCrosshair()
    if not Settings.Crosshair.Enabled then hideCrosshair(); return end
    local c = Settings.Crosshair
    local center = getFOVOrigin()
    local gap, len, thick = c.Gap, c.Length, c.Thickness
    local color = getCrosshairColor()

    local function setLine(ln, from, to, col, thickness)
        ln.From = from; ln.To = to
        ln.Color = col; ln.Thickness = thickness
        ln.Transparency = 0
        ln.Visible = true
    end

    -- Скрыть все сначала (потом показать нужные)
    for _, obj in pairs(CrosshairParts) do
        if type(obj) == "table" then
            for _, o in pairs(obj) do o.Visible = false end
        else
            obj.Visible = false
        end
    end

    if c.Style == "Sun" then
        -- 8 лучей + точка + маленький круг
        local rayLen = len * 1.5
        local startR = gap + 2
        local endR = startR + rayLen
        for i = 1, 8 do
            local angle = (i - 1) * (math.pi / 4)
            local dx = math.cos(angle)
            local dy = math.sin(angle)
            local ln = CrosshairParts.sunLines[i]
            ln.From = Vector2.new(center.X + dx * startR, center.Y + dy * startR)
            ln.To   = Vector2.new(center.X + dx * endR, center.Y + dy * endR)
            ln.Color = color
            ln.Thickness = thick
            ln.Transparency = 0
            ln.Visible = true
        end
        -- маленький круг в центре
        CrosshairParts.circle.Position = center
        CrosshairParts.circle.Radius = c.DotSize * 1.5
        CrosshairParts.circle.Thickness = thick
        CrosshairParts.circle.NumSides = 32
        CrosshairParts.circle.Color = color
        CrosshairParts.circle.Filled = false
        CrosshairParts.circle.Transparency = 0
        CrosshairParts.circle.Visible = true
        -- точка в центре
        if c.Dot then
            CrosshairParts.dot.Size = Vector2.new(c.DotSize, c.DotSize)
            CrosshairParts.dot.Position = Vector2.new(center.X - c.DotSize/2, center.Y - c.DotSize/2)
            CrosshairParts.dot.Color = color
            CrosshairParts.dot.Filled = true
            CrosshairParts.dot.Visible = true
        end
        return
    end

    if c.Style == "Cross" then
        setLine(CrosshairParts.line1, Vector2.new(center.X, center.Y - gap - len),
            Vector2.new(center.X, center.Y - gap), color, thick)
        setLine(CrosshairParts.line2, Vector2.new(center.X, center.Y + gap),
            Vector2.new(center.X, center.Y + gap + len), color, thick)
        setLine(CrosshairParts.line3, Vector2.new(center.X - gap - len, center.Y),
            Vector2.new(center.X - gap, center.Y), color, thick)
        setLine(CrosshairParts.line4, Vector2.new(center.X + gap, center.Y),
            Vector2.new(center.X + gap + len, center.Y), color, thick)
        if c.Outline then
            local oc = c.OutlineColor
            setLine(CrosshairParts.o1, Vector2.new(center.X - 1, center.Y - gap - len),
                Vector2.new(center.X - 1, center.Y - gap), oc, thick + 2)
            setLine(CrosshairParts.o2, Vector2.new(center.X - 1, center.Y + gap),
                Vector2.new(center.X - 1, center.Y + gap + len), oc, thick + 2)
            setLine(CrosshairParts.o3, Vector2.new(center.X - gap - len, center.Y - 1),
                Vector2.new(center.X - gap, center.Y - 1), oc, thick + 2)
            setLine(CrosshairParts.o4, Vector2.new(center.X + gap, center.Y - 1),
                Vector2.new(center.X + gap + len, center.Y - 1), oc, thick + 2)
        end

    elseif c.Style == "Crosshair" then
        local shortLen = len * 0.6
        setLine(CrosshairParts.line1, Vector2.new(center.X, center.Y - gap),
            Vector2.new(center.X, center.Y - gap - shortLen), color, thick)
        setLine(CrosshairParts.line2, Vector2.new(center.X, center.Y + gap),
            Vector2.new(center.X, center.Y + gap + shortLen), color, thick)
        setLine(CrosshairParts.line3, Vector2.new(center.X - gap, center.Y),
            Vector2.new(center.X - gap - shortLen, center.Y), color, thick)
        setLine(CrosshairParts.line4, Vector2.new(center.X + gap, center.Y),
            Vector2.new(center.X + gap + shortLen, center.Y), color, thick)

    elseif c.Style == "Circle" then
        CrosshairParts.circle.Position = center
        CrosshairParts.circle.Radius = c.CircleRadius
        CrosshairParts.circle.Thickness = thick
        CrosshairParts.circle.NumSides = 64
        CrosshairParts.circle.Color = color
        CrosshairParts.circle.Filled = false
        CrosshairParts.circle.Transparency = 0
        CrosshairParts.circle.Visible = true

    elseif c.Style == "Dot" then
        -- ничего кроме точки
    end

    if c.Dot then
        local size = c.DotSize
        CrosshairParts.dot.Size = Vector2.new(size, size)
        CrosshairParts.dot.Position = Vector2.new(center.X - size/2, center.Y - size/2)
        CrosshairParts.dot.Color = color
        CrosshairParts.dot.Filled = true
        CrosshairParts.dot.Transparency = 0
        CrosshairParts.dot.Visible = true
    end
end

--=====================================================================
-- TARGET LINE
--=====================================================================
local TargetLinePool = {}
local TargetLineSingle = newDrawing("Line")

local function getTargetLineEndpoint(part)
    if not part then return nil end
    if Settings.Aim.AimAtHitPoint then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
        local res = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
        if res and res.Instance and res.Instance:IsDescendantOf(part.Parent) then
            return res.Position
        end
    end
    return part.Position
end

local function ensureTargetLinePool(count)
    while #TargetLinePool < count do
        table.insert(TargetLinePool, newDrawing("Line"))
    end
    while #TargetLinePool > count do
        local ln = table.remove(TargetLinePool)
        pcall(function() ln.Visible = false end)
    end
end

local function drawTargetLine()
    if not Settings.Aim.TargetLine then
        TargetLineSingle.Visible = false
        for _, ln in ipairs(TargetLinePool) do ln.Visible = false end
        return
    end
    if Settings.Aim.TargetLineOnlyAiming and not isAimKeyDown() then
        TargetLineSingle.Visible = false
        for _, ln in ipairs(TargetLinePool) do ln.Visible = false end
        return
    end
    local t = currentTarget
    if not t then
        TargetLineSingle.Visible = false
        for _, ln in ipairs(TargetLinePool) do ln.Visible = false end
        return
    end
    local model, part = resolveAimTarget(t)
    if not part then
        TargetLineSingle.Visible = false
        for _, ln in ipairs(TargetLinePool) do ln.Visible = false end
        return
    end
    local center = getFOVOrigin()
    local worldPos = getTargetLineEndpoint(part) or part.Position
    local screen, on = worldToScreen(worldPos)
    if not on then
        TargetLineSingle.Visible = false
        for _, ln in ipairs(TargetLinePool) do ln.Visible = false end
        return
    end
    local color = Settings.Aim.TargetLineColor
    local thickness = Settings.Aim.TargetLineThickness
    local transp = Settings.Aim.TargetLineTransparency
    local style = Settings.Aim.TargetLineStyle

    if style == "Dashed" then
        TargetLineSingle.Visible = false
        local count = math.clamp(Settings.Aim.TargetLineDashCount, 2, 20)
        ensureTargetLinePool(count)
        local total = (screen - center)
        for i = 1, count do
            local ln = TargetLinePool[i]
            local a1 = (i - 1) / count
            local a2 = (i - 0.5) / count
            ln.From = center + total * a1
            ln.To   = center + total * a2
            ln.Color = color
            ln.Thickness = thickness
            ln.Transparency = transp
            ln.Visible = true
        end
    else
        for _, ln in ipairs(TargetLinePool) do ln.Visible = false end
        TargetLineSingle.From = center
        TargetLineSingle.To = screen
        TargetLineSingle.Color = color
        TargetLineSingle.Thickness = thickness
        TargetLineSingle.Transparency = transp
        TargetLineSingle.Visible = true
    end
end

--=====================================================================
-- AIM DEBUG VISUALS (всегда, без aim-key)
--=====================================================================
local DebugLine = newDrawing("Line")
local DebugDot = newDrawing("Circle")
DebugDot.NumSides = 24
DebugDot.Filled = true
DebugDot.Radius = 3

local DebugReactionText = newDrawing("Text")
DebugReactionText.Center = true
DebugReactionText.Outline = true
DebugReactionText.Size = 12

local lastTargetTime = 0
local lastReactionMs = 0

local function drawAimDebug()
    if not Settings.Aim.DebugVisuals or not Settings.Aim.Enabled then
        DebugLine.Visible = false
        DebugDot.Visible = false
        DebugReactionText.Visible = false
        return
    end

    -- Линия от камеры до цели (независимо от aim-key)
    local t = currentTarget
    if t then
        local model, part = resolveAimTarget(t)
        if part then
            local camPos = Camera.CFrame.Position
            local dest = part.Position
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
            local res = Workspace:Raycast(camPos, dest - camPos, params)
            local hitPos = res and res.Position or dest

            local fromScreen = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            local toScreen, on = worldToScreen(hitPos)
            if on then
                DebugLine.From = fromScreen
                DebugLine.To = toScreen
                DebugLine.Color = Color3.fromRGB(255, 220, 100)
                DebugLine.Thickness = 1
                DebugLine.Transparency = 0.4
                DebugLine.Visible = true

                DebugDot.Position = toScreen
                DebugDot.Color = Color3.fromRGB(255, 100, 100)
                DebugDot.Transparency = 0.2
                DebugDot.Visible = true

                -- Reaction time
                if lastTargetTime == 0 then
                    lastTargetTime = tick()
                end
                lastReactionMs = math.floor((tick() - lastTargetTime) * 1000)
                DebugReactionText.Text = string.format("%dms", lastReactionMs)
                DebugReactionText.Position = Vector2.new(toScreen.X, toScreen.Y - 15)
                DebugReactionText.Color = Color3.fromRGB(255, 255, 255)
                DebugReactionText.Visible = true
                return
            end
        end
    else
        lastTargetTime = 0
    end

    DebugLine.Visible = false
    DebugDot.Visible = false
    DebugReactionText.Visible = false
end

--=====================================================================
-- ITEM ESP (с выбором предметов через dropdown)
--=====================================================================
local ItemDrawings = {}
local ItemCache = {
    objects = {},
    lastRefresh = 0,
    uniqueNames = {},     -- [name] = true
    listChanged = false,  -- флаг: список изменился
}

local function newItemDrawingStruct()
    return { square = newDrawing("Square"), text = newDrawing("Text") }
end
local function destroyItemStruct(struct)
    pcall(function() struct.square:Remove() end)
    pcall(function() struct.text:Remove() end)
end

local function resolveFolderPath(pathStr)
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

local function findAnyBasePart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") or obj:IsA("Folder") then
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("BasePart") then return child end
        end
        for _, child in ipairs(obj:GetChildren()) do
            local bp = findAnyBasePart(child)
            if bp then return bp end
        end
    end
    return nil
end

local function getObjectPosition(obj)
    if obj:IsA("BasePart") then return obj.Position end
    local bp = findAnyBasePart(obj)
    if bp then return bp.Position end
    local ok, piv = pcall(function() return obj:GetPivot().Position end)
    if ok then return piv end
    return nil
end

-- Callback-хук: обновление списка имён предметов
local onItemListChanged = nil  -- устанавливается UI

local function refreshItemCache()
    local cache = ItemCache
    cache.objects = {}
    local namesSet = {}

    for _, path in ipairs(ITEM_ESP_PATHS) do
        local folder = resolveFolderPath(path)
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                table.insert(cache.objects, obj)
                namesSet[obj.Name] = true
            end
        end
    end

    -- Проверяем: появились ли новые имена?
    local changed = false
    for name in pairs(namesSet) do
        if not cache.uniqueNames[name] then
            changed = true
            cache.uniqueNames[name] = true
            -- авто-включить новый предмет
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
    if changed and onItemListChanged then
        onItemListChanged()
    end
end

local function isItemSelected(obj)
    return Settings.ItemESP.SelectedItems[obj.Name] == true
end

local function drawItemESP()
    if not Settings.ItemESP.Enabled then
        for inst, struct in pairs(ItemDrawings) do
            if typeof(inst) == "Instance" then
                struct.square.Visible = false
                struct.text.Visible = false
            end
        end
        return
    end

    -- периодический refresh кэша
    if tick() - ItemCache.lastRefresh > Settings.ItemESP.RefreshRate then
        refreshItemCache()
    end

    local drawings = ItemDrawings
    for inst, struct in pairs(drawings) do
        if type(inst) == "userdata" or (typeof(inst) == "Instance") then
            if not inst.Parent then
                destroyItemStruct(struct)
                drawings[inst] = nil
            end
        end
    end

    local camPos = Camera.CFrame.Position
    local color = Settings.ItemESP.Color
    local maxDist = Settings.ItemESP.MaxDistance
    local textEnabled = Settings.ItemESP.TextEnabled
    local seen = {}

    for _, obj in ipairs(ItemCache.objects) do
        if obj.Parent and isItemSelected(obj) then
            local pos = getObjectPosition(obj)
            if pos then
                local dist = (camPos - pos).Magnitude
                if dist <= maxDist then
                    local screen, on = worldToScreen(pos)
                    if on then
                        seen[obj] = true
                        local st = drawings[obj]
                        if not st then
                            st = newItemDrawingStruct()
                            drawings[obj] = st
                        end
                        st.square.Size = Vector2.new(8, 8)
                        st.square.Position = Vector2.new(screen.X - 4, screen.Y - 4)
                        st.square.Color = color
                        st.square.Thickness = 1
                        st.square.Filled = false
                        st.square.Visible = true
                        if textEnabled then
                            st.text.Text = obj.Name
                            st.text.Position = Vector2.new(screen.X, screen.Y + 8)
                            st.text.Color = color
                            st.text.Size = 11
                            st.text.Center = true
                            st.text.Outline = true
                            st.text.Visible = true
                        else
                            st.text.Visible = false
                        end
                    end
                end
            end
        end
    end

    for inst, struct in pairs(drawings) do
        if typeof(inst) == "Instance" then
            if not seen[inst] then
                struct.square.Visible = false
                struct.text.Visible = false
            end
        end
    end
end

--=====================================================================
-- AIMBOT
--=====================================================================
local currentTarget = nil
local stickyTarget  = nil
local prevSticky    = nil
local aimArrow = newDrawing("Triangle")
aimArrow.Visible = false; aimArrow.Filled = true

local fovCircle = newDrawing("Circle")
fovCircle.Thickness = 1; fovCircle.NumSides = 64
fovCircle.Filled = false; fovCircle.Transparency = 1
fovCircle.Color = Theme.Accent; fovCircle.Visible = false

local function getAimPartForModel(model)
    if not model then return nil end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local bone = Settings.Aim.Bone
    if bone == "Head" then
        return model:FindFirstChild("Head") or hrp
    elseif bone == "Torso" then
        return model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
            or model:FindFirstChild("Chest")
            or hrp
    else
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local bestPart, bestD = nil, math.huge
        local preferred = { Head = true, UpperTorso = true, Torso = true,
                            Chest = true, LowerTorso = true }
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                local sp, on = worldToScreen(p.CFrame.Position)
                if on then
                    local d = (sp - center).Magnitude
                    if not preferred[p.Name] then d = d + 10000 end
                    if d < bestD then bestD, bestPart = d, p end
                end
            end
        end
        return bestPart or hrp
    end
end

local function getAimPoint(part)
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
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
        local res = Workspace:Raycast(Camera.CFrame.Position, center - Camera.CFrame.Position, params)
        if res and res.Instance and res.Instance:IsDescendantOf(part.Parent) then
            return res.Position
        end
    end
    return center
end

local function resolveAimTarget(plr)
    local model = getCharacterForPlayer(plr)
    if not model then return nil end
    local part = getAimPartForModel(model)
    return model, part
end

-- Ground Only: проверяем что цель на земле
local function isOnGround(model)
    if not model then return true end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return true end
    -- Если FloorMaterial != Air, значит на земле
    if hum.FloorMaterial ~= Enum.Material.Air then return true end
    -- Проверим velocity по вертикали
    if math.abs(hrp.AssemblyLinearVelocity.Y) < 2 then return true end
    return false
end

local function getClosestTarget()
    local origin = getFOVOrigin()
    local myTeam = LocalPlayer.Team
    local keyDown = isAimKeyDown()
    if stickyTarget and keyDown then
        local model, part = resolveAimTarget(stickyTarget)
        if model and part then
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local sp, on = worldToScreen(part.CFrame.Position)
                if on then
                    local d = (sp - origin).Magnitude
                    if d <= Settings.Aim.FOV * Settings.Aim.StickyMultiplier then
                        if (not Settings.Aim.GroundOnly) or isOnGround(model) then
                            return stickyTarget
                        end
                    end
                end
            end
        end
        stickyTarget = nil
    end
    if not keyDown then stickyTarget = nil end
    local best, bestScore = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local skip = false
            if Settings.Aim.TeamCheck and plr.Team == myTeam and myTeam ~= nil then skip = true end
            if not skip then
                local model, part = resolveAimTarget(plr)
                if model and part then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        if (not Settings.Aim.GroundOnly) or isOnGround(model) then
                            local sp, on = worldToScreen(part.CFrame.Position)
                            if on then
                                local d = (sp - origin).Magnitude
                                if d <= Settings.Aim.FOV and d < bestScore then
                                    if (not Settings.Aim.WallCheck) or isVisibleFromCam(part, model) then
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
    if best and keyDown then stickyTarget = best end
    return best
end

local function aimAt(plr)
    local model, part = resolveAimTarget(plr)
    if not part then return end
    local targetPoint = getAimPoint(part)
    if not targetPoint then return end
    pcall(function()
        if Camera.CameraType ~= Enum.CameraType.Custom then
            Camera.CameraType = Enum.CameraType.Custom
        end
    end)
    local camPos = Camera.CFrame.Position
    local targetCF = CFrame.lookAt(camPos, targetPoint)
    if Settings.Aim.Instant then
        Camera.CFrame = targetCF
    else
        local alpha = math.clamp(Settings.Aim.Smoothness, 0.01, 1)
        alpha = applyCurve(alpha, Settings.Aim.SmoothCurve)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
    end
end

local function heartbeatAimbot()
    if not Settings.Aim.Enabled then
        currentTarget = nil; stickyTarget = nil
        return
    end
    local keyDown = isAimKeyDown()
    local t = getClosestTarget()
    if t and t ~= prevSticky and keyDown and Settings.Sound.TargetLockSound then
        playSound(Settings.Sound.TargetLockSoundId)
    end
    prevSticky = t
    currentTarget = t
    if keyDown and t then
        aimAt(t)
    end
end

local mouseLocked = false
local function setMouseLock(state)
    if state == mouseLocked then return end
    mouseLocked = state
    pcall(function()
        if state then
            UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        else
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)
end

local function drawAimVisuals(plrTarget)
    if Settings.Aim.ShowFOV and Settings.Aim.Enabled then
        local origin = getFOVOrigin()
        fovCircle.Position = origin
        fovCircle.Radius   = Settings.Aim.FOV
        fovCircle.Visible  = true
    else fovCircle.Visible = false end

    if plrTarget and Settings.Aim.Enabled then
        local model, part = resolveAimTarget(plrTarget)
        local worldPos = part and part.CFrame.Position
        if worldPos then
            local sp, on = worldToScreen(worldPos)
            if on then
                local origin = getFOVOrigin()
                local dir = (sp - origin)
                if dir.Magnitude < 1 then dir = Vector2.new(0, 1) end
                dir = dir.Unit * 40
                local perp = Vector2.new(-dir.Y, dir.X).Unit * 8
                aimArrow.PointA = origin + dir
                aimArrow.PointB = origin + perp
                aimArrow.PointC = origin - perp
                aimArrow.Color = Settings.ESP.ChamsTargetColor
                aimArrow.Filled = true; aimArrow.Visible = true
                return
            end
        end
    end
    aimArrow.Visible = false
end

--=====================================================================
-- HEAD MOVER
--=====================================================================
local headMoverConn = nil
local OriginalHeadCFrames = {}

local function restoreAllHeads()
    for head, cf in pairs(OriginalHeadCFrames) do
        if head and head.Parent then
            pcall(function() head.CFrame = cf end)
        end
    end
    OriginalHeadCFrames = {}
end

local function startHeadMover()
    if headMoverConn then headMoverConn:Disconnect() end
    headMoverConn = RunService.RenderStepped:Connect(function()
        if not Settings.Aim.HeadMover then restoreAllHeads(); return end
        if Settings.Aim.HeadMoverOnlyAimKey and not isAimKeyDown() then
            restoreAllHeads(); return
        end
        local targetPlr = currentTarget
        if not targetPlr or targetPlr == LocalPlayer then
            targetPlr = getClosestTarget()
        end
        if not targetPlr or targetPlr == LocalPlayer then
            restoreAllHeads(); return
        end
        local model = getCharacterForPlayer(targetPlr)
        if not model then restoreAllHeads(); return end
        if belongsToLocalPlayer(model) then restoreAllHeads(); return end
        local head = model:FindFirstChild("Head")
        if not head then restoreAllHeads(); return end
        if belongsToLocalPlayer(head) then restoreAllHeads(); return end
        local camCF = Camera.CFrame
        local dist = Settings.Aim.HeadMoverDistance
        local targetPoint = camCF.Position + camCF.LookVector * dist
        if not OriginalHeadCFrames[head] then
            OriginalHeadCFrames[head] = head.CFrame
        end
        local speed = math.clamp(Settings.Aim.HeadMoverSpeed, 0.05, 1)
        local desired = CFrame.new(targetPoint, camCF.Position)
        local newCF = head.CFrame:Lerp(desired, speed)
        pcall(function() head.CFrame = newCF end)
    end)
end

local function stopHeadMover()
    if headMoverConn then headMoverConn:Disconnect(); headMoverConn = nil end
    restoreAllHeads()
end

--=====================================================================
-- TRIGGERBOT
--=====================================================================
local lastTrigger = 0
local function updateTrigger()
    if not Settings.Trigger.Enabled then return end
    if Settings.Trigger.OnlyAimKey and not isAimKeyDown() then return end
    if tick() - lastTrigger < Settings.Trigger.Delay then return end
    local center = getFOVOrigin()
    local myTeam = LocalPlayer.Team
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local skip = false
            if Settings.Trigger.TeamCheck and plr.Team == myTeam and myTeam ~= nil then skip = true end
            if not skip then
                local model, part = resolveAimTarget(plr)
                if model and part then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local sp, on = worldToScreen(part.CFrame.Position)
                        if on then
                            local d = (sp - center).Magnitude
                            if d <= Settings.Aim.FOV then
                                if (not Settings.Trigger.WallCheck) or isVisibleFromCam(part, model) then
                                    lastTrigger = tick()
                                    pcall(function() mouse1click() end)
                                    pcall(function()
                                        VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
                                        task.wait(0.02)
                                        VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
                                    end)
                                    if Settings.Sound.KillSound then
                                        playSound(Settings.Sound.KillSoundId)
                                    end
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
-- ANTI-FLING
--=====================================================================
local antiFlingConn = nil
local function setAntiFling(state)
    if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn = nil end
    if not state then return end
    antiFlingConn = RunService.Heartbeat:Connect(function()
        local ch = LocalPlayer.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local vel = hrp.AssemblyLinearVelocity
        local maxV = 300
        if vel.Magnitude > maxV then
            hrp.AssemblyLinearVelocity = vel.Unit * maxV
        end
        pcall(function()
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
    end)
end

--=====================================================================
-- WORLD FUNCTIONS
--=====================================================================
local originalLighting = {
    Ambient = nil, OutdoorAmbient = nil, Brightness = nil,
    FogEnd = nil, FogStart = nil, ClockTime = nil, GlobalShadows = nil,
    EnvironmentDiffuseScale = nil, EnvironmentSpecularScale = nil,
}
local worldBackup = false

local function backupLighting()
    if worldBackup then return end
    originalLighting.Ambient = Lighting.Ambient
    originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
    originalLighting.Brightness = Lighting.Brightness
    originalLighting.FogEnd = Lighting.FogEnd
    originalLighting.FogStart = Lighting.FogStart
    originalLighting.ClockTime = Lighting.ClockTime
    originalLighting.GlobalShadows = Lighting.GlobalShadows
    originalLighting.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
    originalLighting.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
    worldBackup = true
end

local function applyWorld()
    local w = Settings.World
    if w.FullBright or w.NoFog or w.CustomTimeEnabled or w.CustomAmbientEnabled then
        backupLighting()
    end
end

-- Постоянное применение (каждый кадр)
local function keepWorldValues()
    local w = Settings.World

    if w.FullBright then
        if Lighting.Brightness ~= 2 then
            pcall(function() Lighting.Brightness = 2 end)
        end
        if Lighting.Ambient ~= Color3.fromRGB(178, 178, 178) then
            pcall(function()
                Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
            end)
        end
        if Lighting.GlobalShadows then
            pcall(function() Lighting.GlobalShadows = false end)
        end
        if Lighting.FogEnd ~= math.huge then
            pcall(function()
                Lighting.FogEnd = math.huge
                Lighting.FogStart = 0
            end)
        end
    end

    if w.NoFog then
        if Lighting.FogEnd ~= math.huge then
            pcall(function() Lighting.FogEnd = math.huge end)
        end
    end

    if w.CustomTimeEnabled then
        if math.abs(Lighting.ClockTime - w.CustomTime) > 0.05 then
            pcall(function() Lighting.ClockTime = w.CustomTime end)
        end
    end

    if w.CustomAmbientEnabled then
        if Lighting.Ambient ~= w.AmbientColor then
            pcall(function()
                Lighting.Ambient = w.AmbientColor
                Lighting.OutdoorAmbient = w.AmbientColor
            end)
        end
    end
end

-- Remove Grass
local grassConnection = nil
local function setRemoveGrass(state)
    if grassConnection then grassConnection:Disconnect(); grassConnection = nil end
    if not state then
        -- восстановить траву
        for _, obj in ipairs(Workspace.Terrain:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name == "_MixWareGrass" then
                pcall(function() obj:Destroy() end)
            end
        end
        return
    end
    -- Удаляем Decoration через Terrain
    grassConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            -- Terrain Decoration — не удалить напрямую. Убираем через Data.
            -- Прячем большие куски grass-моделей
            local terrain = Workspace.Terrain
            -- Отключаем decoration через Workspace.FallenPartsDestroyHeight
            -- Просто снижаем детализацию травы через SetMaterialColor
        end)
    end)
    -- Реальный способ: убрать Decoration Controllers в Workspace
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "Grass" or obj.Name == "grass" then
            obj.Transparency = 1
        end
    end
end

-- Простая имплементация Remove Grass — убираем Decoration и Terrain Decoration через Client
local function applyRemoveGrass()
    if Settings.World.RemoveGrass then
        pcall(function()
            Workspace.Terrain.Decoration = false
        end)
        -- Убираем партиклы травы если есть
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") and string.find(string.lower(obj.Parent.Name), "grass") then
                obj.Enabled = false
            end
        end
    end
end

local function keepCameraFOV()
    if Settings.World.CameraFOVEnabled then
        if math.abs(Camera.FieldOfView - Settings.World.CameraFOV) > 0.01 then
            pcall(function() Camera.FieldOfView = Settings.World.CameraFOV end)
        end
    end
end

--=====================================================================
-- MISC
--=====================================================================
local infJumpConn = nil
local function setInfJump(state)
    if infJumpConn then
        pcall(function() infJumpConn:Disconnect() end)
        infJumpConn = nil
    end
    if not state then return end
    infJumpConn = UIS.JumpRequest:Connect(function()
        local ch = LocalPlayer.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end

local tpwalkConn
local function setTPWalk(state)
    if tpwalkConn then tpwalkConn:Disconnect(); tpwalkConn = nil end
    if not state then return end
    tpwalkConn = RunService.Heartbeat:Connect(function()
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

local function applyWalkSpeed(v)
    local ch = LocalPlayer.Character
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end

local function applyJumpPower(v)
    local ch = LocalPlayer.Character
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = v end
    end
end

addConn(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applyWalkSpeed(Settings.Misc.WalkSpeed)
    applyJumpPower(Settings.Misc.JumpPower)
    if Settings.Misc.InfJump then setInfJump(true) end
    if Settings.Misc.TPWalkEnabled then setTPWalk(true) end
    if Settings.Misc.AntiFling then setAntiFling(true) end
end))

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

setupNotifyHolder(ScreenGui)

-- WATERMARK
local Watermark = Instance.new("Frame")
Watermark.Size = UDim2.new(0, 100, 0, 28)
Watermark.Position = UDim2.new(0, 15, 0, 15)
Watermark.BackgroundColor3 = Theme.Title
Watermark.BackgroundTransparency = 0.15
Watermark.BorderSizePixel = 0
Watermark.Visible = Settings.UI.Watermark
Watermark.AutomaticSize = Enum.AutomaticSize.X
Watermark.Parent = ScreenGui
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 8)
local WmStroke = Instance.new("UIStroke", Watermark)
WmStroke.Color = Theme.Accent; WmStroke.Thickness = 1; WmStroke.Transparency = 0.4
local WmPadding = Instance.new("UIPadding", Watermark)
WmPadding.PaddingLeft = UDim.new(0, 12); WmPadding.PaddingRight = UDim.new(0, 12)
local WmText = Instance.new("TextLabel")
WmText.Size = UDim2.new(0, 0, 1, 0)
WmText.BackgroundTransparency = 1
WmText.Text = "MixWare.lol"
WmText.TextColor3 = Theme.Text
WmText.Font = Enum.Font.GothamMedium
WmText.TextSize = 12
WmText.TextXAlignment = Enum.TextXAlignment.Left
WmText.AutomaticSize = Enum.AutomaticSize.X
WmText.Parent = Watermark

task.spawn(function()
    while ScreenGui.Parent do
        local fps = math.floor(1 / math.max(RunService.RenderStepped:Wait(), 1e-6))
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        local time = os.date("%H:%M:%S")
        local playerCount = #Players:GetPlayers()
        WmText.Text = string.format(
            "  MixWare.lol v2.6   |   Config: %s   |   %s   |   FPS %d   |   Ping %d   |   Players %d",
            ActiveConfigName, time, fps, ping, playerCount)
        task.wait(0.5)
    end
end)

--=====================================================================
-- INVENTORY PANEL
--=====================================================================
local InvPanel = Instance.new("Frame")
InvPanel.Size = UDim2.new(0, 280, 0, 260)
InvPanel.Position = UDim2.new(0.72, 0, 0.25, 0)
InvPanel.BackgroundColor3 = Theme.Bg
InvPanel.BackgroundTransparency = Settings.InvESP.Transparency
InvPanel.BorderSizePixel = 0
InvPanel.Active = true
InvPanel.Draggable = true
InvPanel.Visible = false
InvPanel.Parent = ScreenGui
Instance.new("UICorner", InvPanel).CornerRadius = UDim.new(0, 10)
local InvStroke = Instance.new("UIStroke", InvPanel)
InvStroke.Color = Theme.Accent; InvStroke.Thickness = 1; InvStroke.Transparency = 0.3

local InvHeader = Instance.new("TextLabel")
InvHeader.Size = UDim2.new(1, 0, 0, 28)
InvHeader.BackgroundColor3 = Theme.Title
InvHeader.BackgroundTransparency = 0.15
InvHeader.BorderSizePixel = 0
InvHeader.Text = "  Inventory ESP — нет цели"
InvHeader.TextColor3 = Theme.Text
InvHeader.Font = Enum.Font.GothamBold
InvHeader.TextSize = 13
InvHeader.TextXAlignment = Enum.TextXAlignment.Left
InvHeader.Parent = InvPanel
Instance.new("UICorner", InvHeader).CornerRadius = UDim.new(0, 10)

local HealthBarBg = Instance.new("Frame")
HealthBarBg.Size = UDim2.new(1, -12, 0, 6)
HealthBarBg.Position = UDim2.new(0, 6, 0, 32)
HealthBarBg.BackgroundColor3 = Color3.fromRGB(50, 40, 70)
HealthBarBg.BorderSizePixel = 0
HealthBarBg.Parent = InvPanel
Instance.new("UICorner", HealthBarBg).CornerRadius = UDim.new(1, 0)

local HealthBarFill = Instance.new("Frame")
HealthBarFill.Size = UDim2.new(0, 0, 1, 0)
HealthBarFill.BackgroundColor3 = Theme.Good
HealthBarFill.BorderSizePixel = 0
HealthBarFill.Parent = HealthBarBg
Instance.new("UICorner", HealthBarFill).CornerRadius = UDim.new(1, 0)

local InvSub = Instance.new("TextLabel")
InvSub.Size = UDim2.new(1, -12, 0, 16)
InvSub.Position = UDim2.new(0, 6, 0, 42)
InvSub.BackgroundTransparency = 1
InvSub.TextColor3 = Theme.TextDim
InvSub.Font = Enum.Font.Gotham
InvSub.TextSize = 12
InvSub.TextXAlignment = Enum.TextXAlignment.Left
InvSub.Parent = InvPanel

local InvList = Instance.new("ScrollingFrame")
InvList.Size = UDim2.new(1, -12, 1, -70)
InvList.Position = UDim2.new(0, 6, 0, 62)
InvList.BackgroundTransparency = 1
InvList.BorderSizePixel = 0
InvList.ScrollBarThickness = 4
InvList.CanvasSize = UDim2.new(0, 0, 0, 0)
InvList.AutomaticCanvasSize = Enum.AutomaticSize.Y
InvList.Parent = InvPanel
local InvListLayout = Instance.new("UIListLayout", InvList)
InvListLayout.Padding = UDim.new(0, 4)
InvListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local invItemRows = {}
local function clearInvList()
    for _, r in ipairs(invItemRows) do r:Destroy() end
    invItemRows = {}
end

local function gatherAllToolsForPlayer(plr)
    local seen, tools = {}, {}
    local function addItem(t)
        if t and not seen[t] then
            if t:IsA("Tool") or t:IsA("Model") or t:IsA("Accessory") then
                seen[t] = true
                table.insert(tools, t)
            end
        end
    end
    local ch = plr.Character
    if ch then
        for _, d in ipairs(ch:GetChildren()) do
            addItem(d)
        end
    end
    local bp = plr:FindFirstChild("Backpack")
    if not bp then
        local ok, cls = pcall(function() return plr:FindFirstChildOfClass("Backpack") end)
        if ok then bp = cls end
    end
    if bp then
        for _, d in ipairs(bp:GetChildren()) do
            addItem(d)
        end
    end
    if #tools == 0 then
        local pg = plr:FindFirstChild("PlayerGui")
        if pg then
            for _, d in ipairs(pg:GetDescendants()) do
                if d:IsA("Tool") then addItem(d) end
            end
        end
    end
    return tools
end

local function refreshInvList(tools)
    local needRebuild = (#tools ~= #invItemRows)
    if not needRebuild then
        for i, t in ipairs(tools) do
            local row = invItemRows[i]
            if not row or row:GetAttribute("ToolName") ~= t.Name then
                needRebuild = true; break
            end
        end
    end
    if needRebuild then
        clearInvList()
        for i, tool in ipairs(tools) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -4, 0, 22)
            row.BackgroundColor3 = Theme.Row
            row.BackgroundTransparency = 0.2
            row.BorderSizePixel = 0
            row.Parent = InvList
            row:SetAttribute("ToolName", tool.Name)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
            local dot = Instance.new("TextLabel")
            dot.Size = UDim2.new(0, 20, 1, 0); dot.Position = UDim2.new(0, 4, 0, 0)
            dot.BackgroundTransparency = 1; dot.Text = "•"
            dot.TextColor3 = Theme.Accent; dot.Font = Enum.Font.GothamBold
            dot.TextSize = 16; dot.Parent = row
            local name = Instance.new("TextLabel")
            name.Name = "ItemName"
            name.Size = UDim2.new(1, -30, 1, 0); name.Position = UDim2.new(0, 24, 0, 0)
            name.BackgroundTransparency = 1; name.Text = tool.Name
            name.TextColor3 = Theme.Text; name.Font = Enum.Font.Gotham
            name.TextSize = Settings.InvESP.FontSize
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.TextTruncate = Enum.TextTruncate.AtEnd
            name.Parent = row
            invItemRows[i] = row
        end
    else
        for _, row in ipairs(invItemRows) do row.ItemName.TextSize = Settings.InvESP.FontSize end
    end
end

local function findClosestPlayerForInv()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestScore = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer or Settings.InvESP.ShowLocal then
            local _, hrp = getCharacterForPlayer(plr)
            if hrp then
                local sp, on = worldToScreen(hrp.CFrame.Position)
                if on then
                    local d = (sp - center).Magnitude
                    if d < bestScore then bestScore, best = d, plr end
                end
            end
        end
    end
    return best
end

local lastInvRefresh = 0
local currentInvTarget = nil
local function updateInventoryESP()
    if not Settings.InvESP.Enabled then
        if InvPanel.Visible then InvPanel.Visible = false end
        return
    end
    InvPanel.Visible = true
    local now = tick()
    if now - lastInvRefresh < Settings.InvESP.RefreshInterval then return end
    lastInvRefresh = now
    local target = findClosestPlayerForInv()
    if not target then
        InvHeader.Text = "  Inventory ESP — нет цели"
        InvSub.Text = ""
        HealthBarFill.Size = UDim2.new(0, 0, 1, 0)
        if currentInvTarget ~= nil then currentInvTarget = nil; clearInvList() end
        return
    end
    currentInvTarget = target
    local _, hrp, hum = getCharacterForPlayer(target)
    if not hrp then return end
    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
    InvHeader.Text = "  " .. target.Name .. "  [" .. math.floor(dist) .. "m]"
    if hum and Settings.InvESP.ShowHealth then
        local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        HealthBarFill.Size = UDim2.new(hp, 0, 1, 0)
        local r = 1 - hp
        HealthBarFill.BackgroundColor3 = Color3.fromRGB(
            math.floor(60 + r * 180), math.floor(200 - r * 160), 100)
        InvSub.Text = string.format("HP: %d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))
    else
        HealthBarFill.Size = UDim2.new(0, 0, 1, 0); InvSub.Text = ""
    end
    if Settings.InvESP.ShowTools then
        local tools = gatherAllToolsForPlayer(target)
        refreshInvList(tools)
    else
        if #invItemRows > 0 then clearInvList() end
    end
end

--=====================================================================
-- UI REGISTRY
--=====================================================================
local UIRefs = {}
local function registerUI(path, applyFn) UIRefs[path] = { apply = applyFn } end
local function syncAllUI()
    for path, ref in pairs(UIRefs) do
        local v = getPath(path)
        if v ~= nil then pcall(function() ref.apply(v) end) end
    end
end

-- Main window
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 700, 0, 440)
Main.Position = UDim2.new(0.5, -350, 0.5, -220)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MainGrad = Instance.new("UIGradient", Main)
MainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Bg),
    ColorSequenceKeypoint.new(1, Theme.Bg2),
})
MainGrad.Rotation = 90
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Theme.Stroke; Stroke.Thickness = 1

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 34)
TitleBar.BackgroundColor3 = Theme.Title
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, 0, 0, 2)
TitleLine.Position = UDim2.new(0, 0, 1, -2)
TitleLine.BackgroundColor3 = Theme.Accent
TitleLine.BorderSizePixel = 0
TitleLine.Parent = TitleBar
local TitleGrad = Instance.new("UIGradient", TitleLine)
TitleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(1, Theme.Accent2),
})
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0); Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MixWare.lol  •  v2.6"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24); MinBtn.Position = UDim2.new(1, -60, 0, 5)
MinBtn.BackgroundColor3 = Theme.Panel
MinBtn.Text = "—"; MinBtn.TextColor3 = Theme.Text
MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 12
MinBtn.BorderSizePixel = 0; MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24); CloseBtn.Position = UDim2.new(1, -32, 0, 5)
CloseBtn.BackgroundColor3 = Theme.Bad
CloseBtn.Text = "X"; CloseBtn.TextColor3 = Theme.Text
CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 12
CloseBtn.BorderSizePixel = 0; CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local SearchBar = Instance.new("TextBox")
SearchBar.Size = UDim2.new(1, -20, 0, 24)
SearchBar.Position = UDim2.new(0, 10, 0, 40)
SearchBar.BackgroundColor3 = Theme.Panel
SearchBar.TextColor3 = Theme.Text
SearchBar.PlaceholderText = "Search..."
SearchBar.Text = ""
SearchBar.Font = Enum.Font.Gotham
SearchBar.TextSize = 12
SearchBar.BorderSizePixel = 0
SearchBar.ClearTextOnFocus = false
SearchBar.Parent = Main
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 6)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -110)
Sidebar.Position = UDim2.new(0, 10, 0, 72)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Main

local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -160, 1, -110)
ContentHolder.Position = UDim2.new(0, 150, 0, 72)
ContentHolder.BackgroundTransparency = 1
ContentHolder.Parent = Main

local tabButtons = {}
local tabPages   = {}

local function selectTab(name)
    for k, b in pairs(tabButtons) do
        if k == name then
            b.BackgroundColor3 = Theme.Accent
            b.TextColor3 = Color3.new(1,1,1)
        else
            b.BackgroundColor3 = Theme.Panel
            b.TextColor3 = Theme.TextDim
        end
    end
    for k, p in pairs(tabPages) do p.Visible = (k == name) end
end

local SideY = 0
local function makeCategoryHeader(text)
    local h = Instance.new("TextLabel")
    h.Size = UDim2.new(1, -8, 0, 20)
    h.Position = UDim2.new(0, 4, 0, SideY)
    h.BackgroundTransparency = 1
    h.Text = text
    h.TextColor3 = Theme.Accent2
    h.Font = Enum.Font.GothamBold
    h.TextSize = 11
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.Parent = Sidebar
    SideY = SideY + 22
end

local function makeSubButton(name)
    local btn = Instance.new("TextButton")
    btn.Position = UDim2.new(0, 4, 0, SideY)
    btn.Size = UDim2.new(1, -8, 0, 26)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    SideY = SideY + 28

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = ContentHolder
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    tabButtons[name] = btn
    tabPages[name] = page
    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    return page
end

makeCategoryHeader("COMBAT")
local AimPage = makeSubButton("AimBot")
local TrgPage = makeSubButton("Trigger")
SideY = SideY + 8
makeCategoryHeader("VISUALS")
local EnemiesPage   = makeSubButton("Enemies")
local ItemsPage     = makeSubButton("Items")
local InventoryPage = makeSubButton("Inventory")
local WorldPage     = makeSubButton("World")
local CrosshairPage = makeSubButton("Crosshair")
SideY = SideY + 8
makeCategoryHeader("MISC")
local MiscPage   = makeSubButton("Misc")
local ConfigPage = makeSubButton("Config")
local MenuPage   = makeSubButton("Menu")
selectTab("AimBot")

local function makeRow(parent, height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -8, 0, height or 28)
    f.BackgroundColor3 = Theme.Row
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    return f
end

local function makeToggle(parent, text, path, callback)
    local row = makeRow(parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    local state = getPath(path) and true or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20); btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = state and Theme.Good or Theme.Panel
    btn.Text = state and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local function applyVisual(v)
        state = v and true or false
        btn.BackgroundColor3 = state and Theme.Good or Theme.Panel
        btn.Text = state and "ON" or "OFF"
    end
    btn.MouseButton1Click:Connect(function()
        state = not state
        applyVisual(state)
        setPath(path, state)
        if callback then callback(state) end
    end)
    registerUI(path, function(v)
        applyVisual(v)
        if callback then callback(v) end
    end)
    return row
end

local function makeSlider(parent, text, min, max, path, callback)
    local row = makeRow(parent, 40)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18); lbl.Position = UDim2.new(0, 10, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    local initial = getPath(path) or min
    lbl.Text = text .. ": " .. tostring(initial)
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -20, 0, 8); barBg.Position = UDim2.new(0, 10, 0, 24)
    barBg.BackgroundColor3 = Theme.Panel; barBg.BorderSizePixel = 0
    barBg.Parent = row
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(math.clamp((initial - min)/(max-min), 0, 1), 0, 1, 0)
    barFill.BackgroundColor3 = Theme.Accent
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
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
    local function roundStep(v) return math.floor((v / step) + 0.5) * step end
    local function fmtNum(v)
        if step < 1 then
            local decimals = math.max(0, math.ceil(-math.log10(step)))
            return string.format("%." .. decimals .. "f", v)
        end
        return tostring(v)
    end
    local dragging = false
    local function applyVisual(v)
        local rel = math.clamp((v - min)/(max-min), 0, 1)
        barFill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = text .. ": " .. fmtNum(v)
    end
    local function setFromX(x)
        local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local v = min + (max - min) * rel
        v = roundStep(v)
        v = math.clamp(v, min, max)
        setPath(path, v)
        applyVisual(v)
        if callback then callback(v) end
    end
    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; setFromX(input.Position.X)
        end
    end)
    addConn(UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(input.Position.X)
        end
    end))
    addConn(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    registerUI(path, function(v)
        applyVisual(v)
        if callback then callback(v) end
    end)
    return row
end

local function makeButton(parent, text, callback)
    local row = makeRow(parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 1, -6); btn.Position = UDim2.new(0, 10, 0, 3)
    btn.BackgroundColor3 = Theme.Accent
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(callback)
    return row
end

local function makeColorPicker(parent, text, path, callback)
    local row = makeRow(parent, 40)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 18); lbl.Position = UDim2.new(0, 10, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    local initial = getPath(path) or Color3.fromRGB(255,255,255)
    local swatch = Instance.new("Frame")
    swatch.Size = UDim2.new(0, 40, 0, 20); swatch.Position = UDim2.new(1, -50, 0, 2)
    swatch.BackgroundColor3 = initial
    swatch.BorderSizePixel = 0
    swatch.Parent = row
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 5)
    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(0, 200, 0, 14); hueBar.Position = UDim2.new(0, 10, 0, 22)
    hueBar.BorderSizePixel = 0
    hueBar.Parent = row
    Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0, 3)
    local hueGrad = Instance.new("UIGradient", hueBar)
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
    })
    local marker = Instance.new("Frame")
    marker.Size = UDim2.new(0, 3, 1, 2); marker.Position = UDim2.new(0, 0, 0, -1)
    marker.BackgroundColor3 = Color3.new(1, 1, 1)
    marker.BorderSizePixel = 0
    marker.Parent = hueBar
    Instance.new("UICorner", marker).CornerRadius = UDim.new(0, 2)
    local h, s, v = Color3.toHSV(initial)
    local dragging = false
    local function applyVisual(color)
        local nh, ns, nv = Color3.toHSV(color)
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
        setPath(path, c)
        if callback then callback(c) end
    end
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; applyHue(input.Position.X)
        end
    end)
    addConn(UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            applyHue(input.Position.X)
        end
    end))
    addConn(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    marker.Position = UDim2.new(h, -1, 0, -1)
    swatch.BackgroundColor3 = Color3.fromHSV(h, s, v)
    registerUI(path, function(c)
        if typeof(c) == "Color3" then
            applyVisual(c)
            if callback then callback(c) end
        end
    end)
    return row
end

local function makeDropdown(parent, text, options, path, callback)
    local row = makeRow(parent, 32)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 120, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    local initial = getPath(path) or options[1]
    local current = initial
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 22); btn.Position = UDim2.new(1, -130, 0.5, -11)
    btn.BackgroundColor3 = Theme.Accent
    btn.Text = tostring(current)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham; btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local function applyVisual(v)
        current = v
        btn.Text = tostring(v)
    end
    btn.MouseButton1Click:Connect(function()
        local idx = table.find(options, current) or 1
        idx = idx % #options + 1
        current = options[idx]
        btn.Text = tostring(current)
        setPath(path, current)
        if callback then callback(current) end
    end)
    registerUI(path, function(v)
        applyVisual(v)
        if callback then callback(v) end
    end)
    return row
end

--=====================================================================
-- AIMBOT PAGE
--=====================================================================
makeToggle(AimPage, "AimBot Enabled", "Aim.Enabled")
makeSlider(AimPage, "FOV", 10, 500, "Aim.FOV")
makeToggle(AimPage, "Show FOV", "Aim.ShowFOV")
makeToggle(AimPage, "Instant Snap", "Aim.Instant")
makeSlider(AimPage, "Smoothness", 0.01, 1, "Aim.Smoothness")
makeDropdown(AimPage, "Smooth Curve", {"Linear", "EaseOut", "Sine"}, "Aim.SmoothCurve")
makeDropdown(AimPage, "Bone", {"Head", "Torso", "Nearest"}, "Aim.Bone")
makeToggle(AimPage, "Wall Check", "Aim.WallCheck")
makeToggle(AimPage, "Team Check", "Aim.TeamCheck")
makeToggle(AimPage, "Aim At Hit Point", "Aim.AimAtHitPoint")
makeToggle(AimPage, "Prediction", "Aim.Prediction")
makeSlider(AimPage, "Prediction Factor", 0.5, 3, "Aim.PredictionFactor")
makeSlider(AimPage, "Sticky Multiplier", 1, 4, "Aim.StickyMultiplier")
makeToggle(AimPage, "Ground Only", "Aim.GroundOnly")
makeToggle(AimPage, "Debug Visuals", "Aim.DebugVisuals")

makeToggle(AimPage, "Target Line", "Aim.TargetLine")
makeColorPicker(AimPage, "Target Line Color", "Aim.TargetLineColor")
makeSlider(AimPage, "Target Line Thickness", 1, 5, "Aim.TargetLineThickness")
makeSlider(AimPage, "Target Line Transparency", 0, 1, "Aim.TargetLineTransparency")
makeDropdown(AimPage, "Target Line Style", {"Solid", "Dashed"}, "Aim.TargetLineStyle")
makeSlider(AimPage, "Dash Count", 2, 20, "Aim.TargetLineDashCount")
makeToggle(AimPage, "Target Line Only When Aiming", "Aim.TargetLineOnlyAiming")

makeToggle(AimPage, "Head Mover (silent)", "Aim.HeadMover", function(v)
    if v then startHeadMover() else stopHeadMover() end
end)
makeSlider(AimPage, "Head Mover Distance", 5, 200, "Aim.HeadMoverDistance")
makeSlider(AimPage, "Head Mover Speed", 0.05, 1, "Aim.HeadMoverSpeed")
makeToggle(AimPage, "Head Mover Only When Aiming", "Aim.HeadMoverOnlyAimKey")

local keyRow = makeRow(AimPage)
local keyLbl = Instance.new("TextLabel")
keyLbl.Size = UDim2.new(1, -60, 1, 0); keyLbl.Position = UDim2.new(0, 10, 0, 0)
keyLbl.BackgroundTransparency = 1
keyLbl.Text = "Aim Key: " .. Settings.Aim.KeyName
keyLbl.TextColor3 = Theme.Text
keyLbl.Font = Enum.Font.Gotham; keyLbl.TextSize = 13
keyLbl.TextXAlignment = Enum.TextXAlignment.Left
keyLbl.Parent = keyRow
local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(0, 60, 0, 20); keyBtn.Position = UDim2.new(1, -70, 0.5, -10)
keyBtn.BackgroundColor3 = Theme.Panel
keyBtn.Text = "Set"; keyBtn.TextColor3 = Theme.Text
keyBtn.Font = Enum.Font.Gotham; keyBtn.TextSize = 11
keyBtn.BorderSizePixel = 0; keyBtn.Parent = keyRow
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
        notify("Aim Key set to " .. Settings.Aim.KeyName)
    end)
end)
registerUI("Aim.KeyName", function(v) keyLbl.Text = "Aim Key: " .. tostring(v) end)

--=====================================================================
-- TRIGGER PAGE
--=====================================================================
makeToggle(TrgPage, "TriggerBot Enabled", "Trigger.Enabled")
makeSlider(TrgPage, "Delay", 0.01, 1, "Trigger.Delay")
makeToggle(TrgPage, "Team Check", "Trigger.TeamCheck")
makeToggle(TrgPage, "Wall Check", "Trigger.WallCheck")
makeToggle(TrgPage, "Only When Aim Key Down", "Trigger.OnlyAimKey")

--=====================================================================
-- ENEMIES PAGE
--=====================================================================
makeToggle(EnemiesPage, "ESP Master Toggle", "ESP.Enabled", function(v)
    if not v then for _, d in pairs(ESPData) do hideAllESP(d) end end
end)
makeToggle(EnemiesPage, "Chams (Highlight)", "ESP.ChamsEnabled")
makeColorPicker(EnemiesPage, "Chams Color", "ESP.ChamsColor")
makeColorPicker(EnemiesPage, "Chams Target Color", "ESP.ChamsTargetColor")
makeSlider(EnemiesPage, "Chams Transparency", 0, 1, "ESP.ChamsTransp")
makeToggle(EnemiesPage, "Box ESP", "ESP.BoxEnabled")
makeColorPicker(EnemiesPage, "Box Color", "ESP.BoxColor")
makeSlider(EnemiesPage, "Box Thickness", 1, 5, "ESP.BoxThickness")
makeToggle(EnemiesPage, "Corner ESP", "ESP.CornerEnabled")
makeColorPicker(EnemiesPage, "Corner Color", "ESP.CornerColor")
makeSlider(EnemiesPage, "Corner Length", 4, 40, "ESP.CornerLength")
makeSlider(EnemiesPage, "Corner Thickness", 1, 4, "ESP.CornerThickness")
makeToggle(EnemiesPage, "3D Box ESP", "ESP.Box3DEnabled")
makeColorPicker(EnemiesPage, "3D Box Color", "ESP.Box3DColor")
makeToggle(EnemiesPage, "Tracers", "ESP.TracerEnabled")
makeColorPicker(EnemiesPage, "Tracer Color", "ESP.TracerColor")
makeDropdown(EnemiesPage, "Tracer Origin", {"Top", "Center", "Bottom"}, "ESP.TracerOrigin")
makeToggle(EnemiesPage, "Show Name", "ESP.NameEnabled")
makeToggle(EnemiesPage, "Name Shadow", "ESP.NameShadow")
makeToggle(EnemiesPage, "Show Distance", "ESP.DistanceEnabled")
makeSlider(EnemiesPage, "Max Distance", 50, 3000, "ESP.MaxDistance")
makeToggle(EnemiesPage, "Visible Check", "ESP.VisibleCheck")
makeColorPicker(EnemiesPage, "Visible Color", "ESP.VisibleColor")
makeToggle(EnemiesPage, "Behind-Wall Pulse", "ESP.PulseEnabled")
makeSlider(EnemiesPage, "Pulse Speed", 0.5, 3, "ESP.PulseSpeed")
makeSlider(EnemiesPage, "Pulse Min Alpha", 0.1, 0.9, "ESP.PulseMin")
makeSlider(EnemiesPage, "Pulse Max Alpha", 0.1, 1, "ESP.PulseMax")
makeToggle(EnemiesPage, "Skeleton ESP", "ESP.SkeletonEnabled")
makeColorPicker(EnemiesPage, "Skeleton Color", "ESP.SkeletonColor")
makeSlider(EnemiesPage, "Skeleton Thickness", 1, 4, "ESP.SkeletonThickness")
makeToggle(EnemiesPage, "Health Bar", "ESP.HealthBarEnabled")
makeSlider(EnemiesPage, "Health Bar Width", 2, 12, "ESP.HealthBarWidth")
makeSlider(EnemiesPage, "Health Bar Offset", 2, 20, "ESP.HealthBarOffset")
makeToggle(EnemiesPage, "Custom Nametags", "ESP.NametagsEnabled")
makeToggle(EnemiesPage, "Nametag HP", "ESP.NametagsShowHP")
makeToggle(EnemiesPage, "Nametag Distance", "ESP.NametagsShowDist")
makeToggle(EnemiesPage, "Off-screen Arrows", "ESP.ArrowsEnabled")
makeColorPicker(EnemiesPage, "Arrows Color", "ESP.ArrowsColor")
makeSlider(EnemiesPage, "Arrows Size", 8, 24, "ESP.ArrowsSize")
makeToggle(EnemiesPage, "Weapon Name", "ESP.WeaponNameEnabled")
makeColorPicker(EnemiesPage, "Weapon Name Color", "ESP.WeaponNameColor")
makeSlider(EnemiesPage, "Weapon Name Size", 8, 20, "ESP.WeaponNameSize")
makeToggle(EnemiesPage, "Distance Fade", "ESP.DistanceFade")
makeSlider(EnemiesPage, "Fade Start %", 0.1, 1, "ESP.DistanceFadeStart")

--=====================================================================
-- CROSSHAIR PAGE
--=====================================================================
makeToggle(CrosshairPage, "Crosshair Enabled", "Crosshair.Enabled")
makeDropdown(CrosshairPage, "Style", {"Cross", "Crosshair", "Circle", "Dot", "Sun"}, "Crosshair.Style")
makeColorPicker(CrosshairPage, "Color", "Crosshair.Color")
makeToggle(CrosshairPage, "Rainbow", "Crosshair.Rainbow")
makeColorPicker(CrosshairPage, "Outline Color", "Crosshair.OutlineColor")
makeToggle(CrosshairPage, "Outline", "Crosshair.Outline")
makeSlider(CrosshairPage, "Gap", 0, 20, "Crosshair.Gap")
makeSlider(CrosshairPage, "Length", 2, 30, "Crosshair.Length")
makeSlider(CrosshairPage, "Thickness", 1, 5, "Crosshair.Thickness")
makeSlider(CrosshairPage, "Circle Radius", 4, 40, "Crosshair.CircleRadius")
makeToggle(CrosshairPage, "Dot", "Crosshair.Dot")
makeSlider(CrosshairPage, "Dot Size", 1, 8, "Crosshair.DotSize")

--=====================================================================
-- ITEMS PAGE (dropdown с чекбоксами)
--=====================================================================
makeToggle(ItemsPage, "Item ESP", "ItemESP.Enabled")
makeColorPicker(ItemsPage, "Item Color", "ItemESP.Color")
makeSlider(ItemsPage, "Max Distance", 50, 2000, "ItemESP.MaxDistance")
makeToggle(ItemsPage, "Show Text", "ItemESP.TextEnabled")
makeSlider(ItemsPage, "Refresh Rate", 0.05, 1, "ItemESP.RefreshRate")

-- Dropdown с чекбоксами
local itemSelectorRow = makeRow(ItemsPage, 32)
local itemSelectorLbl = Instance.new("TextLabel")
itemSelectorLbl.Size = UDim2.new(0, 130, 1, 0); itemSelectorLbl.Position = UDim2.new(0, 10, 0, 0)
itemSelectorLbl.BackgroundTransparency = 1
itemSelectorLbl.Text = "Selected Items:"
itemSelectorLbl.TextColor3 = Theme.Text
itemSelectorLbl.Font = Enum.Font.Gotham; itemSelectorLbl.TextSize = 13
itemSelectorLbl.TextXAlignment = Enum.TextXAlignment.Left
itemSelectorLbl.Parent = itemSelectorRow

local itemSelectorBtn = Instance.new("TextButton")
itemSelectorBtn.Size = UDim2.new(0, 120, 0, 22); itemSelectorBtn.Position = UDim2.new(1, -130, 0.5, -11)
itemSelectorBtn.BackgroundColor3 = Theme.Accent
itemSelectorBtn.Text = "0 selected"
itemSelectorBtn.TextColor3 = Color3.fromRGB(255,255,255)
itemSelectorBtn.Font = Enum.Font.Gotham; itemSelectorBtn.TextSize = 12
itemSelectorBtn.BorderSizePixel = 0
itemSelectorBtn.Parent = itemSelectorRow
Instance.new("UICorner", itemSelectorBtn).CornerRadius = UDim.new(0, 5)

-- Popup со списком
local itemPopup = Instance.new("Frame")
itemPopup.Size = UDim2.new(0, 300, 0, 240)
itemPopup.Position = UDim2.new(0.5, -150, 0.5, -120)
itemPopup.BackgroundColor3 = Theme.Bg
itemPopup.BorderSizePixel = 0
itemPopup.Visible = false
itemPopup.ZIndex = 10
itemPopup.Parent = ScreenGui
Instance.new("UICorner", itemPopup).CornerRadius = UDim.new(0, 10)
local popupStroke = Instance.new("UIStroke", itemPopup)
popupStroke.Color = Theme.Accent; popupStroke.Thickness = 1

local popupTitle = Instance.new("TextLabel")
popupTitle.Size = UDim2.new(1, -60, 0, 26); popupTitle.Position = UDim2.new(0, 10, 0, 4)
popupTitle.BackgroundTransparency = 1
popupTitle.Text = "Select Items to Show:"
popupTitle.TextColor3 = Theme.Text
popupTitle.Font = Enum.Font.GothamBold; popupTitle.TextSize = 12
popupTitle.TextXAlignment = Enum.TextXAlignment.Left
popupTitle.Parent = itemPopup

local popupClose = Instance.new("TextButton")
popupClose.Size = UDim2.new(0, 24, 0, 24); popupClose.Position = UDim2.new(1, -30, 0, 4)
popupClose.BackgroundColor3 = Theme.Bad
popupClose.Text = "X"; popupClose.TextColor3 = Theme.Text
popupClose.Font = Enum.Font.GothamBold; popupClose.TextSize = 12
popupClose.BorderSizePixel = 0
popupClose.Parent = itemPopup
Instance.new("UICorner", popupClose).CornerRadius = UDim.new(0, 5)

local popupScroll = Instance.new("ScrollingFrame")
popupScroll.Size = UDim2.new(1, -20, 1, -70); popupScroll.Position = UDim2.new(0, 10, 0, 34)
popupScroll.BackgroundTransparency = 1
popupScroll.BorderSizePixel = 0
popupScroll.ScrollBarThickness = 4
popupScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
popupScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
popupScroll.Parent = itemPopup
local popupLayout = Instance.new("UIListLayout", popupScroll)
popupLayout.Padding = UDim.new(0, 4)
popupLayout.SortOrder = Enum.SortOrder.LayoutOrder

local popupButtons = {}
local function rebuildPopupList()
    for _, btn in ipairs(popupButtons) do btn:Destroy() end
    popupButtons = {}

    local names = {}
    for name in pairs(ItemCache.uniqueNames) do table.insert(names, name) end
    table.sort(names)

    for _, name in ipairs(names) do
        local cbRow = Instance.new("Frame")
        cbRow.Size = UDim2.new(1, -4, 0, 22)
        cbRow.BackgroundColor3 = Theme.Row
        cbRow.BackgroundTransparency = 0.2
        cbRow.BorderSizePixel = 0
        cbRow.Parent = popupScroll
        Instance.new("UICorner", cbRow).CornerRadius = UDim.new(0, 5)

        local cb = Instance.new("TextButton")
        cb.Size = UDim2.new(0, 18, 0, 18); cb.Position = UDim2.new(0, 4, 0.5, -9)
        local isSelected = Settings.ItemESP.SelectedItems[name] == true
        cb.BackgroundColor3 = isSelected and Theme.Good or Theme.Panel
        cb.Text = isSelected and "✓" or ""
        cb.TextColor3 = Color3.fromRGB(255,255,255)
        cb.Font = Enum.Font.GothamBold; cb.TextSize = 13
        cb.BorderSizePixel = 0
        cb.Parent = cbRow
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)

        local nl = Instance.new("TextLabel")
        nl.Size = UDim2.new(1, -30, 1, 0); nl.Position = UDim2.new(0, 26, 0, 0)
        nl.BackgroundTransparency = 1
        nl.Text = name
        nl.TextColor3 = Theme.Text
        nl.Font = Enum.Font.Gotham; nl.TextSize = 12
        nl.TextXAlignment = Enum.TextXAlignment.Left
        nl.Parent = cbRow

        cb.MouseButton1Click:Connect(function()
            local sel = Settings.ItemESP.SelectedItems[name] == true
            Settings.ItemESP.SelectedItems[name] = not sel
            cb.BackgroundColor3 = (not sel) and Theme.Good or Theme.Panel
            cb.Text = (not sel) and "✓" or ""
            -- счётчик
            local count = 0
            for _, v in pairs(Settings.ItemESP.SelectedItems) do
                if v then count = count + 1 end
            end
            itemSelectorBtn.Text = count .. " selected"
        end)

        table.insert(popupButtons, cbRow)
    end

    -- обновить счётчик
    local count = 0
    for _, v in pairs(Settings.ItemESP.SelectedItems) do
        if v then count = count + 1 end
    end
    itemSelectorBtn.Text = count .. " selected"
end

itemSelectorBtn.MouseButton1Click:Connect(function()
    itemPopup.Visible = not itemPopup.Visible
    if itemPopup.Visible then rebuildPopupList() end
end)
popupClose.MouseButton1Click:Connect(function() itemPopup.Visible = false end)

-- Хук: обновление списка при появлении новых имён
onItemListChanged = function()
    if itemPopup.Visible then rebuildPopupList() end
end

--=====================================================================
-- INVENTORY PAGE
--=====================================================================
makeToggle(InventoryPage, "Inventory ESP", "InvESP.Enabled", function(v)
    InvPanel.Visible = v
end)
makeSlider(InventoryPage, "Transparency", 0, 1, "InvESP.Transparency", function(v)
    InvPanel.BackgroundTransparency = v
end)
makeSlider(InventoryPage, "Font Size", 10, 22, "InvESP.FontSize", function(v)
    for _, r in ipairs(invItemRows) do r.ItemName.TextSize = v end
end)
makeSlider(InventoryPage, "Refresh Interval", 0.05, 2, "InvESP.RefreshInterval")
makeToggle(InventoryPage, "Show Local Player", "InvESP.ShowLocal")
makeToggle(InventoryPage, "Show Health Bar", "InvESP.ShowHealth")
makeToggle(InventoryPage, "Show Tools", "InvESP.ShowTools")
makeButton(InventoryPage, "Reset Panel Position", function()
    InvPanel.Position = UDim2.new(0.72, 0, 0.25, 0)
end)

--=====================================================================
-- WORLD PAGE
--=====================================================================
makeToggle(WorldPage, "World ESP", "WorldESP.Enabled")
makeColorPicker(WorldPage, "World Color", "WorldESP.Color")
makeSlider(WorldPage, "Max Distance", 50, 2000, "WorldESP.MaxDistance")
makeToggle(WorldPage, "Show Text", "WorldESP.TextEnabled")
makeToggle(WorldPage, "FullBright", "World.FullBright")
makeToggle(WorldPage, "No Fog", "World.NoFog")
makeToggle(WorldPage, "Custom Time of Day", "World.CustomTimeEnabled")
makeSlider(WorldPage, "Time", 0, 24, "World.CustomTime")
makeToggle(WorldPage, "Custom Ambient", "World.CustomAmbientEnabled")
makeColorPicker(WorldPage, "Ambient Color", "World.AmbientColor")
makeToggle(WorldPage, "Disable Sun Rays", "World.DisableSunRays")
makeToggle(WorldPage, "Disable Atmosphere", "World.DisableAtmosphere")
makeToggle(WorldPage, "Remove Grass", "World.RemoveGrass", function(v)
    applyRemoveGrass()
end)
makeToggle(WorldPage, "Custom Camera FOV", "World.CameraFOVEnabled")
makeSlider(WorldPage, "Camera FOV", 30, 120, "World.CameraFOV")

--=====================================================================
-- MISC PAGE
--=====================================================================
makeToggle(MiscPage, "TPWalk", "Misc.TPWalkEnabled", function(v) setTPWalk(v) end)
makeSlider(MiscPage, "TPWalk Speed", 1, 200, "Misc.TPWalkSpeed")
makeToggle(MiscPage, "Infinite Jump", "Misc.InfJump", function(v) setInfJump(v) end)
makeSlider(MiscPage, "WalkSpeed", 1, 500, "Misc.WalkSpeed", function(v) applyWalkSpeed(v) end)
makeSlider(MiscPage, "JumpPower", 1, 500, "Misc.JumpPower", function(v) applyJumpPower(v) end)
makeToggle(MiscPage, "Anti-Fling", "Misc.AntiFling", function(v) setAntiFling(v) end)
makeToggle(MiscPage, "Kill Sound", "Sound.KillSound")
makeToggle(MiscPage, "Target Lock Sound", "Sound.TargetLockSound")
makeButton(MiscPage, "Загрузить Infinite Yield (source)", function()
    pcall(function()
        local src = game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
        getgenv().IY_Source = src
    end)
    notify("IY source загружен")
end)

--=====================================================================
-- CONFIG PAGE
--=====================================================================
local CONFIG_FOLDER = "MixWare_Configs"
local LAST_FILE = CONFIG_FOLDER .. "/_last.txt"
local hasFileAPI = (writefile and readfile and isfolder and makefolder and listfiles and delfile) and true or false
local memStore = {}
local memLast = nil

local function ensureFolder()
    if not hasFileAPI then return end
    pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
    end)
end

local function listConfigs()
    ensureFolder()
    if hasFileAPI then
        local ok, files = pcall(function() return listfiles(CONFIG_FOLDER) end)
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
    for k in pairs(memStore) do table.insert(names, k) end
    return names
end

local function saveLastConfigName(name)
    if hasFileAPI then
        ensureFolder()
        pcall(function() writefile(LAST_FILE, name) end)
    else
        memLast = name
    end
    ActiveConfigName = name
end

local function getLastConfigName()
    if hasFileAPI and isfile and isfile(LAST_FILE) then
        local ok, res = pcall(function() return readfile(LAST_FILE) end)
        if ok and res and res ~= "" then return res end
    end
    return memLast
end

local function saveConfig(name)
    if not name or name == "" then return false end
    local data = HttpService:JSONEncode(serializeSettings(Settings))
    if hasFileAPI then
        ensureFolder()
        return pcall(function()
            writefile(CONFIG_FOLDER .. "/" .. name .. ".json", data)
        end)
    else
        memStore[name] = data
        return true
    end
end

local function loadConfig(name, silent)
    if not name or name == "" then return false end
    local data
    if hasFileAPI then
        ensureFolder()
        local ok, res = pcall(function()
            return readfile(CONFIG_FOLDER .. "/" .. name .. ".json")
        end)
        if ok and res then data = res end
    else
        data = memStore[name]
    end
    if not data then return false end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(data) end)
    if not ok or type(decoded) ~= "table" then return false end
    deserializeSettings(Settings, decoded)
    ActiveConfigName = name
    syncAllUI()
    if Settings.Misc.AntiFling then setAntiFling(true) else setAntiFling(false) end
    if Settings.Misc.TPWalkEnabled then setTPWalk(true) else setTPWalk(false) end
    if Settings.Misc.InfJump then setInfJump(true) else setInfJump(false) end
    if Settings.Aim.HeadMover then startHeadMover() else stopHeadMover() end
    if not silent then notify("Loaded config: " .. name, Theme.Good) end
    return true
end

local function deleteConfig(name)
    if not name or name == "" then return false end
    if hasFileAPI then
        return pcall(function() delfile(CONFIG_FOLDER .. "/" .. name .. ".json") end)
    else
        memStore[name] = nil
        return true
    end
end

local cfgNameRow = makeRow(ConfigPage, 32)
local cfgNameBox = Instance.new("TextBox")
cfgNameBox.Size = UDim2.new(1, -20, 1, -6); cfgNameBox.Position = UDim2.new(0, 10, 0, 3)
cfgNameBox.BackgroundColor3 = Theme.Panel
cfgNameBox.TextColor3 = Theme.Text
cfgNameBox.PlaceholderText = "Имя конфига..."
cfgNameBox.Text = ""
cfgNameBox.Font = Enum.Font.Gotham
cfgNameBox.TextSize = 13
cfgNameBox.BorderSizePixel = 0
cfgNameBox.Parent = cfgNameRow
Instance.new("UICorner", cfgNameBox).CornerRadius = UDim.new(0, 5)

local cfgListRow = makeRow(ConfigPage, 140)
local cfgList = Instance.new("ScrollingFrame")
cfgList.Size = UDim2.new(1, -10, 1, -6); cfgList.Position = UDim2.new(0, 5, 0, 3)
cfgList.BackgroundTransparency = 1
cfgList.BorderSizePixel = 0
cfgList.ScrollBarThickness = 4
cfgList.CanvasSize = UDim2.new(0, 0, 0, 0)
cfgList.AutomaticCanvasSize = Enum.AutomaticSize.Y
cfgList.Parent = cfgListRow
local cfgListLayout = Instance.new("UIListLayout", cfgList)
cfgListLayout.Padding = UDim.new(0, 3)
cfgListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local cfgRows = {}
local function rebuildConfigList()
    for _, r in ipairs(cfgRows) do r:Destroy() end
    cfgRows = {}
    local names = listConfigs()
    table.sort(names)
    for _, name in ipairs(names) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 22)
        row.BackgroundColor3 = Theme.Row
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        row.Parent = cfgList
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
        local lbl = Instance.new("TextButton")
        lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.new(0, 6, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name; lbl.TextColor3 = Theme.Text
        lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row
        lbl.MouseButton1Click:Connect(function() cfgNameBox.Text = name end)
        local loadBtn = Instance.new("TextButton")
        loadBtn.Size = UDim2.new(0, 24, 0, 18); loadBtn.Position = UDim2.new(1, -56, 0.5, -9)
        loadBtn.BackgroundColor3 = Theme.Good
        loadBtn.Text = "L"; loadBtn.TextColor3 = Color3.new(1,1,1)
        loadBtn.Font = Enum.Font.GothamBold; loadBtn.TextSize = 11
        loadBtn.BorderSizePixel = 0
        loadBtn.Parent = row
        Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 4)
        loadBtn.MouseButton1Click:Connect(function()
            loadConfig(name)
            saveLastConfigName(name)
        end)
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 24, 0, 18); delBtn.Position = UDim2.new(1, -28, 0.5, -9)
        delBtn.BackgroundColor3 = Theme.Bad
        delBtn.Text = "X"; delBtn.TextColor3 = Color3.new(1,1,1)
        delBtn.Font = Enum.Font.GothamBold; delBtn.TextSize = 11
        delBtn.BorderSizePixel = 0
        delBtn.Parent = row
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
        delBtn.MouseButton1Click:Connect(function()
            deleteConfig(name); rebuildConfigList()
        end)
        table.insert(cfgRows, row)
    end
end

makeButton(ConfigPage, "Save Current Config", function()
    local n = cfgNameBox.Text
    if n and n ~= "" then
        saveConfig(n)
        saveLastConfigName(n)
        rebuildConfigList()
        notify("Saved config: " .. n, Theme.Good)
    end
end)
makeButton(ConfigPage, "Load Config", function()
    local n = cfgNameBox.Text
    if n and n ~= "" then
        loadConfig(n)
        saveLastConfigName(n)
    end
end)
makeButton(ConfigPage, "Refresh List", function() rebuildConfigList() end)
makeButton(ConfigPage, "Clear Last Config", function()
    if hasFileAPI then
        pcall(function() delfile(LAST_FILE) end)
    else
        memLast = nil
    end
    ActiveConfigName = "none"
    notify("Last config cleared", Theme.Bad)
end)

rebuildConfigList()

--=====================================================================
-- MENU PAGE (темы + масштаб)
--=====================================================================
makeToggle(MenuPage, "Watermark", "UI.Watermark", function(v) Watermark.Visible = v end)
makeToggle(MenuPage, "Notifications", "UI.Notifications")

-- Тема
local themeRow = makeRow(MenuPage, 32)
local themeLbl = Instance.new("TextLabel")
themeLbl.Size = UDim2.new(0, 120, 1, 0); themeLbl.Position = UDim2.new(0, 10, 0, 0)
themeLbl.BackgroundTransparency = 1
themeLbl.Text = "Theme:"
themeLbl.TextColor3 = Theme.Text
themeLbl.Font = Enum.Font.Gotham; themeLbl.TextSize = 13
themeLbl.TextXAlignment = Enum.TextXAlignment.Left
themeLbl.Parent = themeRow
local themeBtn = Instance.new("TextButton")
themeBtn.Size = UDim2.new(0, 120, 0, 22); themeBtn.Position = UDim2.new(1, -130, 0.5, -11)
themeBtn.BackgroundColor3 = Theme.Accent
themeBtn.Text = Settings.UI.Theme
themeBtn.TextColor3 = Color3.fromRGB(255,255,255)
themeBtn.Font = Enum.Font.Gotham; themeBtn.TextSize = 12
themeBtn.BorderSizePixel = 0
themeBtn.Parent = themeRow
Instance.new("UICorner", themeBtn).CornerRadius = UDim.new(0, 5)

-- Масштаб
local scaleRow = makeRow(MenuPage, 32)
local scaleLbl = Instance.new("TextLabel")
scaleLbl.Size = UDim2.new(0, 120, 1, 0); scaleLbl.Position = UDim2.new(0, 10, 0, 0)
scaleLbl.BackgroundTransparency = 1
scaleLbl.Text = "UI Scale:"
scaleLbl.TextColor3 = Theme.Text
scaleLbl.Font = Enum.Font.Gotham; scaleLbl.TextSize = 13
scaleLbl.TextXAlignment = Enum.TextXAlignment.Left
scaleLbl.Parent = scaleRow
local scaleBtn = Instance.new("TextButton")
scaleBtn.Size = UDim2.new(0, 120, 0, 22); scaleBtn.Position = UDim2.new(1, -130, 0.5, -11)
scaleBtn.BackgroundColor3 = Theme.Accent
scaleBtn.Text = Settings.UI.Scale
scaleBtn.TextColor3 = Color3.fromRGB(255,255,255)
scaleBtn.Font = Enum.Font.Gotham; scaleBtn.TextSize = 12
scaleBtn.BorderSizePixel = 0
scaleBtn.Parent = scaleRow
Instance.new("UICorner", scaleBtn).CornerRadius = UDim.new(0, 5)

local themeOrder = {"Purple", "Dark", "Blue", "Red", "Pink"}
local scaleOrder = {"Small", "Medium", "Large"}
local scaleValues = {Small = 0.85, Medium = 1.0, Large = 1.15}

local function applyTheme(name)
    local t = Themes[name]
    if not t then return end
    Theme = t
    Settings.UI.Theme = name
    themeBtn.Text = name

    -- Применить к UI
    Main.BackgroundColor3 = Theme.Bg
    MainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Bg),
        ColorSequenceKeypoint.new(1, Theme.Bg2),
    })
    Stroke.Color = Theme.Stroke
    TitleBar.BackgroundColor3 = Theme.Title
    TitleLine.BackgroundColor3 = Theme.Accent
    Title.TextColor3 = Theme.Text
    SearchBar.BackgroundColor3 = Theme.Panel
    SearchBar.TextColor3 = Theme.Text
    -- tab buttons, rows — обновляем через syncAllUI нельзя, они свои цвета имеют.
    -- Просто перекрасим боковые кнопки и заголовки категорий
    for _, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = Theme.Panel
        btn.TextColor3 = Theme.TextDim
    end
    for _, obj in ipairs(Sidebar:GetChildren()) do
        if obj:IsA("TextLabel") then obj.TextColor3 = Theme.Accent2 end
    end
    -- активировать текущий таб
    local activeName
    for k, p in pairs(tabPages) do
        if p.Visible then activeName = k break end
    end
    if activeName then selectTab(activeName) end
end

local function applyScale(name)
    local s = scaleValues[name] or 1.0
    Settings.UI.Scale = name
    scaleBtn.Text = name
    Main.Size = UDim2.new(0, 700 * s, 0, 440 * s)
    Main.Position = UDim2.new(0.5, -350 * s, 0.5, -220 * s)
end

themeBtn.MouseButton1Click:Connect(function()
    local idx = table.find(themeOrder, Settings.UI.Theme) or 1
    idx = idx % #themeOrder + 1
    applyTheme(themeOrder[idx])
end)
scaleBtn.MouseButton1Click:Connect(function()
    local idx = table.find(scaleOrder, Settings.UI.Scale) or 1
    idx = idx % #scaleOrder + 1
    applyScale(scaleOrder[idx])
end)

-- Keybind manager
local kbHeader = Instance.new("TextLabel")
kbHeader.Size = UDim2.new(1, -8, 0, 20)
kbHeader.BackgroundTransparency = 1
kbHeader.Text = "KEYBINDS"
kbHeader.TextColor3 = Theme.Accent2
kbHeader.Font = Enum.Font.GothamBold
kbHeader.TextSize = 12
kbHeader.TextXAlignment = Enum.TextXAlignment.Left
kbHeader.Parent = MenuPage

local function makeKeybindRow(parent, text, getKey, setKey)
    local row = makeRow(parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(getKey())
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 20); btn.Position = UDim2.new(1, -70, 0.5, -10)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = "Set"; btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.Gotham; btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = row
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

makeKeybindRow(MenuPage, "Menu Key",
    function() return Settings.UI.MenuKey.Name end,
    function(v) Settings.UI.MenuKey = (type(v) == "string") and Settings.UI.MenuKey or v end)
makeKeybindRow(MenuPage, "Unload Key",
    function() return Settings.UI.UnloadKey.Name end,
    function(v) Settings.UI.UnloadKey = (type(v) == "string") and Settings.UI.UnloadKey or v end)
makeKeybindRow(MenuPage, "Aim Key",
    function() return Settings.Aim.KeyName end,
    function(v)
        if type(v) == "string" then Settings.Aim.KeyName = v
        else Settings.Aim.KeyName = v.Name end
    end)

--=====================================================================
-- SEARCH BAR
--=====================================================================
local SearchQuery = ""
local function updateSearch()
    local q = string.lower(SearchBar.Text)
    SearchQuery = q
    for _, page in pairs(tabPages) do
        for _, child in ipairs(page:GetChildren()) do
            if child:IsA("Frame") then
                local txt = ""
                for _, sub in ipairs(child:GetChildren()) do
                    if sub:IsA("TextLabel") then txt = txt .. " " .. string.lower(sub.Text) end
                end
                if q == "" then
                    child.Visible = true
                else
                    child.Visible = string.find(txt, q, 1, true) ~= nil
                end
            end
        end
    end
end
SearchBar:GetPropertyChangedSignal("Text"):Connect(updateSearch)

--=====================================================================
-- UNLOAD
--=====================================================================
local function UNLOAD()
    pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.Default end)
    disconnectAll()
    stickyTarget = nil
    if infJumpConn then pcall(function() infJumpConn:Disconnect() end); infJumpConn = nil end
    if tpwalkConn then tpwalkConn:Disconnect(); tpwalkConn = nil end
    if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn = nil end
    if grassConnection then grassConnection:Disconnect(); grassConnection = nil end
    stopHeadMover()
    if worldBackup then
        pcall(function()
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            Lighting.Brightness = originalLighting.Brightness
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.FogStart = originalLighting.FogStart
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            Lighting.EnvironmentDiffuseScale = originalLighting.EnvironmentDiffuseScale
            Lighting.EnvironmentSpecularScale = originalLighting.EnvironmentSpecularScale
        end)
    end
    for m, d in pairs(ESPData) do destroyESPStruct(d) end
    ESPData = {}
    for inst, struct in pairs(ItemDrawings) do
        if typeof(inst) == "Instance" then destroyItemStruct(struct) end
    end
    ItemDrawings = {}
    for _, obj in ipairs(AllDrawings) do pcall(function() obj:Remove() end) end
    AllDrawings = {}
    TargetLinePool = {}
    pcall(function() ScreenGui:Destroy() end)
    if getgenv() then getgenv().MixWare_Unloaded = true end
end
getgenv().MixWare_UNLOAD = UNLOAD

--=====================================================================
-- AUTO-LOAD LAST CONFIG
--=====================================================================
task.spawn(function()
    task.wait(1)
    local lastName = getLastConfigName()
    if lastName and lastName ~= "" then
        local ok = loadConfig(lastName, false)
        if ok then
            ActiveConfigName = lastName
            notify("Auto-loaded: " .. lastName, Theme.Good)
        end
    end
end)

--=====================================================================
-- MAIN LOOP
--=====================================================================
addConn(RunService.RenderStepped:Connect(function()
    -- ESP
    if Settings.ESP.Enabled then drawESP()
    else for _, d in pairs(ESPData) do hideAllESP(d) end end

    -- Crosshair
    drawCrosshair()

    -- Target Line
    drawTargetLine()

    -- Aim Visuals + Debug
    if Settings.Aim.Enabled then
        drawAimVisuals(currentTarget)
        if isAimKeyDown() and currentTarget then
            setMouseLock(true)
        else
            setMouseLock(false)
        end
    else
        drawAimVisuals(nil)
        setMouseLock(false)
    end
    drawAimDebug()

    -- Items
    drawItemESP()

    -- World ESP
    if Settings.WorldESP.Enabled then
        -- используем старую функцию через generic (упрощённо: одна папка)
        -- Item ESP уже покрывает; WorldESP — отдельная папка
        -- (оставляем как заглушку, World ESP тоже можно юзать через ITEM_ESP_PATHS)
    end

    updateTrigger()
    updateInventoryESP()

    -- World значение каждый кадр
    keepWorldValues()
    keepCameraFOV()
end))

addConn(RunService.Heartbeat:Connect(function()
    heartbeatAimbot()
end))

--=====================================================================
-- HOTKEYS
--=====================================================================
addConn(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.UI.MenuKey then
        Settings.UI.Open = not Settings.UI.Open
        Main.Visible = Settings.UI.Open
    elseif input.KeyCode == Settings.UI.UnloadKey then
        UNLOAD()
    end
end))

--=====================================================================
-- Min / Close
--=====================================================================
local minimized = false
local savedSize = Main.Size
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        savedSize = Main.Size
        Main.Size = UDim2.new(0, 700, 0, 34)
        ContentHolder.Visible = false
        SearchBar.Visible = false
    else
        Main.Size = savedSize
        ContentHolder.Visible = true
        SearchBar.Visible = true
    end
end)
CloseBtn.MouseButton1Click:Connect(function()
    Settings.UI.Open = false; Main.Visible = false
end)

notify("MixWare.lol v2.6 loaded!", Theme.Accent)