--[[
Addon.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local L             = LibStub('AceLocale-3.0'):GetLocale('tdBattlePetScript_Rematch')
local Addon         = LibStub('AceAddon-3.0'):GetAddon('tdBattlePetScript')
local PluginRematch = Addon:NewPlugin('Rematch', 'AceEvent-3.0', 'AceHook-3.0')

function PluginRematch:OnInitialize()
    self:EnableWithAddon('Rematch')
    self:SetPluginTitle(L.TITLE)
    self:SetPluginNotes(L.NOTES)
    self:SetPluginIcon([[Interface\Icons\PetJournalPortrait]])

    self.teamMenu = {
        text = L.WRITE_SCRIPT,
        func = function(_, key)
            self:OpenScriptEditor(key, Rematch:GetTeamTitle(key))
        end
    }

end

function PluginRematch:OnEnable()
    tinsert(Rematch:GetMenu('TeamMenu'), 6, self.teamMenu)

    ---- Delete Team

    self.teamKey = nil
    self:Hook(RematchDialog, 'AcceptOnClick', function(...)
        if RematchDialog.dialogName ~= 'DeleteTeam' then
            return
        end
        if self.teamKey then
            self:RemoveScript(self.teamKey)
        end
    end)
    self:Hook(RematchDialog, 'FillTeam', function(_, _, team)
        if RematchDialog.dialogName ~= 'DeleteTeam' then
            return
        end
        for key, v in pairs(RematchSaved) do
            if team == v then
                self.teamKey = key
                return
            end
        end
    end)

    ---- Fix width

    self:HookScript(RematchJournal, 'OnShow', function(self)
        CollectionsJournal:SetAttribute('UIPanelLayout-width', 870)
        UpdateUIPanelPositions()
    end)
    self:HookScript(RematchJournal, 'OnHide', function(self)
        CollectionsJournal:SetAttribute('UIPanelLayout-width', 710)
        UpdateUIPanelPositions()
    end)
end

function PluginRematch:OnDisable()
    tDeleteItem(Rematch:GetMenu('TeamMenu'), self.teamMenu)
end

function PluginRematch:GetCurrentKey()
    return RematchSettings.loadedTeam
end

function PluginRematch:GetPetTip(id)
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

function PluginRematch:OnTooltipFormatting(tip, key)
    local saved = RematchSaved[key]
    if not saved then
        tip:AddLine('当前没有队伍匹配到该脚本。', RED_FONT_COLOR:GetRGB())
    else
        tip:AddLine('队伍：' .. Rematch:GetTeamTitle(key), GREEN_FONT_COLOR:GetRGB())
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

function PluginRematch:OnExport(key)
    if RematchSaved[key] then
        Rematch:SetSideline(key, RematchSaved[key])
        return Rematch:ConvertSidelineToString()
    end
end

function PluginRematch:OnImport(data)
    Rematch:ShowImportDialog()
    RematchDialog.MultiLine.EditBox:SetText(data)
end
