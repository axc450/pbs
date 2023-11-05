--[[
Plugin.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]
local ns              = select(2, ...)
local L               = ns.L
local UI              = ns.UI
local Addon           = ns.Addon
local ScriptManager   = ns.ScriptManager
local PluginManager   = ns.PluginManager
local PluginPrototype = ns.PluginPrototype

---- override

function PluginPrototype:GetCurrentKey()
    error(format('`%s`:GetCurrentKey not defined', self:GetPluginName()))
end

function PluginPrototype:GetTitleByKey(key)
    return self:AllocName()
end

function PluginPrototype:OnTooltipFormatting(tip, key)
    error(format('`%s`:OnTooltipFormatting not defined', self:GetPluginName()))
end

function PluginPrototype:OnExport(key)
    return
end

function PluginPrototype:OnImport(script, extra)
    return
end

---- method

function PluginPrototype:GetScript(key)
    return ScriptManager:GetScript(self, key)
end

function PluginPrototype:RemoveScript(key)
    return ScriptManager:RemoveScript(self, key)
end

function PluginPrototype:AddScript(key, script)
    return ScriptManager:AddScript(self, key, script)
end

function PluginPrototype:MoveScript(oldKey, newKey)
    return ScriptManager:MoveScript(self, oldKey, newKey)
end

function PluginPrototype:CopyScript(sourceKey, destinationKey)
    return ScriptManager:CopyScript(self, sourceKey, destinationKey)
end

function PluginPrototype:IterateScripts()
    return ScriptManager:IteratePluginScripts(self)
end

function PluginPrototype:GetPluginName()
    return self:GetName()
end

function PluginPrototype:EnableWithAddon(addon)
    return PluginManager:EnableModuleWithAddonLoaded(self, addon)
end

function PluginPrototype:SetPluginTitle(title)
    self._title = title
end

function PluginPrototype:GetPluginTitle()
    return self._title or self:GetPluginName()
end

function PluginPrototype:SetPluginIcon(icon)
    self._icon = icon
end

function PluginPrototype:GetPluginIcon()
    return self._icon or ns.ICON
end

function PluginPrototype:SetPluginNotes(notes)
    self._notes = notes
end

function PluginPrototype:GetPluginNotes()
    return self._notes
end

function PluginPrototype:OpenScriptEditor(key, name)
    return UI.MainPanel:OpenScriptDialog(self, key, name)
end

function PluginPrototype:AllocName()
    local id = 0
    for key, script in self:IterateScripts() do
        local _id = tonumber(script:GetName():match('^' .. L.DEFAULT_NEW_SCRIPT_NAME .. ' (%d+)$'))
        if _id then
            id = max(id, _id)
        end
    end
    return L.DEFAULT_NEW_SCRIPT_NAME .. ' ' .. (id + 1)
end
