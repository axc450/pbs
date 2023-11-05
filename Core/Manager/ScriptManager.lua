--[[
ScriptManager.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns            = select(2, ...)
local Addon         = ns.Addon
local ScriptManager = Addon:NewModule('ScriptManager', 'AceEvent-3.0')

local db = setmetatable({}, {
    __index = function(t, k)
        t[k] = {}
        return t[k]
    end
})

function ScriptManager:AddScript(plugin, key, script)
    db[plugin][key] = script
    self:SendMessage('PET_BATTLE_SCRIPT_SCRIPT_ADDED', plugin, key, script)
    self:SendMessage('PET_BATTLE_SCRIPT_SCRIPT_LIST_UPDATE')
end

function ScriptManager:GetScript(plugin, key)
    return db[plugin][key]
end

function ScriptManager:RemoveScript(plugin, key)
    db[plugin][key] = nil
    self:SendMessage('PET_BATTLE_SCRIPT_SCRIPT_REMOVED', plugin, key)
    self:SendMessage('PET_BATTLE_SCRIPT_SCRIPT_LIST_UPDATE')
end

function ScriptManager:MoveScript(plugin, oldKey, newKey)
    local script = db[plugin][oldKey]
    db[plugin][oldKey] = nil
    script = Addon:GetClass('Script'):New(script:GetDB(), script:GetPlugin(), newKey)
    db[plugin][newKey] = script
    self:SendMessage('PET_BATTLE_SCRIPT_SCRIPT_REMOVED', plugin, oldKey)
    self:SendMessage('PET_BATTLE_SCRIPT_SCRIPT_ADDED', plugin, newKey, script)
    self:SendMessage('PET_BATTLE_SCRIPT_SCRIPT_LIST_UPDATE')
end

function ScriptManager:CopyScript(plugin, sourceKey, destinationKey)
    local script = db[plugin][sourceKey]
    script = Addon:GetClass('Script'):New(CopyTable(script:GetDB()), script:GetPlugin(), destinationKey)
    db[plugin][destinationKey] = script
    self:SendMessage('PET_BATTLE_SCRIPT_SCRIPT_ADDED', plugin, destinationKey, script)
    self:SendMessage('PET_BATTLE_SCRIPT_SCRIPT_LIST_UPDATE')
end

function ScriptManager:IteratePluginScripts(plugin)
    return pairs(db[plugin])
end
