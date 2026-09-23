return function(ctx)
    local M, U, Settings, Theme = ctx.M, ctx.U, ctx.Settings, ctx.Theme
    local cloneref, gethui, protect_gui, getgenv = ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv
    local Drawing = ctx.Drawing
    local RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager = ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager
    local LocalPlayer, Camera = ctx.LocalPlayer, ctx.Camera
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
    if w.FullBright then
        U.backupLighting()
        if not w.CustomAmbientEnabled then
            if Lighting.Ambient ~= Color3.fromRGB(255,255,255) then
                pcall(function()
                    Lighting.Ambient = Color3.fromRGB(255,255,255)
                    Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
                end)
            end
        end
        if Lighting.Brightness ~= 3 then pcall(function() Lighting.Brightness = 3 end) end
        if Lighting.GlobalShadows ~= false then pcall(function() Lighting.GlobalShadows = false end) end
        if Lighting.FogEnd ~= math.huge then
            pcall(function() Lighting.FogEnd = math.huge; Lighting.FogStart = 0 end)
        end
        if Lighting.ClockTime < 11 or Lighting.ClockTime > 13 then
            pcall(function() Lighting.ClockTime = 12 end)
        end
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Atmosphere") then pcall(function() obj.Enabled = false end) end
            if obj:IsA("SunRaysEffect") then pcall(function() obj.Enabled = false end) end
            if obj:IsA("BlurEffect") then pcall(function() obj.Enabled = false end) end
        end
    end
    if w.NoFog and Lighting.FogEnd ~= math.huge then
        pcall(function() Lighting.FogEnd = math.huge end)
    end
    if w.CustomTimeEnabled and math.abs(Lighting.ClockTime - w.CustomTime) > 0.05 then
        pcall(function() Lighting.ClockTime = w.CustomTime end)
    end
    if w.CustomAmbientEnabled then
        pcall(function()
            Lighting.Ambient = w.AmbientColor
            Lighting.OutdoorAmbient = w.AmbientColor
        end)
    end
    if w.ColorCorrection and (w.FullBright or w.CustomAmbientEnabled) then
        local cc = M.ColorCorrection
        if not cc or not cc.Parent then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "MixWareColorCorrection"
            cc.Parent = Lighting
            M.ColorCorrection = cc
        end
        cc.Brightness = w.FullBright and 0.3 or 0.1
        cc.Contrast = 0
        cc.Saturation = 0
        cc.TintColor = Color3.fromRGB(255, 255, 255)
    else
        if M.ColorCorrection then
            pcall(function() M.ColorCorrection:Destroy() end)
            M.ColorCorrection = nil
        end
    end
end

function U.applyRemoveGrass()
    if Settings.World.RemoveGrass then
        pcall(function() Workspace.Terrain.Decoration = false end)
    end
end

function U.keepCameraFOV()
    if Settings.World.CameraFOVEnabled then
        if math.abs(Camera.FieldOfView - Settings.World.CameraFOV) > 0.01 and not M.FreecamActive then
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
-- FREECAM

end
