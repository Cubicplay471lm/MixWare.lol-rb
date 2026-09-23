return function(ctx)
    local M, U, Settings, Theme = ctx.M, ctx.U, ctx.Settings, ctx.Theme
    local cloneref, gethui, protect_gui, getgenv = ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv
    local Drawing = ctx.Drawing
    local RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager = ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager
    local LocalPlayer, Camera = ctx.LocalPlayer, ctx.Camera
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

-- UNIVERSAL PANEL DRAG
local function makePanelDraggable(frame)
    if not frame or not frame:IsA("GuiObject") then return end
    frame.Active = true
    local dragging=false
    local dragStart,startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; startPos=frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
        local d=input.Position-dragStart
        frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
end

-- WATERMARK
do
    local wm = Instance.new("Frame", ScreenGui)
    wm.Size = UDim2.new(0, 100, 0, 28)
    wm.Position = UDim2.new(Settings.UI.WatermarkX, 0, Settings.UI.WatermarkY, 0)
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
    local wmScale = Instance.new("UIScale", wm)
    wmScale.Scale = Settings.UI.WatermarkScale
    M.WatermarkScale = wmScale
    M.Watermark = wm
    M.WatermarkText = wt
    makePanelDraggable(wm)

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
                "  MixWare.lol v3.0.0   |   Config: %s   |   %s   |   FPS %d   |   Ping %d   |   Players %d",
                M.ActiveConfigName, time, fps, ping, pc)
            task.wait(0.5)
        end
    end)
end

--=====================================================================
-- INVENTORY PANEL
--=====================================================================
M.InvPanel = Instance.new("Frame", ScreenGui)
M.InvPanel.Size = UDim2.new(0, 280, 0, 260)
M.InvPanel.Position = UDim2.new(Settings.UI.InventoryX, 0, Settings.UI.InventoryY, 0)
M.InvPanel.BackgroundColor3 = Theme.Bg
M.InvPanel.BackgroundTransparency = Settings.InvESP.Transparency
M.InvPanel.BorderSizePixel = 0
M.InvPanel.Active = true
M.InvPanel.Visible = false
Instance.new("UICorner", M.InvPanel).CornerRadius = UDim.new(0, 10)
M.InvScale = Instance.new("UIScale", M.InvPanel)
M.InvScale.Scale = Settings.UI.InventoryScale
makePanelDraggable(M.InvPanel)
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
-- MOBILE BUTTON
--=====================================================================
M.MobileButtonActive = false
M.MobileAimBtn = nil

function U.createMobileAimButton()
    if M.MobileAimBtn or not M.IsMobile or not Settings.Aim.MobileButtonShow then return end
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 64, 0, 64)
    btn.Position = UDim2.new(Settings.Aim.MobileButtonX, 0, Settings.Aim.MobileButtonY, 0)
    btn.BackgroundColor3 = Theme.Bad; btn.BackgroundTransparency = 0.2
    btn.Text = "AIM"; btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Theme.Stroke; stroke.Thickness = 2
    btn.MouseButton1Click:Connect(function()
        M.MobileButtonActive = not M.MobileButtonActive
        btn.BackgroundColor3 = M.MobileButtonActive and Theme.Good or Theme.Bad
    end)
    M.MobileAimBtn = btn
end

