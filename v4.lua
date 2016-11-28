--[[
v4.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns = select(2, ...)
if ns.Version ~= 4 then return end

local Addon = ns.Addon
local L     = LibStub('AceLocale-3.0'):GetLocale('tdBattlePetScript_Rematch')

local teamMenu = {
    text = L.WRITE_SCRIPT,
    func = function(_, key, ...)
        Addon:OpenScriptEditor(key, Rematch:GetTeamTitle(key))
    end
}

function Addon:OnEnable()
    tinsert(Rematch:GetMenu('TeamMenu'), 6, teamMenu)

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

    self:SecureHook(RematchTeamPanel, 'FillTeamButton', function(_, button, key)
        if self:GetScript(key) then
            button.Name:SetTextColor(0, 1, 0)
        else
            button.Name:SetTextColor(1, 1, 1)
        end
    end)

    self:HookScript(RematchJournal, 'OnShow', function(self)
        CollectionsJournal:SetAttribute('UIPanelLayout-width', 870)
        UpdateUIPanelPositions()
    end)
    self:HookScript(RematchJournal, 'OnHide', function(self)
        CollectionsJournal:SetAttribute('UIPanelLayout-width', 710)
        UpdateUIPanelPositions()
    end)
end

function Addon:OnDisable()
    tDeleteItem(Rematch:GetMenu('TeamMenu'), teamMenu)
end

function Addon:OnExport(key)
    if RematchSaved[key] then
        Rematch:SetSideline(key, RematchSaved[key])
        return Rematch:ConvertSidelineToString()
    end
end

function Addon:OnImport(data)
    Rematch:ShowImportDialog()
    RematchDialog.MultiLine.EditBox:SetText(data)
end
