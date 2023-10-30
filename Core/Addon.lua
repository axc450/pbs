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