function U.setMobileButtonVisible(state)
    if state and M.IsMobile then
        U.createMobileAimButton()
        if M.MobileAimBtn then M.MobileAimBtn.Visible = true end
    else
        if M.MobileAimBtn then M.MobileAimBtn.Visible = false end
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
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    U.addConn(UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end))
    U.addConn(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
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
    local row = U.makeRow(parent, 76)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -60, 0, 16); lbl.Position = UDim2.new(0, 10, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local initial = U.getPath(path) or Color3.new(1,1,1)
    local swatch = Instance.new("Frame", row)
    swatch.Size = UDim2.new(0, 40, 0, 20); swatch.Position = UDim2.new(1, -50, 0, 2)
    swatch.BackgroundColor3 = initial
    swatch.BorderSizePixel = 0
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", swatch).Color = Theme.Stroke

    local h, s, v = Color3.toHSV(initial)
    s = 1

    local hueBar = Instance.new("Frame", row)
    hueBar.Size = UDim2.new(1, -20, 0, 14)
    hueBar.Position = UDim2.new(0, 10, 0, 26)
    hueBar.BorderSizePixel = 0
    Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0, 3)
    local hueGrad = Instance.new("UIGradient", hueBar)
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
    })
    local hueMarker = Instance.new("Frame", hueBar)
    hueMarker.Size = UDim2.new(0, 3, 1, 2)
    hueMarker.Position = UDim2.new(h, -1, 0, -1)
    hueMarker.BackgroundColor3 = Color3.new(1,1,1)
    hueMarker.BorderSizePixel = 0
    Instance.new("UICorner", hueMarker).CornerRadius = UDim.new(0, 2)

    local brightBar = Instance.new("Frame", row)
    brightBar.Size = UDim2.new(1, -20, 0, 14)
    brightBar.Position = UDim2.new(0, 10, 0, 48)
    brightBar.BorderSizePixel = 0
    Instance.new("UICorner", brightBar).CornerRadius = UDim.new(0, 3)
    local brightGrad = Instance.new("UIGradient", brightBar)
    local function updateBrightGradient()
        local c = Color3.fromHSV(h, 1, 1)
        brightGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
            ColorSequenceKeypoint.new(1, c),
        })
    end
    updateBrightGradient()
    local brightMarker = Instance.new("Frame", brightBar)
    brightMarker.Size = UDim2.new(0, 3, 1, 2)
    brightMarker.Position = UDim2.new(v, -1, 0, -1)
    brightMarker.BackgroundColor3 = Color3.new(1,1,1)
    brightMarker.BorderSizePixel = 0
    Instance.new("UICorner", brightMarker).CornerRadius = UDim.new(0, 2)

    local function emit()
        local c = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = c
        U.setPath(path, c)
        if cb then cb(c) end
    end

    local hueDrag = false
    local function hueFromX(x)
        local rel = math.clamp((x - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
        h = rel
        hueMarker.Position = UDim2.new(rel, -1, 0, -1)
        updateBrightGradient()
        emit()
    end
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            hueDrag = true
            hueFromX(input.Position.X)
        end
    end)

    local brightDrag = false
    local function brightFromX(x)
        local rel = math.clamp((x - brightBar.AbsolutePosition.X) / brightBar.AbsoluteSize.X, 0, 1)
        v = math.clamp(rel, 0.05, 1)
        brightMarker.Position = UDim2.new(v, -1, 0, -1)
        emit()
    end
    brightBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            brightDrag = true
            brightFromX(input.Position.X)
        end
    end)

    U.addConn(UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            if hueDrag then hueFromX(input.Position.X) end
            if brightDrag then brightFromX(input.Position.X) end
        end
    end))
    U.addConn(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            hueDrag = false
            brightDrag = false
        end
    end))

    emit()

    U.registerUI(path, function(c)
        if typeof(c) ~= "Color3" then return end
        local nh, ns, nv = Color3.toHSV(c)
        h, s, v = nh, ns, nv
        hueMarker.Position = UDim2.new(h, -1, 0, -1)
        brightMarker.Position = UDim2.new(v, -1, 0, -1)
        updateBrightGradient()
        swatch.BackgroundColor3 = Color3.fromHSV(h, s, v)
        if cb then cb(c) end
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
-- MOBILE MENU RESTORE
--=====================================================================
M.MobileMenuBtn = nil
function U.createMobileMenuButton()
    if not M.IsMobile or M.MobileMenuBtn then return end
    local b = Instance.new("TextButton", ScreenGui)
    b.Size = UDim2.new(0, 42, 0, 42)
    b.Position = UDim2.new(0, 12, 1, -54)
    b.BackgroundColor3 = Theme.Accent
    b.BackgroundTransparency = 0.12
    b.Text = "≡"
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 22
    b.BorderSizePixel = 0
    b.Visible = false
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    makePanelDraggable(b)
    b.MouseButton1Click:Connect(function()
        Settings.UI.Open = true
        M.Main.Visible = true
        b.Visible = false
    end)
    M.MobileMenuBtn = b
end

--=====================================================================
-- MAIN WINDOW
--=====================================================================
M.Main = Instance.new("Frame", ScreenGui)
M.Main.Size = UDim2.new(0, 700, 0, 440)
M.Main.Position = UDim2.new(0.5, -350, 0.5, -220)
M.Main.BackgroundColor3 = Theme.Bg
M.Main.BorderSizePixel = 0
M.Main.Active = true
M.Main.Draggable = true
M.MainScale = Instance.new("UIScale", M.Main)
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
M.Title.Text = "MixWare.lol  •  v3.0.0"
M.Title.TextColor3 = Theme.Text
M.Title.Font = Enum.Font.GothamBold
M.Title.TextSize = 13
M.Title.TextXAlignment = Enum.TextXAlignment.Left

M.MinBtn = Instance.new("TextButton", M.TitleBar)
M.MinBtn.Size = UDim2.new(0, 24, 0, 24); M.MinBtn.Position = UDim2.new(1, -60, 0, 5)
M.MinBtn.BackgroundColor3 = Theme.Panel
M.MinBtn.Text = "—"; M.MinBtn.TextColor3 = Theme.Text
M.MinBtn.Font = Enum.Font.GothamBold; M.MinBtn.TextSize = 12
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

-- AIM PAGE
U.makeToggle(AimPage, "AimBot Enabled", "Aim.Enabled")
U.makeSlider(AimPage, "FOV", 10, 500, "Aim.FOV")
U.makeToggle(AimPage, "Show FOV", "Aim.ShowFOV")
U.makeColorPicker(AimPage, "FOV Border Color", "Aim.FOVColor")
U.makeToggle(AimPage, "FOV Fill", "Aim.FOVFillEnabled")
U.makeColorPicker(AimPage, "FOV Fill Center", "Aim.FOVFillCenterColor")
U.makeSlider(AimPage, "FOV Fill Transparency", 0, 1, "Aim.FOVFillTransparency")
U.makeToggle(AimPage, "Target Pulse", "Aim.TargetPulseEnabled")
U.makeSlider(AimPage, "Target Pulse Speed", 0.5, 5, "Aim.TargetPulseSpeed")
U.makeSlider(AimPage, "Target Pulse Min", 0, 1, "Aim.TargetPulseMin")
U.makeSlider(AimPage, "Target Pulse Max", 0, 1, "Aim.TargetPulseMax")
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
U.makeToggle(AimPage, "Mobile Aim Button", "Aim.MobileButtonShow", function(v)
    U.setMobileButtonVisible(v)
end)

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

-- TRIGGER PAGE
U.makeToggle(TrgPage, "TriggerBot Enabled", "Trigger.Enabled")
U.makeSlider(TrgPage, "Delay", 0.01, 1, "Trigger.Delay")
U.makeToggle(TrgPage, "Team Check", "Trigger.TeamCheck")
U.makeToggle(TrgPage, "Wall Check", "Trigger.WallCheck")
U.makeToggle(TrgPage, "Only When Aim Key Down", "Trigger.OnlyAimKey")

-- ENEMIES PAGE
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
U.makeToggle(EnemiesPage, "Hitbox Expander", "ESP.HitboxExpander")
U.makeSlider(EnemiesPage, "Hitbox Size", 2, 20, "ESP.HitboxSize")
U.makeSlider(EnemiesPage, "Hitbox Transparency", 0, 1, "ESP.HitboxTransparency")
U.makeDropdown(EnemiesPage, "Hitbox Parts", {"Head","Root","Head+Root"}, "ESP.HitboxParts")
U.makeToggle(EnemiesPage, "Hitbox Team Check", "ESP.HitboxTeamCheck")

-- CROSSHAIR PAGE
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

-- ITEMS PAGE
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
Instance.new("UIStroke", M.ItemPopup).Color = Theme.Accent

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

-- INVENTORY PAGE
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
    U.setPath("UI.InventoryX", 0.72)
    U.setPath("UI.InventoryY", 0.25)
    M.InvPanel.Position = UDim2.new(0.72, 0, 0.25, 0)
end)

