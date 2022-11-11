--[[
Addon.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns    = select(2, ...)
local L     = LibStub('AceLocale-3.0'):GetLocale('PetBattleScripts')
local Addon = PetBattleScripts:NewPlugin('Rematch', 'AceEvent-3.0', 'AceHook-3.0', 'LibClass-2.0')

ns.Addon   = Addon

function Addon:OnInitialize()
    self:EnableWithAddon('Rematch')
    self:SetPluginTitle(L.TITLE)
    self:SetPluginNotes(L.NOTES)
    self:SetPluginIcon([[Interface\Icons\Icon_petfamily_dragon]])
end

function Addon:GetCurrentKey()
    return RematchSettings.loadedTeam
end

function Addon:IterateKeys()
    return coroutine.wrap(function()
        for key in pairs(RematchSaved) do
            coroutine.yield(key)
        end
    end)
end

function Addon:GetTitleByKey(key)
    return Rematch:GetTeamTitle(key)
end

function Addon:OnTooltipFormatting(tip, key)
    local saved = RematchSaved[key]
    if not saved then
        tip:AddLine(L.NO_TEAM_FOR_SCRIPT, RED_FONT_COLOR:GetRGB())
    else
        tip:AddLine(L['TEAM'] .. Rematch:GetTeamTitle(key), GREEN_FONT_COLOR:GetRGB())
        tip:AddLine(' ')

		for i=1,3 do
			local petID = saved[i][1]
			local petInfo = Rematch.petInfo:Fetch(petID)
			tip:AddLine(format([[|T%s:20|t %s]],petInfo.icon,petInfo.name))
		end
    end
end
