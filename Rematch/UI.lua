--[[
UI.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns = select(2, ...)

local Addon = ns.Addon
local L     = LibStub('AceLocale-3.0'):GetLocale('PetBattleScripts')

-- Team menu entry to edit script
local teamMenu = {
    text = L.WRITE_SCRIPT,
    func = function(_, key, ...)
        Addon:OpenScriptEditor(key, Addon:GetTitleByKey(key))
    end
}

function Addon:OnEnable()
    local afterText = Rematch.localization['Set Notes'] -- Use Rematch's locale string.
    Rematch.menus:AddToMenu('TeamMenu', teamMenu, afterText)
    Rematch.menus:AddToMenu('LoadedTeamMenu', teamMenu, afterText)

    -- Button to indicate a script exists
    local icon = 'Interface/AddOns/tdBattlePetScript/Rematch/Textures/ScriptIcon'
    Rematch.badges:RegisterBadge('teams', 'PetBattleScripts', icon, nil, function(teamID)
        return teamID and Addon:GetScript(teamID)
    end)

    -- Team is deleted
    Rematch.events:Register(Addon, 'REMATCH_TEAM_DELETED', function(self, teamID)
        Addon:RemoveScript(teamID)
    end)

    -- When a script is added/removed, refresh the teams list.
    self:RegisterMessage('PET_BATTLE_SCRIPT_SCRIPT_LIST_UPDATE')
end

function Addon:PET_BATTLE_SCRIPT_SCRIPT_LIST_UPDATE()
    if Rematch.teamsPanel:IsVisible() then
        Rematch.teamsPanel:Refresh()
    end
end


function Addon:OnDisable()
    -- TODO: Hide menu, disable badge
end

function Addon:OnExport(key)
    --if RematchSaved[key] then
    --    Rematch:SetSideline(key, RematchSaved[key])
    --    return Rematch:ConvertSidelineToString()
    --end
end

function Addon:OnImport(data)
    --Rematch:ShowImportDialog()
    --RematchDialog.MultiLine.EditBox:SetText(data)
end