-- WORLD PAGE
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
U.makeToggle(WorldPage, "Color Correction", "World.ColorCorrection")
U.makeToggle(WorldPage, "Disable Sun Rays", "World.DisableSunRays")
U.makeToggle(WorldPage, "Disable Atmosphere", "World.DisableAtmosphere")
U.makeToggle(WorldPage, "Remove Grass", "World.RemoveGrass", function() U.applyRemoveGrass() end)
U.makeToggle(WorldPage, "Custom Camera FOV", "World.CameraFOVEnabled", function(v)
    if v then pcall(function() Camera.FieldOfView = Settings.World.CameraFOV end)
    else pcall(function() Camera.FieldOfView = 70 end) end
end)
U.makeSlider(WorldPage, "Camera FOV", 30, 120, "World.CameraFOV", function(v)
    if Settings.World.CameraFOVEnabled then
        pcall(function() Camera.FieldOfView = v end)
    end
end)

U.makeToggle(WorldPage, "Hand Chams (self)", "World.HandChamsEnabled")
U.makeDropdown(WorldPage, "Hand Material", {"Neon","ForceField","Glass","Plastic","Metal","Ice","Marble","Granite","Slate","Concrete","Wood","Sand","Fabric","Foil","Grass","Pebble","Salt","Snow","Glacier","Mud"}, "World.HandChamsMaterial")
U.makeColorPicker(WorldPage, "Hand Color", "World.HandChamsColor")
U.makeSlider(WorldPage, "Hand Transparency", 0, 1, "World.HandChamsTransparency")
U.makeToggle(WorldPage, "Weapon Chams (self)", "World.WeaponChamsEnabled")
U.makeDropdown(WorldPage, "Weapon Material", {"Neon","ForceField","Glass","Plastic","Metal","Ice","Marble","Granite","Slate","Concrete","Wood","Sand","Fabric","Foil","Grass","Pebble","Salt","Snow","Glacier","Mud"}, "World.WeaponChamsMaterial")
U.makeColorPicker(WorldPage, "Weapon Color", "World.WeaponChamsColor")
U.makeSlider(WorldPage, "Weapon Transparency", 0, 1, "World.WeaponChamsTransparency")

