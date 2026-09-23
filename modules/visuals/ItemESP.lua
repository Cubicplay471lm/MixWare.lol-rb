return function(ctx)
    local M, U, Settings, Theme = ctx.M, ctx.U, ctx.Settings, ctx.Theme
    local cloneref, gethui, protect_gui, getgenv = ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv
    local Drawing = ctx.Drawing
    local RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager = ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager
    local LocalPlayer, Camera = ctx.LocalPlayer, ctx.Camera
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

end
