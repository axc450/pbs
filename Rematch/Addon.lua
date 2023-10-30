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

    local rematchIcon = [[Interface\AddOns\Rematch\Textures\icon]]
    local fallbackIcon = [[Interface\Icons\inv_misc_questionmark]]
    local rematchExists = select(5, GetAddOnInfo('Rematch')) ~= 'MISSING'
    self:SetPluginIcon(rematchExists and rematchIcon or fallbackIcon)
end

function RematchPlugin:OnEnable()
    local rematchVersion = ns.Version:Current('Rematch')

    if rematchVersion < ns.Version:New(5, 0, 0, 0) then
        self.savedRematchTeams = RematchSaved
    end

    -- Team is deleted
    if rematchVersion < ns.Version:New(5, 0, 0, 0) then
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
    if rematchVersion < ns.Version:New(5, 0, 0, 0) then
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

            self:RemoveScript(old)
            self:AddScript(new, script)
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

    -- UI
    self:SetupUI()
end

function RematchPlugin:OnDisable()
    local rematchVersion = ns.Version:Current('Rematch')

    self:TeardownUI()

    self:UnhookAll()

    self.savedRematchTeams = nil
end

function RematchPlugin:GetCurrentKey()
    local rematchVersion = ns.Version:Current('Rematch')

    if rematchVersion < ns.Version:New(5, 0, 0, 0) then
        return RematchSettings.loadedTeam
    end
end

function RematchPlugin:IterateKeys()
    local rematchVersion = ns.Version:Current('Rematch')

    if not rematchVersion then
        return
    end

    return coroutine.wrap(function()
        for key in pairs(self.savedRematchTeams) do
            coroutine.yield(key)
        end
    end)
end

function RematchPlugin:GetTitleByKey(key)
    local rematchVersion = ns.Version:Current('Rematch')

    if rematchVersion < ns.Version:New(5, 0, 0, 0) then
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
    if rematchVersion < ns.Version:New(5, 0, 0, 0) then
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
            tip:AddLine(format([[|T%s:20|t %s]],petInfo.icon,petInfo.name))
        end
    end
end

function RematchPlugin:OnExport(key)
    local rematchVersion = ns.Version:Current('Rematch')

    if not rematchVersion then
        return
    end

    if rematchVersion < ns.Version:New(5, 0, 0, 0) then
        if self.savedRematchTeams[key] then
            Rematch:SetSideline(key, self.savedRematchTeams[key])
            return Rematch:ConvertSidelineToString()
        end
    end
end

function RematchPlugin:OnImport(data)
    local rematchVersion = ns.Version:Current('Rematch')

    if not rematchVersion then
        return
    end

    if rematchVersion < ns.Version:New(5, 0, 0, 0) then
        Rematch:ShowImportDialog()
        RematchDialog.MultiLine.EditBox:SetText(data)
    end
end
