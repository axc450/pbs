--[[
Addon.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns    = select(2, ...)
local L     = LibStub('AceLocale-3.0'):GetLocale('PetBattleScripts')
local RematchPlugin = PetBattleScripts:NewPlugin('Rematch', 'AceEvent-3.0', 'AceHook-3.0', 'LibClass-2.0')
local GUI   = LibStub('tdGUI-1.0')
local Addon    = ns.Addon
local Director = ns.Director

ns.RematchPlugin   = RematchPlugin

function RematchPlugin:OnInitialize()
    self:EnableWithAddon('Rematch')
    self:SetPluginTitle(L.SELECTOR_REMATCH_TITLE)
    self:SetPluginNotes(L.SELECTOR_REMATCH_NOTES)

    local rematchIcon = [[Interface\AddOns\Rematch\Textures\icon]]
    local fallbackIcon = [[Interface\Icons\inv_misc_questionmark]]
    local rematchExists = select(5, C_AddOns.GetAddOnInfo('Rematch')) ~= 'MISSING'
    self:SetPluginIcon(rematchExists and rematchIcon or fallbackIcon)
end

local function runIfOnceOutOfCombat(fun)
    if InCombatLockdown() then
        EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_REGEN_ENABLED", fun)
    else
        C_Timer.After(0, fun)
    end
end

function RematchPlugin:OnEnable()
    local rematchVersion = ns.Version:Current('Rematch')

    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        self.savedRematchTeams = Rematch.savedTeams
    else
        self.savedRematchTeams = RematchSaved

        C_Timer.After(1, function()
            runIfOnceOutOfCombat(function()
                GUI:Notify({
                    text = format('%s\n|cff00ffff%s|r', ns.L.ADDON_NAME, ns.L.REMATCH4_DEPRECATED),
                    icon = ns.ICON,
                    duration = 30,
                })
            end)
        end)
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

            self:OnImportContinuation(teamID)
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

            self:OnImportContinuation(teamID)
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

    if rematchVersion >= ns.Version:New(5, 0, 0, 0) then
        C_Timer.After(2, function()
            runIfOnceOutOfCombat(function()
                self:CheckAllTeamsForScriptsInNotes()
            end)
        end)
    end
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
        self:MaybeTakeScriptFromNotes(addedTeamID, self.savedRematchTeams[addedTeamID])
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
        GUI:Notify({
            text = format('%s\n|cff00ffff%s|r', ns.L.ADDON_NAME, ns.L.SELECTOR_REMATCH_4_TO_5_UPDATE_NOTE),
            icon = ns.ICON,
            duration = -1,
        })
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
                GUI:Notify({
                    text = format('%s\n|cff00ffff%s|r', ns.L.ADDON_NAME, format(ns.L.SELECTOR_REMATCH_4_TO_5_UPDATE_ORPHAN, script:GetName(), teamID)),
                    icon = ns.ICON,
                    duration = -1,
                })
            end)
        end
    end
end

local section           = 'PET BATTLE SCRIPT'
local patternSeps       = '%-%-%-%-%-'
local outputSeps        = '-----'
local patternBegin      = patternSeps .. 'BEGIN ' .. section .. patternSeps
local outputBegin       = outputSeps  .. 'BEGIN ' .. section .. outputSeps
local patternEnd        = patternSeps .. 'END '   .. section .. patternSeps
local outputEnd         = outputSeps  .. 'END '   .. section .. outputSeps
local patternScriptNote = '\n*' .. patternBegin .. '\n(.*)' .. patternEnd .. '\n*'
local outputScriptNoteB = '\n'  .. outputBegin .. '\n'
local outputScriptNoteA =                             '\n'  .. outputEnd .. '\n'

function RematchPlugin:_UpdateTeamNote(key, note)
    if self.savedRematchTeams[key].notes == note then
        return
    end

    self.savedRematchTeams[key].notes = note
    Rematch.events:Fire("REMATCH_NOTES_CHANGED", key)

    if not self.hasRematchUiUpdateQueued then
        self.hasRematchUiUpdateQueued = true
        runIfOnceOutOfCombat(function()
            Rematch.frame:Update()
            self.hasRematchUiUpdateQueued = false
        end)
    end
end

local function htmlUnescape(str)
    str = string.gsub(str, '&Aacute;', 'Á')
    str = string.gsub(str, '&aacute;', 'á')
    str = string.gsub(str, '&Acirc;', 'Â')
    str = string.gsub(str, '&acirc;', 'â')
    str = string.gsub(str, '&acute;', '´')
    str = string.gsub(str, '&AElig;', 'Æ')
    str = string.gsub(str, '&aelig;', 'æ')
    str = string.gsub(str, '&Agrave;', 'À')
    str = string.gsub(str, '&agrave;', 'à')
    str = string.gsub(str, '&Aring;', 'Å')
    str = string.gsub(str, '&aring;', 'å')
    str = string.gsub(str, '&Atilde;', 'Ã')
    str = string.gsub(str, '&atilde;', 'ã')
    str = string.gsub(str, '&Auml;', 'Ä')
    str = string.gsub(str, '&auml;', 'ä')
    str = string.gsub(str, '&brvbar;', '¦')
    str = string.gsub(str, '&Ccedil;', 'Ç')
    str = string.gsub(str, '&ccedil;', 'ç')
    str = string.gsub(str, '&cedil;', '¸')
    str = string.gsub(str, '&cent;', '¢')
    str = string.gsub(str, '&copy;', '©')
    str = string.gsub(str, '&curren;', '¤')
    str = string.gsub(str, '&deg;', '°')
    str = string.gsub(str, '&divide;', '÷')
    str = string.gsub(str, '&Eacute;', 'É')
    str = string.gsub(str, '&eacute;', 'é')
    str = string.gsub(str, '&Ecirc;', 'Ê')
    str = string.gsub(str, '&ecirc;', 'ê')
    str = string.gsub(str, '&Egrave;', 'È')
    str = string.gsub(str, '&egrave;', 'è')
    str = string.gsub(str, '&ETH;', 'Ð')
    str = string.gsub(str, '&eth;', 'ð')
    str = string.gsub(str, '&Euml;', 'Ë')
    str = string.gsub(str, '&euml;', 'ë')
    str = string.gsub(str, '&euro;', '€')
    str = string.gsub(str, '&frac12;', '½')
    str = string.gsub(str, '&frac14;', '¼')
    str = string.gsub(str, '&frac34;', '¾')
    str = string.gsub(str, '&Iacute;', 'Í')
    str = string.gsub(str, '&iacute;', 'í')
    str = string.gsub(str, '&Icirc;', 'Î')
    str = string.gsub(str, '&icirc;', 'î')
    str = string.gsub(str, '&iexcl;', '¡')
    str = string.gsub(str, '&Igrave;', 'Ì')
    str = string.gsub(str, '&igrave;', 'ì')
    str = string.gsub(str, '&iquest;', '¿')
    str = string.gsub(str, '&Iuml;', 'Ï')
    str = string.gsub(str, '&iuml;', 'ï')
    str = string.gsub(str, '&laquo;', '«')
    str = string.gsub(str, '&macr;', '¯')
    str = string.gsub(str, '&micro;', 'µ')
    str = string.gsub(str, '&middot;', '·')
    str = string.gsub(str, '&nbsp;', ' ')
    str = string.gsub(str, '&not;', '¬')
    str = string.gsub(str, '&Ntilde;', 'Ñ')
    str = string.gsub(str, '&ntilde;', 'ñ')
    str = string.gsub(str, '&Oacute;', 'Ó')
    str = string.gsub(str, '&oacute;', 'ó')
    str = string.gsub(str, '&Ocirc;', 'Ô')
    str = string.gsub(str, '&ocirc;', 'ô')
    str = string.gsub(str, '&Ograve;', 'Ò')
    str = string.gsub(str, '&ograve;', 'ò')
    str = string.gsub(str, '&ordf;', 'ª')
    str = string.gsub(str, '&ordm;', 'º')
    str = string.gsub(str, '&Oslash;', 'Ø')
    str = string.gsub(str, '&oslash;', 'ø')
    str = string.gsub(str, '&Otilde;', 'Õ')
    str = string.gsub(str, '&otilde;', 'õ')
    str = string.gsub(str, '&Ouml;', 'Ö')
    str = string.gsub(str, '&ouml;', 'ö')
    str = string.gsub(str, '&para;', '¶')
    str = string.gsub(str, '&plusmn;', '±')
    str = string.gsub(str, '&pound;', '£')
    str = string.gsub(str, '&raquo;', '»')
    str = string.gsub(str, '&reg;', '®')
    str = string.gsub(str, '&sect;', '§')
    str = string.gsub(str, '&shy;', '­')
    str = string.gsub(str, '&sup1;', '¹')
    str = string.gsub(str, '&sup2;', '²')
    str = string.gsub(str, '&sup3;', '³')
    str = string.gsub(str, '&szlig;', 'ß')
    str = string.gsub(str, '&THORN;', 'Þ')
    str = string.gsub(str, '&thorn;', 'þ')
    str = string.gsub(str, '&times;', '×')
    str = string.gsub(str, '&Uacute;', 'Ú')
    str = string.gsub(str, '&uacute;', 'ú')
    str = string.gsub(str, '&Ucirc;', 'Û')
    str = string.gsub(str, '&ucirc;', 'û')
    str = string.gsub(str, '&Ugrave;', 'Ù')
    str = string.gsub(str, '&ugrave;', 'ù')
    str = string.gsub(str, '&uml;', '¨')
    str = string.gsub(str, '&Uuml;', 'Ü')
    str = string.gsub(str, '&uuml;', 'ü')
    str = string.gsub(str, '&Yacute;', 'Ý')
    str = string.gsub(str, '&yacute;', 'ý')
    str = string.gsub(str, '&yen;', '¥')
    str = string.gsub(str, '&yuml;', 'ÿ')
    str = string.gsub(str, '&#(%d+);', function(n) return string.char(n) end)
    str = string.gsub(str, '&#x(%d+);', function(n) return string.char(tonumber(n,16)) end)
    str = string.gsub(str, '&amp;', '&') -- Be sure to do this after all others
    return str
end

function RematchPlugin:MaybeTakeScriptFromNotes(key, team)
    local note = self.savedRematchTeams[key].notes

    if not note then
        return
    end

    local len = string.len(note)
    local istart, iend, code = string.find(note, patternScriptNote)

    if not istart or not iend or not code then
        return
    end

    -- Hack-around for bad Xufu exports
    code = htmlUnescape(code)

    local function queueError(team, err)
        if not self.failedScriptImports then
            C_Timer.After(5, function()
                local fails = self.failedScriptImports
                self.failedScriptImports = nil

                local errors = ''
                for key, info in pairs(fails) do
                    errors = errors .. format(L.REMATCH_NOTE_SCRIPT_IMPORT_FAIL_LINE, info.name, info.error) .. '\n'
                end

                GUI:Notify({
                    text = format('%s\n|cff00ffff%s|r', ns.L.ADDON_NAME, format(L.REMATCH_NOTE_SCRIPT_IMPORT_FAIL, errors)),
                    icon = ns.ICON,
                    duration = -1,
                })
            end)
        end
        self.failedScriptImports = self.failedScriptImports or {}
        self.failedScriptImports[key] = {name = team.name, error = err}
    end

    local checkedCode, err = Director:BuildScript(code)
    if not checkedCode then
        queueError(team, err)
        return
    end
    checkedCode = Director:BeautyScript(checkedCode)

    local pre = istart > 1 and string.sub(note, 1, istart - 1) or nil
    local post = iend < len and string.sub(note, iend + 1, len) or nil

    local existingScript = self:GetScript(key)
    if existingScript then
        local checkedExistingCode, err = Director:BuildScript(existingScript:GetCode())
        if err or Director:BeautyScript(checkedExistingCode) ~= checkedCode then
            queueError(team, L.REMATCH_NOTE_SCRIPT_IMPORT_FAIL_EXIST_DIFFERENT)
            return
        end
    else
        local scriptData = {name = team.name, code = checkedCode,}
        self:AddScript(key, Addon:GetClass('Script'):New(scriptData, self, key))
    end
    self:_UpdateTeamNote(key, pre and post and (pre .. '\n' .. post) or pre or post)
end

function RematchPlugin:CheckAllTeamsForScriptsInNotes()
    for key, team in Rematch.savedTeams:AllTeams() do
        self:MaybeTakeScriptFromNotes(key, team)
    end
end

function RematchPlugin:AddScriptToNote(key)
    local existingScript = self:GetScript(key)
    if not existingScript then
        return
    end

    local checkedExistingCode, err = Director:BuildScript(existingScript:GetCode())
    if err then
        return
    end
    local code = Director:BeautyScript(checkedExistingCode)

    local note = self.savedRematchTeams[key].notes or ''
    self:_UpdateTeamNote(key, note .. outputScriptNoteB .. code .. outputScriptNoteA)
end
