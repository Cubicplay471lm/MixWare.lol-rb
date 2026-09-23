return function(ctx)
    local M, U, Settings, Theme = ctx.M, ctx.U, ctx.Settings, ctx.Theme
    local cloneref, gethui, protect_gui, getgenv = ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv
    local Drawing = ctx.Drawing
    local RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager = ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager
    local LocalPlayer, Camera = ctx.LocalPlayer, ctx.Camera
M.HitboxOriginals = {}

function U.restoreHitboxes()
    for part, data in pairs(M.HitboxOriginals) do
        if part and part.Parent then
            pcall(function()
                part.Size = data.Size
                part.Transparency = data.Transparency
                part.CanCollide = data.CanCollide
                part.CanTouch = data.CanTouch
                part.CanQuery = data.CanQuery
            end)
        end
    end
    M.HitboxOriginals = {}
end

function U.shouldExpandHitbox(plr)
    if plr == LocalPlayer then return false end
    if Settings.ESP.HitboxTeamCheck and LocalPlayer.Team ~= nil and plr.Team == LocalPlayer.Team then return false end
    return true
end

function U.applyHitboxPart(part, size, transparency)
    if not part or not part:IsA("BasePart") then return end
    if not M.HitboxOriginals[part] then
        M.HitboxOriginals[part] = {
            Size = part.Size, Transparency = part.Transparency,
            CanCollide = part.CanCollide, CanTouch = part.CanTouch, CanQuery = part.CanQuery,
        }
    end
    pcall(function()
        part.Size = Vector3.new(size, size, size)
        part.Transparency = math.clamp(transparency, 0, 1)
        part.CanCollide = false
        part.CanTouch = true
        part.CanQuery = true
    end)
end

function U.updateHitboxExpander()
    if not Settings.ESP.HitboxExpander then
        if next(M.HitboxOriginals) then U.restoreHitboxes() end
        return
    end
    local wanted = {}
    local size = math.max(1, Settings.ESP.HitboxSize)
    local transp = math.clamp(Settings.ESP.HitboxTransparency, 0, 1)
    for _, plr in ipairs(Players:GetPlayers()) do
        if U.shouldExpandHitbox(plr) then
            local ch = plr.Character
            if ch then
                if Settings.ESP.HitboxParts == "Head" or Settings.ESP.HitboxParts == "Head+Root" then
                    local head = ch:FindFirstChild("Head")
                    if head and head:IsA("BasePart") then wanted[head] = true; U.applyHitboxPart(head, size, transp) end
                end
                if Settings.ESP.HitboxParts == "Root" or Settings.ESP.HitboxParts == "Head+Root" then
                    local root = ch:FindFirstChild("HumanoidRootPart")
                    if root and root:IsA("BasePart") then wanted[root] = true; U.applyHitboxPart(root, size, transp) end
                end
            end
        end
    end
    for part in pairs(M.HitboxOriginals) do
        if not wanted[part] or not part.Parent then
            local data = M.HitboxOriginals[part]
            if part and part.Parent and data then
                pcall(function()
                    part.Size=data.Size; part.Transparency=data.Transparency
                    part.CanCollide=data.CanCollide; part.CanTouch=data.CanTouch; part.CanQuery=data.CanQuery
                end)
            end
            M.HitboxOriginals[part] = nil
        end
    end
end

--=====================================================================
-- GUI

end
