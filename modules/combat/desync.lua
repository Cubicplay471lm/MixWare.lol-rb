local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

local Desync = {}
Desync.Enabled = false
Desync.ServerCFrame = nil
Desync._conn = nil

local function getChar()
    local c = LP.Character
    if not c then return nil end
    return c, c:FindFirstChild("Humanoid"), c:FindFirstChild("HumanoidRootPart")
end

function Desync:Enable()
    if self.Enabled then return end
    local char, hum, hrp = getChar()
    if not (char and hum and hrp) then return end

    -- запоминаем серверную позицию — её будет видеть сервер
    self.ServerCFrame = hrp.CFrame
    self.Enabled = true

    -- забираем физику себе
    pcall(function() hrp:SetNetworkOwner(LP) end)

    -- отключаем обычное управление — теперь двигаем вручную
    hum.PlatformStand = true
    hum.AutoRotate = false

    self._conn = RunService.RenderStepped:Connect(function(dt)
        if not self.Enabled then return end
        local _, h, root = getChar()
        if not (h and root) then return end

        -- ввод игрока → локальное движение
        local move = h.MoveDirection
        local speed = 50
        local look = workspace.CurrentCamera.CFrame.LookVector

        if move.Magnitude > 0 then
            local dir = (look * move.Z + look:Cross(Vector3.new(0,1,0)) * move.X)
            dir = Vector3.new(dir.X, 0, dir.Z).Unit
            root.CFrame = root.CFrame + dir * speed * dt
        end

        -- гасим velocity, чтобы сервер не «тянул» тебя обратно
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end

function Desync:Disable()
    if not self.Enabled then return end
    self.Enabled = false
    if self._conn then self._conn:Disconnect(); self._conn = nil end

    local _, hum, hrp = getChar()
    if hum then
        hum.PlatformStand = false
        hum.AutoRotate = true
    end
    if hrp then
        pcall(function() hrp:SetNetworkOwner(nil) end) -- вернуть серверу
    end
    self.ServerCFrame = nil
end

function Desync:Toggle()
    if self.Enabled then self:Disable() else self:Enable() end
    return self.Enabled
end

return Desync