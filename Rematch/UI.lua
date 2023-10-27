--[[
UI.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns = select(2, ...)

local Addon = ns.Addon
local L     = LibStub('AceLocale-3.0'):GetLocale('PetBattleScripts')

local scriptMenu = {
    text = L.EDITOR_CREATE_SCRIPT,
    func = function(_, key, ...)
        Addon:OpenScriptEditor(key, Addon:GetTitleByKey(key))
    end
}

function Addon:OnEnable()
    -- Add menu to edit script
    local afterText = Rematch.localization['Set Notes'] -- Use Rematch's locale string.
    Rematch.menus:AddToMenu('TeamMenu', scriptMenu, afterText)
    Rematch.menus:AddToMenu('LoadedTeamMenu', scriptMenu, afterText)

    -- Button to indicate a script exists
    local icon = 'Interface/AddOns/tdBattlePetScript/Rematch/Textures/ScriptIcon'
    Rematch.badges:RegisterBadge('teams', 'PetBattleScripts', icon, nil, function(teamID)
        return teamID and self:GetScript(teamID)
    end)

    -- Team is deleted
    Rematch.events:Register(self, 'REMATCH_TEAM_DELETED', function(self, teamID)
        self:RemoveScript(teamID)
    end)

    -- Maintain sync between script name, and team name
    Rematch.events:Register(self, 'REMATCH_TEAM_UPDATED', function(self, teamID)
        local team = Rematch.savedTeams[teamID]
        local script = self:GetScript(teamID)

        if team and script then
            script:SetName(team.name)
        end
    end)

    -- TODO: what do we want to do when a team is overwritten? delete the script? keep it? migrate the old script to the new teamID?
    --Rematch.events:Register(self, 'REMATCH_TEAM_OVERWRITTEN', function(self, teamID, oldTeamID) end)

    -- All teams are wiped, wipe all scripts.
    Rematch.events:Register(self, 'REMATCH_TEAMS_WIPED', function(self)
        for key in self:IterateScripts() do
            self:RemoveScript(key)
        end
    end)

    -- Database script conversion.
    Rematch.events:Register(self, 'REMATCH_TEAMS_CONVERTED', self.UpdateDB)

    -- Hook `/rematch reset everything` This is a messy way to hook that function
    self:Hook(Rematch.dialog, 'Register', function(_, name, info)
        if name == 'ResetEverything' then
            self:Hook(info, 'acceptFunc', self.ResetEverything)
        end
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
    -- TODO: hide menu, disable badge?

    -- Is there even a way to disable this plugin after its loaded? (outisde of source)

    -- Should we Unregister REMATCH_TEAM_DELETED?
    -- If a team is deleted when this plugin is disabled, matching scripts will
    -- be made orphans, and if a new team is created with that same key, the
    -- old script will be matched with it.
end

function Addon:OnExport(key)
    --if Rematch.savedTeams[key] then
    --    return Rematch.teamStrings:ExportTeam(key)
    --end
end

function Addon:OnImport(data)
    -- TODO: Bug. (Do people even use this?)
    --   When importing a PBS script, the key is preset in the data,
    --   but it wont match up after importing this Rematch team.

    --Rematch.dialog:ShowDialog('ImportTeams')
    --Rematch.dialog.Canvas.MultiLineEditBox:SetText(data)
end
