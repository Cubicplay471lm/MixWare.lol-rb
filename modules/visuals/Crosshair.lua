return function(ctx)
    local M, U, Settings, Theme = ctx.M, ctx.U, ctx.Settings, ctx.Theme
    local cloneref, gethui, protect_gui, getgenv = ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv
    local Drawing = ctx.Drawing
    local RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager = ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager
    local LocalPlayer, Camera = ctx.LocalPlayer, ctx.Camera
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
    cp.line1.Visible=false; cp.line2.Visible=false; cp.line3.Visible=false; cp.line4.Visible=false
    cp.dot.Visible=false; cp.circle.Visible=false
    cp.o1.Visible=false; cp.o2.Visible=false; cp.o3.Visible=false; cp.o4.Visible=false
    for i=1,8 do cp.sunLines[i].Visible=false end
end

function U.getCrosshairColor()
    if not Settings.Crosshair.Rainbow then return Settings.Crosshair.Color end
    return Color3.fromHSV((os.clock() * 0.3) % 1, 1, 1)
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
        if c.Dot or c.Style == "Dot" then
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

    if c.Dot or c.Style == "Dot" then
        local s = c.DotSize
        cp.dot.Size = Vector2.new(s, s)
        cp.dot.Position = Vector2.new(center.X-s/2, center.Y-s/2)
        cp.dot.Color = color; cp.dot.Filled = true
        cp.dot.Transparency = 0; cp.dot.Visible = true
    end
end

--=====================================================================
-- AIMBOT

end
