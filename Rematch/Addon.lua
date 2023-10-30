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

function RematchPlugin:OnEnable()
    -- Team is deleted
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

    -- Maintain sync between script name, and team name
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
            if not RematchSaved[key] or not Rematch:SidelinePetsDifferentThan(key) then
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

    -- UI
    self:SetupUI()
end

function RematchPlugin:OnDisable()
    self:TeardownUI()
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

function RematchPlugin:OnExport(key)
    if RematchSaved[key] then
        Rematch:SetSideline(key, RematchSaved[key])
        return Rematch:ConvertSidelineToString()
    end
end

function RematchPlugin:OnImport(data)
    Rematch:ShowImportDialog()
    RematchDialog.MultiLine.EditBox:SetText(data)
end
