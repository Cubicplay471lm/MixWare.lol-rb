return function(ctx)
--[[
    BUILD: 3.0.0
    MixWare.lol v3.0.0
    Combat → AimBot | Trigger
    Visuals → Enemies | Items | Inventory | World | Crosshair
    Misc → Misc | Config | Menu

    Новое в 3.0.0:
      - Modular architecture: combat / visuals / UI / misc вынесены в отдельные файлы
      - main.lua теперь является лёгким загрузчиком модулей
      - Функционал 2.9.0 сохранён без изменения логики
      - Структура проекта зафиксирована для следующих обновлений
--]]

--=====================================================================
-- API
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

local injectedMouse1Click = mouse1click
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

-- Экстренный сброс при запуске
pcall(function()
    UIS.MouseBehavior = Enum.MouseBehavior.Default
    local cam = workspace.CurrentCamera
    if cam then cam.CameraType = Enum.CameraType.Custom end
end)

--=====================================================================
-- ГЛАВНАЯ ТАБЛИЦА
--=====================================================================
local M = {}
M.U = {}
U = M.U
M.ESPData = {}
M.AllDrawings = {}
M.ItemDrawings = {}
M.Connections = {}
M.ActiveConfigName = "none"
M.IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

--=====================================================================
-- THEME
--=====================================================================
M.Themes = {
    Purple = {Bg=Color3.fromRGB(18,14,26),Bg2=Color3.fromRGB(26,18,38),Panel=Color3.fromRGB(38,26,54),Row=Color3.fromRGB(44,30,62),Title=Color3.fromRGB(40,26,58),Accent=Color3.fromRGB(160,90,255),Accent2=Color3.fromRGB(220,120,255),Text=Color3.fromRGB(235,225,250),TextDim=Color3.fromRGB(160,140,190),Good=Color3.fromRGB(90,220,120),Bad=Color3.fromRGB(220,70,130),Stroke=Color3.fromRGB(85,55,130)},
    Dark = {Bg=Color3.fromRGB(15,15,18),Bg2=Color3.fromRGB(22,22,26),Panel=Color3.fromRGB(32,32,38),Row=Color3.fromRGB(38,38,44),Title=Color3.fromRGB(34,34,40),Accent=Color3.fromRGB(90,140,240),Accent2=Color3.fromRGB(140,180,255),Text=Color3.fromRGB(230,230,240),TextDim=Color3.fromRGB(140,140,150),Good=Color3.fromRGB(90,220,120),Bad=Color3.fromRGB(210,70,90),Stroke=Color3.fromRGB(60,60,70)},
    Blue = {Bg=Color3.fromRGB(12,18,30),Bg2=Color3.fromRGB(18,26,42),Panel=Color3.fromRGB(26,40,62),Row=Color3.fromRGB(32,48,74),Title=Color3.fromRGB(28,44,68),Accent=Color3.fromRGB(60,140,255),Accent2=Color3.fromRGB(120,190,255),Text=Color3.fromRGB(220,235,255),TextDim=Color3.fromRGB(140,170,210),Good=Color3.fromRGB(90,220,120),Bad=Color3.fromRGB(220,80,110),Stroke=Color3.fromRGB(60,100,150)},
    Red = {Bg=Color3.fromRGB(20,12,14),Bg2=Color3.fromRGB(30,16,20),Panel=Color3.fromRGB(46,22,26),Row=Color3.fromRGB(56,28,32),Title=Color3.fromRGB(50,24,30),Accent=Color3.fromRGB(230,70,90),Accent2=Color3.fromRGB(255,130,150),Text=Color3.fromRGB(250,230,235),TextDim=Color3.fromRGB(200,150,160),Good=Color3.fromRGB(90,220,120),Bad=Color3.fromRGB(255,50,60),Stroke=Color3.fromRGB(120,50,60)},
    Pink = {Bg=Color3.fromRGB(24,14,22),Bg2=Color3.fromRGB(36,20,32),Panel=Color3.fromRGB(54,28,48),Row=Color3.fromRGB(66,34,58),Title=Color3.fromRGB(58,30,52),Accent=Color3.fromRGB(255,110,180),Accent2=Color3.fromRGB(255,170,220),Text=Color3.fromRGB(250,225,240),TextDim=Color3.fromRGB(200,150,180),Good=Color3.fromRGB(90,220,120),Bad=Color3.fromRGB(230,60,120),Stroke=Color3.fromRGB(140,70,110)},
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
        SkeletonEnabled=false, SkeletonColor=Color3.fromRGB(200,130,255), SkeletonThickness=1,
        HealthBarEnabled=false, HealthBarWidth=4, HealthBarOffset=6,
        NametagsEnabled=false, NametagsShowHP=true, NametagsShowDist=true,
        ArrowsEnabled=false, ArrowsColor=Color3.fromRGB(200,130,255), ArrowsSize=14,
        WeaponNameEnabled=false, WeaponNameColor=Color3.fromRGB(255,180,220), WeaponNameSize=12,
        DistanceFade=false, DistanceFadeStart=0.7,
        HitboxExpander=false, HitboxSize=8, HitboxTransparency=0.75, HitboxParts="Head+Root", HitboxTeamCheck=true,
    },
    Crosshair = {Enabled=false,Style="Cross",Color=Color3.fromRGB(255,255,255),OutlineColor=Color3.fromRGB(0,0,0),Gap=4,Length=8,Thickness=1,Dot=true,DotSize=2,CircleRadius=12,Outline=true,Rainbow=false},
    ItemESP = {Enabled=false,Color=Color3.fromRGB(220,180,100),MaxDistance=500,TextEnabled=true,RefreshRate=0.2,SelectedItems={}},
    WorldESP = {Enabled=false,Color=Color3.fromRGB(120,220,200),MaxDistance=500,TextEnabled=true},
    World = {
        FullBright=false, NoFog=false, CustomTimeEnabled=false, CustomTime=14,
        CustomAmbientEnabled=false, AmbientColor=Color3.fromRGB(255,255,255),
        CameraFOVEnabled=false, CameraFOV=70,
        DisableSunRays=false, DisableAtmosphere=false, RemoveGrass=false, ColorCorrection=true,
        HandChamsEnabled=false, HandChamsMaterial="Neon",
        HandChamsColor=Color3.fromRGB(255,100,200), HandChamsTransparency=0.2,
        WeaponChamsEnabled=false, WeaponChamsMaterial="Neon",
        WeaponChamsColor=Color3.fromRGB(150,255,150), WeaponChamsTransparency=0.2,
    },
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
        MobileButtonShow=true,
        MobileButtonX=0.82, MobileButtonY=0.75,
        MobileButtonLocked=false,
        FOVFillEnabled=false,
        FOVFillCenterColor=Color3.fromRGB(255,50,50),
        FOVFillTransparency=0.85,
        FOVColor=Color3.fromRGB(160,90,255),
        TargetPulseEnabled=false,
        TargetPulseSpeed=2.0,
        TargetPulseMin=0.3,
        TargetPulseMax=1.0,
    },
    Trigger = {Enabled=false,Delay=0.05,TeamCheck=true,WallCheck=false,OnlyAimKey=true},
    Misc = {
        TPWalkEnabled=false, TPWalkSpeed=20, InfJump=false, WalkSpeed=16, JumpPower=50, AntiFling=false,
        FreecamEnabled=false, FreecamKey=Enum.KeyCode.K, FreecamSpeed=1.5,
    },
    Sound = {KillSound=true,TargetLockSound=true,KillSoundId="rbxassetid://5275866553",TargetLockSoundId="rbxassetid://876939830"},
    UI = {
        Open=true, MenuKey=Enum.KeyCode.RightShift, UnloadKey=Enum.KeyCode.End,
        Watermark=true, Notifications=true, Theme="Purple", Scale="Medium",
        WatermarkX=0.01, WatermarkY=0.02, WatermarkScale=1.0,
        InventoryX=0.72, InventoryY=0.25, InventoryScale=1.0,
        MenuSize=1.0,
        DragHoldTime=0.7, AutoScale=true,
    },
}
M.Settings = Settings

