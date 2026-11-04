--[[
    BUILD: 3.0.0
    MixWare.lol v3.0.0
    Modular build
--]]
local BASE = "https://raw.githubusercontent.com/Cubicplay471lm/MixWare.lol-rb/main/"
local ctx = {}
local function loadModule(path)
    local src = game:HttpGet(BASE .. path)
    local chunk = assert(loadstring(src), "MixWare module failed to compile: " .. path)
    local init = chunk()
    assert(type(init) == "function", "MixWare module invalid: " .. path)
    init(ctx)
end
loadModule("modules/core/Core.lua")
loadModule("modules/visuals/ESP.lua")
loadModule("modules/visuals/Crosshair.lua")
loadModule("modules/combat/Aimbot.lua")
loadModule("modules/visuals/ItemESP.lua")
loadModule("modules/visuals/WorldESP.lua")
loadModule("modules/misc/Freecam.lua")
loadModule("modules/combat/HeadMover.lua")
loadModule("modules/combat/TriggerBot.lua")
loadModule("modules/combat/HitboxExpander.lua")
loadModule("modules/ui/UI.lua")
