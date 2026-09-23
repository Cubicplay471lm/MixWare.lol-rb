return function(ctx)
    local M, U, Settings, Theme = ctx.M, ctx.U, ctx.Settings, ctx.Theme
    local cloneref, gethui, protect_gui, getgenv = ctx.cloneref, ctx.gethui, ctx.protect_gui, ctx.getgenv
    local Drawing = ctx.Drawing
    local RunService, Players, UIS, Workspace, Lighting, HttpService, Stats, SoundService, VirtualInputManager = ctx.RunService, ctx.Players, ctx.UIS, ctx.Workspace, ctx.Lighting, ctx.HttpService, ctx.Stats, ctx.SoundService, ctx.VirtualInputManager
    local LocalPlayer, Camera = ctx.LocalPlayer, ctx.Camera
--=====================================================================
M.FreecamActive = false
M.FreecamConn = nil
M.FreecamCFrame = nil
M.FreecamVel = Vector3.zero
M.FreecamSavedSubject = nil

function U.startFreecam()
    if M.FreecamActive then return end
    M.FreecamActive = true
    M.FreecamSavedSubject = Camera.CameraSubject
    M.FreecamCFrame = Camera.CFrame
    pcall(function()
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CameraSubject = nil
    end)
    M.FreecamConn = RunService.RenderStepped:Connect(function(dt)
        if not M.FreecamActive then return end
        local move = Vector3.zero
        local speed = Settings.Misc.FreecamSpeed * 50
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + M.FreecamCFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - M.FreecamCFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - M.FreecamCFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + M.FreecamCFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            move = move - Vector3.new(0, 1, 0)
        end
        if move.Magnitude > 0 then
            M.FreecamVel = M.FreecamVel:Lerp(move.Unit * speed, math.clamp(dt * 15, 0, 1))
        else
            M.FreecamVel = M.FreecamVel:Lerp(Vector3.zero, math.clamp(dt * 20, 0, 1))
        end
        M.FreecamCFrame = M.FreecamCFrame + M.FreecamVel * dt
        Camera.CFrame = M.FreecamCFrame
    end)
end

function U.stopFreecam()
    if not M.FreecamActive then return end
    M.FreecamActive = false
    if M.FreecamConn then M.FreecamConn:Disconnect(); M.FreecamConn = nil end
    pcall(function()
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = M.FreecamSavedSubject or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
    end)
end

function U.toggleFreecam()
    if M.FreecamActive then
        U.stopFreecam()
        U.notify("Freecam OFF", Theme.Bad)
    else
        U.startFreecam()
        U.notify("Freecam ON (WASD/Space/Ctrl)", Theme.Good)
    end
end

U.addConn(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.Misc.FreecamKey then
        U.toggleFreecam()
    end
end))

--=====================================================================
-- HEAD MOVER
--=====================================================================

end