-- MISC PAGE
U.makeToggle(MiscPage, "TPWalk", "Misc.TPWalkEnabled", function(v) U.setTPWalk(v) end)
U.makeSlider(MiscPage, "TPWalk Speed", 1, 200, "Misc.TPWalkSpeed")
U.makeToggle(MiscPage, "Infinite Jump", "Misc.InfJump", function(v) U.setInfJump(v) end)
U.makeSlider(MiscPage, "WalkSpeed", 1, 500, "Misc.WalkSpeed", function(v) U.applyWalkSpeed(v) end)
U.makeSlider(MiscPage, "JumpPower", 1, 500, "Misc.JumpPower", function(v) U.applyJumpPower(v) end)
U.makeToggle(MiscPage, "Anti-Fling", "Misc.AntiFling", function(v) U.setAntiFling(v) end)
U.makeToggle(MiscPage, "Freecam (bind K)", "Misc.FreecamEnabled", function(v)
    if v then U.startFreecam() else U.stopFreecam() end
end)
U.makeSlider(MiscPage, "Freecam Speed", 0.5, 10, "Misc.FreecamSpeed")
U.makeToggle(MiscPage, "Kill Sound", "Sound.KillSound")
U.makeToggle(MiscPage, "Target Lock Sound", "Sound.TargetLockSound")
U.makeButton(MiscPage, "Load Infinite Yield source", function()
    pcall(function()
        local src = game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
        getgenv().IY_Source = src
    end)
    U.notify("IY source загружен")
end)

-- CONFIG PAGE
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
    M.InvPanel.Position = UDim2.new(Settings.UI.InventoryX, 0, Settings.UI.InventoryY, 0)
    if M.InvScale then M.InvScale.Scale = Settings.UI.InventoryScale or 1 end
    M.Watermark.Position = UDim2.new(Settings.UI.WatermarkX, 0, Settings.UI.WatermarkY, 0)
    if M.WatermarkScale then M.WatermarkScale.Scale = Settings.UI.WatermarkScale or 1 end
    U.applyMenuSize(Settings.UI.MenuSize or 1)
    if M.MobileAimBtn then
        M.MobileAimBtn.Position = UDim2.new(Settings.Aim.MobileButtonX, 0, Settings.Aim.MobileButtonY, 0)
    end
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

-- MENU PAGE
U.makeToggle(MenuPage, "Watermark", "UI.Watermark", function(v) M.Watermark.Visible = v end)
U.makeToggle(MenuPage, "Notifications", "UI.Notifications")
U.makeSlider(MenuPage, "Drag Hold Time", 0.3, 2, "UI.DragHoldTime")
U.makeToggle(MenuPage, "Auto Menu Scale", "UI.AutoScale", function(v) U.updateAutoMenuScale() end)
U.makeSlider(MenuPage, "Menu Size", 0.70, 1.40, "UI.MenuSize", function(v) U.applyMenuSize(v) end)
U.makeSlider(MenuPage, "Watermark Size", 0.70, 1.50, "UI.WatermarkScale", function(v) if M.WatermarkScale then M.WatermarkScale.Scale = v end end)
U.makeSlider(MenuPage, "Inventory ESP Size", 0.70, 1.50, "UI.InventoryScale", function(v) if M.InvScale then M.InvScale.Scale = v end end)

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

function U.getAutoMenuScale()
    local cam=Workspace.CurrentCamera
    if not cam then return 1 end
    local vp=cam.ViewportSize
    return math.clamp(math.min(vp.X/760,vp.Y/500),0.55,1)
