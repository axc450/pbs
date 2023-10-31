--[[
Addon.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ADDON, ns = ...
local Addon = LibStub('AceAddon-3.0'):NewAddon('PetBattleScripts', 'AceEvent-3.0', 'LibClass-2.0')
local GUI   = LibStub('tdGUI-1.0')

ns.Addon = Addon
ns.UI    = {}
ns.L     = LibStub('AceLocale-3.0'):GetLocale('PetBattleScripts', true)
ns.ICON  = [[Interface\Icons\Icon_petfamily_dragon]]

_G.PetBattleScripts = Addon

-- TODO: remove before merge, add to curseforge
ns.L['SELECTOR_REMATCH_CANT_FORMAT_TOOLTIP_REMATCH_NOT_LOADED'] = "Can't show information: Rematch addon not loaded."
ns.L['SHARE_IMPORT_PLUGIN_NOT_ENABLED'] = "Can't import: Plugin is not enabled."
ns.L['SHARE_IMPORT_LABEL_HAS_EXTRA'] = "This import string will import extra data in addition to just the script, depending on the script plugin. Usually, this is information about the corresponding team."
ns.L['SHARE_IMPORT_LABEL_EXTRA'] = nil
ns.L.SELECTOR_REMATCH_4_TO_5_UPDATE_NOTE = 'Updated from Rematch 4 to Rematch 5. Please check whether your scripts are still correctly linked to teams.\nIf the upgrade failed, restore a backup of wow/WTF/Account/<your account>/SavedVariables/tdBattlePetScript.lua, or open it and search for "Rematch" and remove or replace with "Rematch5", then search for "Rematch4" and replace it with "Rematch". Then downgrade back to Rematch 4 and report a bug on https://github.com/axc450/pbs/issues/new, attaching your saved variables file for Rematch and this addon.'
ns.L.SELECTOR_REMATCH_4_TO_5_UPDATE_ORPHAN = 'Found script named "%s" which is linked to the non-existent Rematch team id "%s".\nThis can indicate an issue during updating the database, or a previous corruption. If this error has happened to a lot of teams, please report it as a bug. Otherwise, just remove orphaned teams via the Script Browser and re-add them to the correct teams.'

function Addon:OnInitialize()
    local defaults = {
        global = {
            scripts = {

            },
            notifies = {

            }
        },
        profile = {
            pluginDisabled = {},
            pluginOrders = {},
            settings = {
                hideMinimap        = false,
                autoSelect         = true,
                hideNoScript       = true,
                noWaitDeleteScript = false,
                editorFontFace     = STANDARD_TEXT_FONT,
                editorFontSize     = 14,
                autoButtonHotKey   = 'A',
                testBreak          = true,
                lockScriptSelector = false,
                notifyButtonActive = false,
                notifyButtonActiveSound = 'None',
            },
            minimap = {
                minimapPos = 50,
            },
            position = {
                point = 'CENTER', x = 0, y = 0, width = 350, height = 450,
            },
            scriptSelectorPosition = {
                point = 'TOP', x = 0, y = -60,
            }
        }
    }

    self.db = LibStub('AceDB-3.0'):New('TD_DB_BATTLEPETSCRIPT_GLOBAL', defaults, true)

    self.db.RegisterCallback(self, 'OnDatabaseShutdown')
end

function Addon:OnEnable()
    self:RegisterMessage('PET_BATTLE_SCRIPT_SCRIPT_ADDED')
    self:RegisterMessage('PET_BATTLE_SCRIPT_SCRIPT_REMOVED')
    self:InitSettings()
    self:UpdateDatabase()
end

function Addon:InitSettings()
    for key, value in pairs(self.db.profile.settings) do
        self:SetSetting(key, value)
    end
end

function Addon:UpdateDatabase()
    local oldVersion = self.db.global.version
    local newVersion = GetAddOnMetadata(ADDON, 'Version')

    if oldVersion ~= newVersion then
        self.db.global.version = newVersion

        C_Timer.After(0.9, function()
            GUI:Notify{
                text = format('%s\n|cff00ffff%s: |cffffff00%s|r', ns.L.ADDON_NAME, ns.L.DATABASE_UPDATED_TO, newVersion),
                icon = ns.ICON,
                help = ''
            }
        end)
    end
end

function Addon:OnModuleCreated(module)
    local name = module:GetName()
    if name:find('^UI%.') then
        ns.UI[name:match('^UI%.(.+)$')] = module
    else
        ns[name] = module
    end
end

function Addon:OnDatabaseShutdown()
    self:SendMessage('PET_BATTLE_SCRIPT_DB_SHUTDOWN')
end

function Addon:PET_BATTLE_SCRIPT_SCRIPT_ADDED(_, plugin, key, script)
    self.db.global.scripts[plugin:GetPluginName()][key] = script:GetDB()
end

function Addon:PET_BATTLE_SCRIPT_SCRIPT_REMOVED(_, plugin, key)
    self.db.global.scripts[plugin:GetPluginName()][key] = nil
end

function Addon:GetSetting(key)
    return self.db.profile.settings[key]
end

function Addon:SetSetting(key, value)
    self.db.profile.settings[key] = value
    self:SendMessage('PET_BATTLE_SCRIPT_SETTING_CHANGED', key, value)
    self:SendMessage('PET_BATTLE_SCRIPT_SETTING_CHANGED_' .. key, value)
end

function Addon:ResetSetting(key)
    if type(self.db.profile[key]) == 'table' then
        wipe(self.db.profile[key])

        for k, v in pairs(self.db.defaults.profile[key]) do
            if type(v) == 'table' then
                self.db.profile[key][k] = CopyTable(v)
            else
                self.db.profile[key][k] = v
            end
        end
    else
        error('not support')
    end
end

function Addon:ResetFrames()
    self:ResetSetting('position')
    self:ResetSetting('scriptSelectorPosition')
    self:SendMessage('PET_BATTLE_SCRIPT_RESET_FRAMES')
end
