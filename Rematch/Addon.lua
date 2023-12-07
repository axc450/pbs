--[[
Addon.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns    = select(2, ...)
local L     = LibStub('AceLocale-3.0'):GetLocale('PetBattleScripts')
local RematchPlugin = PetBattleScripts:NewPlugin('Rematch', 'AceEvent-3.0', 'AceHook-3.0', 'LibClass-2.0')
local GUI   = LibStub('tdGUI-1.0')

ns.RematchPlugin   = RematchPlugin

function RematchPlugin:OnInitialize()
    self:EnableWithAddon('Rematch')
    self:SetPluginTitle(L.SELECTOR_REMATCH_TITLE)
    self:SetPluginNotes(L.SELECTOR_REMATCH_NOTES)

    local rematchIcon = [[Interface\AddOns\Rematch\Textures\icon]]
    local fallbackIcon = [[Interface\Icons\inv_misc_questionmark]]
    local rematchExists = select(5, GetAddOnInfo('Rematch')) ~= 'MISSING'
    self:SetPluginIcon(rematchExists and rematchIcon or fallbackIcon)
end

function RematchPlugin:OnEnable()
    local rematchVersion = ns.Version:Current('Rematch')

    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        self.savedRematchTeams = Rematch.savedTeams
    else
        self.savedRematchTeams = RematchSaved
    end

    -- Team is deleted
    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        Rematch.events:Register(self, 'REMATCH_TEAM_DELETED', function(self, teamID)
            self:RemoveScript(teamID)
        end)
        Rematch.events:Register(self, 'REMATCH_TEAMS_WIPED', function(self)
            for key, script in self:IterateScripts() do
                self:RemoveScript(key)
            end
        end)
    else
        local function FindMenuItem(menu, text)
            for i, v in ipairs(menu) do
                if v.text == text then
                    return v
                end
            end
        end
        local deleteItem = FindMenuItem(Rematch:GetMenu('TeamMenu'), DELETE)
        self:RawHook(deleteItem, 'func', function(obj, key, ...)
            self.hooks[deleteItem].func(obj, key, ...)

            local origAccept = RematchDialog.acceptFunc
            RematchDialog.acceptFunc = function(...)
                self:RemoveScript(key)
                return origAccept(...)
            end
        end, true)
    end

    -- Maintain sync between script name, and team name
    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        local function overwriteName(self, teamID)
            local team = Rematch.savedTeams[teamID]
            local script = self:GetScript(teamID)

            if team and script then
                script:SetName(team.name)
            end
        end

        Rematch.events:Register(self, 'REMATCH_TEAM_OVERWRITTEN', function(self, overwriteID, teamID, saveMode)
            -- overwriteID is being overwritten with import, and wont have a script
            if overwriteID and not teamID then
                return self:RemoveScript(overwriteID)
            end

            -- Note: Getting the subject from the UI instead of event data is Gello-approved. A later version
            -- added it as an event argument to avoid future breakage.
            saveMode = saveMode or (Rematch.dialog:GetSubject() and Rematch.dialog:GetSubject().saveMode)
            if saveMode and saveMode ~= Rematch.constants.SAVE_MODE_EDIT then
                if teamID and self:GetScript(teamID) then -- team exists, and has script
                    self:CopyScript(teamID, overwriteID)
                else -- teamID doesnt exist or teamID has no script
                    self:RemoveScript(overwriteID)
                end
            end
            -- if SAVE_MODE_EDIT, no action is needed, REMATCH_TEAM_DELETED will delete overwriteID's script
        end)

        Rematch.events:Register(self, 'REMATCH_TEAM_UPDATED', overwriteName)
    else
        local function rename(old, new)
            if not old then
                return
            end
            if old == new then
                return
            end
            local script = self:GetScript(old)
            if not script then
                return
            end

            self:MoveScript(old, new)
        end

        local function errorhandler(err)
            return geterrorhandler()(err)
        end

        local function safecall(func, ...)
            return xpcall(func, errorhandler, ...)
        end

        self:RawHook(Rematch, 'SaveAsAccept', function(...)
            safecall(function()
                local team, key = Rematch:GetSideline()
                if not self.savedRematchTeams[key] or not Rematch:SidelinePetsDifferentThan(key) then
                    rename(Rematch:GetSidelineContext('originalKey'), key)
                end
            end)
            return self.hooks[Rematch].SaveAsAccept(...)
        end, true)

        self:SecureHook(Rematch, 'OverwriteAccept', function()
            safecall(function()
                rename(Rematch:GetSidelineContext('originalKey'), select(2, Rematch:GetSideline()))
            end)
        end)
    end

    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        Rematch.events:Register(self, 'REMATCH_TEAM_CREATED', function(self, teamID)
            self:OnImportContinuation(teamID)
        end)
    else
        -- TODO: Should be done in Rematch4 as well, but apparently nobody noticed for years,
        -- so probably not worth bothering.
    end

    -- Database script conversion. Also hook `/rematch reset everything` to allow for it to be
    -- used if update was in wrong order. There is no other way too hook this (implementation
    -- directly in handler).
    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        local convertedTeams, _ = Rematch.convert:GetConvertedTeams()
        if next(convertedTeams) ~= nil then
            self:UpdateDBRematch4To5(convertedTeams)
        else
            Rematch.events:Register(self, 'REMATCH_TEAMS_CONVERTED', self.UpdateDBRematch4To5)
        end

        self:Hook(Rematch.dialog, 'Register', function(_, name, info)
            if name == 'ResetEverything' then
                self:Hook(info, 'acceptFunc', self.ResetEverything)
            end
        end)
    end

    -- UI
    self:SetupUI()
end

function RematchPlugin:OnDisable()
    local rematchVersion = ns.Version:Current('Rematch')

    self:TeardownUI()

    self:UnhookAll()

    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        Rematch.events:Unregister(self, 'REMATCH_TEAMS_CONVERTED')
        Rematch.events:Unregister(self, 'REMATCH_TEAM_OVERWRITTEN')
        Rematch.events:Unregister(self, 'REMATCH_TEAM_UPDATED')
        Rematch.events:Unregister(self, 'REMATCH_TEAMS_WIPED')
        Rematch.events:Unregister(self, 'REMATCH_TEAM_DELETED')
        Rematch.events:Unregister(self, 'REMATCH_TEAM_CREATED')
    end

    self.savedRematchTeams = nil
end

function RematchPlugin:GetCurrentKey()
    local rematchVersion = ns.Version:Current('Rematch')

    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        return Rematch.settings.currentTeamID
    else
        return RematchSettings.loadedTeam
    end
end

function RematchPlugin:IterateKeys()
    local rematchVersion = ns.Version:Current('Rematch')

    if not rematchVersion then
        return
    end

    local iter,tbl
    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        iter,tbl = Rematch.savedTeams:AllTeams()
    else
        iter,tbl = pairs(RematchSaved)
    end

    return coroutine.wrap(function()
        for key in iter,tbl do
            coroutine.yield(key)
        end
    end)
end

function RematchPlugin:GetTitleByKey(key)
    local rematchVersion = ns.Version:Current('Rematch')

    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        return Rematch.savedTeams[key].name
    else
        return Rematch:GetTeamTitle(key)
    end
end

function RematchPlugin:OnTooltipFormatting(tip, key)
    local rematchVersion = ns.Version:Current('Rematch')

    if not rematchVersion then
        tip:AddLine(L.SELECTOR_REMATCH_CANT_FORMAT_TOOLTIP_REMATCH_NOT_LOADED, RED_FONT_COLOR:GetRGB())
        return
    end

    local GetTeamName
    local GetTeamPets
    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        GetTeamName = function(key) return Rematch.savedTeams[key].name end
        GetTeamPets = function(team, i) return team.pets[i] end
    else
        GetTeamName = function(key) return Rematch:GetTeamTitle(key) end
        GetTeamPets = function(team, i) return team[i][1] end
    end

    local saved = self.savedRematchTeams[key]
    if not saved then
        tip:AddLine(L.SELECTOR_REMATCH_NO_TEAM_FOR_SCRIPT, RED_FONT_COLOR:GetRGB())
    else
        tip:AddLine(format(L.SELECTOR_REMATCH_TEAM_FORMAT, GetTeamName(key)), GREEN_FONT_COLOR:GetRGB())

        for i=1,3 do
            local petID = GetTeamPets(saved, i)
            local petInfo = Rematch.petInfo:Fetch(petID)
            if petInfo.icon and petInfo.name then
                tip:AddLine(format([[|T%s:20|t %s]],petInfo.icon,petInfo.name))
            else
                tip:AddLine(SEARCH_LOADING_TEXT)
            end
        end
    end
end

function RematchPlugin:OnExportImpl(key)
    local rematchVersion = ns.Version:Current('Rematch')

    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        return Rematch.teamStrings:ExportTeam(key)
    else
        Rematch:SetSideline(key, self.savedRematchTeams[key])
        return Rematch:ConvertSidelineToString()
    end
end

function RematchPlugin:OnExport(key)
    local rematchVersion = ns.Version:Current('Rematch')

    if not rematchVersion then
        return
    end

    if not self.savedRematchTeams[key] then
        return
    end

    return self:OnExportImpl(key)
end

local importTeamIdCounter = 0
local importTeamIdMapping = {}

function RematchPlugin:OnImport(script, extra)
    local rematchVersion = ns.Version:Current('Rematch')

    if not rematchVersion then
        return
    end

    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        local temporaryTeamId = 'temporary-team-id-' .. importTeamIdCounter
        importTeamIdCounter = importTeamIdCounter + 1
        self:MoveScript(script:GetKey(), temporaryTeamId)
        importTeamIdMapping[extra] = temporaryTeamId

        Rematch.dialog:ShowDialog('ImportTeams')
        Rematch.dialog.Canvas.MultiLineEditBox:SetText(extra)
    else
        Rematch:ShowImportDialog()
        RematchDialog.MultiLine.EditBox:SetText(extra)
    end
end

function RematchPlugin:OnImportContinuation(addedTeamID)
    local extra = self:OnExportImpl(addedTeamID)
    local temporaryTeamId = importTeamIdMapping[extra]

    if not temporaryTeamId then
        return
    end

    importTeamIdMapping[extra] = nil

    self:MoveScript(temporaryTeamId, addedTeamID)
end

function RematchPlugin.ResetEverything()
    local scriptsDB = PetBattleScripts.db.global.scripts

    scriptsDB.Rematch = CopyTable(scriptsDB.Rematch4)
    wipe(scriptsDB.Rematch4)
end

function RematchPlugin:UpdateDBRematch4To5(convertedTeams)
    -- Backup old scripts.
    local scriptsDB = PetBattleScripts.db.global.scripts
    if scriptsDB.Rematch4 then
        -- Already did an upgrade at some point, so don't do it again.
        return
    end
    scriptsDB.Rematch4 = CopyTable(scriptsDB.Rematch)

    C_Timer.After(0.9, function()
        GUI:Notify{
            text = format('%s\n|cff00ffff%s|r', ns.L.ADDON_NAME, ns.L.SELECTOR_REMATCH_4_TO_5_UPDATE_NOTE),
            icon = ns.ICON,
            duration = -1,
        }
    end)

    -- First we need a cache list of all of our scripts, so we can modify our scripts
    -- database without messing up the loops.
    local scriptList = {}
    for key, script in self:IterateScripts() do
        scriptList[key] = script
    end

    -- Second we can migrate scripts.
    for oldTeamID, script in pairs(scriptList) do
        local newTeamID = convertedTeams[oldTeamID]
        local newTeam = Rematch.savedTeams[newTeamID]
        if newTeamID and newTeam then
            self:MoveScript(oldTeamID, newTeamID)
            self:GetScript(newTeamID):SetName(newTeam.name)
        end
    end

    -- Warn about scripts that are not linked to anything.
    for teamID, script in self:IterateScripts() do
        if not self.savedRematchTeams[teamID] then
            C_Timer.After(0.9, function()
                GUI:Notify{
                    text = format('%s\n|cff00ffff%s|r', ns.L.ADDON_NAME, format(ns.L.SELECTOR_REMATCH_4_TO_5_UPDATE_ORPHAN, script:GetName(), teamID)),
                    icon = ns.ICON,
                    duration = -1,
                }
            end)
        end
    end
end
