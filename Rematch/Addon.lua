--[[
Addon.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns    = select(2, ...)
local L     = LibStub('AceLocale-3.0'):GetLocale('tdBattlePetScript_Rematch')
local Addon = tdBattlePetScript:NewPlugin('Rematch', 'AceEvent-3.0', 'AceHook-3.0', 'LibClass-2.0')

ns.Addon   = Addon

function Addon:OnInitialize()
    self:EnableWithAddon('Rematch')
    self:SetPluginTitle(L.TITLE)
    self:SetPluginNotes(L.NOTES)
    self:SetPluginIcon([[Interface\Icons\PetJournalPortrait]])
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

function Addon:GetPetTip(id)
    if not id then
        return ' '
    end
    local _, customName, _, _, _, _, _, name, icon, petType = C_PetJournal.GetPetInfoByPetID(id)
    if not name then
        return ' '
    end
    local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(id)

    return format('|T%s:20|t %s%s|r', icon, ITEM_QUALITY_COLORS[rarity-1].hex, customName or name)
end

function Addon:OnTooltipFormatting(tip, key)
    local saved = RematchSaved[key]
    if not saved then
        tip:AddLine(L.NO_TEAM_FOR_SCRIPT, RED_FONT_COLOR:GetRGB())
    else
        tip:AddLine(L['Team:'] .. Rematch:GetTeamTitle(key), GREEN_FONT_COLOR:GetRGB())
        tip:AddLine(' ')

        for i, v in ipairs(saved) do
            if v[1] ~= 0 then
                tip:AddLine(self:GetPetTip(v[1]), HIGHLIGHT_FONT_COLOR:GetRGB())
            else
                tip:AddLine(format([[|TInterface\AddOns\Rematch\Textures\levelingicon:20|t %s]], L.LEVELING_FIELD), HIGHLIGHT_FONT_COLOR:GetRGB())
            end
        end
    end
end