ctx.M, ctx.U, ctx.Settings, ctx.Theme = M, U, Settings, Theme
ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv = cloneref, gethui, protect_gui, getgenv
ctx.Drawing = Drawing
ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager = RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager
ctx.LocalPlayer, ctx.Camera = LocalPlayer, Camera

--=====================================================================
-- УТИЛИТЫ
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
    if M.IsMobile and Settings.Aim.MobileButtonShow and M.MobileButtonActive then return true end
    local kn = Settings.Aim.KeyName
    if kn == "MouseButton2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
    if kn == "MouseButton1" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
    local kc = Enum.KeyCode[kn]
    if kc then return UIS:IsKeyDown(kc) end
    return false
end

M.VisibilityRayParams = RaycastParams.new()
M.VisibilityRayParams.FilterType = Enum.RaycastFilterType.Exclude
M.VisibilityRayParams.IgnoreWater = true
M.VisibilityFilter = {nil, Camera}

function U.isVisibleFromCam(part, targetModel)
    if not part then return false end
    M.VisibilityFilter[1] = LocalPlayer.Character
    M.VisibilityFilter[2] = Camera
    M.VisibilityRayParams.FilterDescendantsInstances = M.VisibilityFilter
    local camPos = Camera.CFrame.Position
    local res = Workspace:Raycast(camPos, part.Position - camPos, M.VisibilityRayParams)
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

-- FIX: проверяем что Drawing-объект реально работает
function U.newDrawing(kind)
    local ok, obj = pcall(function() return Drawing.new(kind) end)
    if ok and obj then
        -- Проверяем что Visible можно установить
        local testOK = pcall(function() obj.Visible = false end)
        if testOK then
            table.insert(M.AllDrawings, obj)
            return obj
        end
        -- Если нет — удаляем
        pcall(function() obj:Remove() end)
    end
    -- Заглушка
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

end
