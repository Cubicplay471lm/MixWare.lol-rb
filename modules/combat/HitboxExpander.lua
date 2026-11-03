return function(ctx)
    local M, U, Settings, Theme = ctx.M, ctx.U, ctx.Settings, ctx.Theme
    local cloneref, gethui, protect_gui, getgenv = ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv
    local Drawing = ctx.Drawing
    local RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager = ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager
    local LocalPlayer, Camera = ctx.LocalPlayer, ctx.Camera
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
                "  MixWare.lol v2.8.7   |   Config: %s   |   %s   |   FPS %d   |   Ping %d   |   Players %d",
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

end
