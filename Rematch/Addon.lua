--[[
Addon.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns    = select(2, ...)
local L     = LibStub('AceLocale-3.0'):GetLocale('PetBattleScripts')
local RematchPlugin = PetBattleScripts:NewPlugin('Rematch', 'AceEvent-3.0', 'AceHook-3.0', 'LibClass-2.0')

ns.RematchPlugin   = RematchPlugin

function RematchPlugin:OnInitialize()
    self:EnableWithAddon('Rematch')
    self:SetPluginTitle(L.SELECTOR_REMATCH_TITLE)
    self:SetPluginNotes(L.SELECTOR_REMATCH_NOTES)
    self:SetPluginIcon([[Interface\AddOns\Rematch\Textures\icon]])
end

function RematchPlugin:GetCurrentKey()
    return RematchSettings.loadedTeam
end

function RematchPlugin:IterateKeys()
    return coroutine.wrap(function()
        for key in pairs(RematchSaved) do
            coroutine.yield(key)
        end
    end)
end

function RematchPlugin:GetTitleByKey(key)
    return Rematch:GetTeamTitle(key)
end

function RematchPlugin:OnTooltipFormatting(tip, key)
    local saved = RematchSaved[key]
    if not saved then
        tip:AddLine(L.SELECTOR_REMATCH_NO_TEAM_FOR_SCRIPT, RED_FONT_COLOR:GetRGB())
    else
        tip:AddLine(format(L.SELECTOR_REMATCH_TEAM_FORMAT, Rematch:GetTeamTitle(key)), GREEN_FONT_COLOR:GetRGB())

		for i=1,3 do
			local petID = saved[i][1]
			local petInfo = Rematch.petInfo:Fetch(petID)
			tip:AddLine(format([[|T%s:20|t %s]],petInfo.icon,petInfo.name))
		end
    end
end