end
function U.applyMenuSize(v)
    v=math.clamp(tonumber(v) or 1,0.70,1.40); Settings.UI.MenuSize=v
    local total=U.getAutoMenuScale()*v
    if M.MainScale then M.MainScale.Scale=total end
    M.Main.Position=UDim2.new(0.5,-350*total,0.5,-220*total)
end
function U.updateAutoMenuScale()
    if not M.Main then return end
    local total=U.getAutoMenuScale()*(Settings.UI.MenuSize or 1)
    if M.MainScale then M.MainScale.Scale=total end
    M.Main.Position=UDim2.new(0.5,-350*total,0.5,-220*total)
end

function U.applyScale(name)
    local s=scaleValues[name] or 1.0; Settings.UI.Scale=name; M.ScaleBtn.Text=name
    local total=U.getAutoMenuScale()*s*(Settings.UI.MenuSize or 1)
    if M.MainScale then M.MainScale.Scale=total end
    M.Main.Position=UDim2.new(0.5,-350*total,0.5,-220*total)
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

-- SEARCH
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

-- UNLOAD
function U.UNLOAD()
    pcall(function()
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = true
    end)
    M.MouseLocked = false
    U.disconnectAll()
    M.StickyTarget = nil
    if M.InfJumpConn then pcall(function() M.InfJumpConn:Disconnect() end); M.InfJumpConn = nil end
    if M.TPWalkConn then M.TPWalkConn:Disconnect(); M.TPWalkConn = nil end
    if M.AntiFlingConn then M.AntiFlingConn:Disconnect(); M.AntiFlingConn = nil end
    U.stopHeadMover()
    U.stopFreecam()
    U.restoreHitboxes()
    U.clearLocalMaterial()
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
    if M.ColorCorrection then pcall(function() M.ColorCorrection:Destroy() end) end
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

-- AUTO-LOAD
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

-- MOBILE
task.spawn(function()
    task.wait(0.5)
    if M.IsMobile and Settings.Aim.MobileButtonShow then
        U.createMobileAimButton()
    end
end)

-- MAIN LOOP
U.addConn(RunService.RenderStepped:Connect(function()
    if Settings.ESP.Enabled then U.drawESP()
    else for _, d in pairs(M.ESPData) do U.hideAllESP(d) end end

    U.updateChamsAll()
    U.updateHitboxExpander()
    U.drawCrosshair()
    U.drawTargetLine()

    -- FIX: одна проверка shouldLock + страховка
    if not Settings.Aim.Enabled and UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
        pcall(function()
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            M.MouseLocked = false
        end)
    end

    local shouldLock = false
    if Settings.Aim.Enabled
        and M.CurrentTarget ~= nil
        and not M.FreecamActive
        and U.isAimKeyDown()
    then
        shouldLock = true
    end
    U.setMouseLock(shouldLock)

    if Settings.Aim.Enabled then
        U.drawAimVisuals(M.CurrentTarget)
    else
        U.drawAimVisuals(nil)
    end
    U.drawAimDebug()

    U.drawItemESP()
    U.updateTrigger()
    U.updateInventoryESP()
    U.keepWorldValues()
    U.keepCameraFOV()
    U.applyLocalMaterial()
end))

U.addConn(RunService.Heartbeat:Connect(function()
    U.heartbeatAimbot()
end))

-- HOTKEYS
U.addConn(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.UI.MenuKey then
        Settings.UI.Open = not Settings.UI.Open
        M.Main.Visible = Settings.UI.Open
        if M.MobileMenuBtn then M.MobileMenuBtn.Visible = not Settings.UI.Open and M.IsMobile end
    elseif input.KeyCode == Settings.UI.UnloadKey then
        U.UNLOAD()
    elseif input.KeyCode == Enum.KeyCode.LeftAlt then
        -- FIX: аварийный сброс мыши
        pcall(function()
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            M.MouseLocked = false
            if M.FreecamActive then U.stopFreecam() end
            local cam = workspace.CurrentCamera
            if cam then
                cam.CameraType = Enum.CameraType.Custom
                if LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then cam.CameraSubject = hum end
                end
            end
        end)
        U.notify("Mouse force reset", Theme.Good)
    end
end))

-- MIN / CLOSE
do
    U.createMobileMenuButton()
    M.MinBtn.MouseButton1Click:Connect(function()
        Settings.UI.Open = false
        M.Main.Visible = false
        if M.MobileMenuBtn then M.MobileMenuBtn.Visible = M.IsMobile end
    end)
    M.CloseBtn.MouseButton1Click:Connect(function()
        U.UNLOAD()
    end)
end

U.notify("MixWare.lol v3.0.0 loaded! LeftAlt = mouse reset", Theme.Accent)
end
