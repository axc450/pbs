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

ns.L["DATABASE_UPDATE_BASE_TO_FIRSTENEMY_NOTIFICATION"] = ns.L['PLUGINFIRSTENEMY_NOTIFY']
ns.L["DATABASE_UPDATED_TO"] = ns.L['UPDATED']

ns.L["DEFAULT_NEW_SCRIPT_NAME"] = ns.L["New script"]

ns.L["DIRECTOR_TEST_NEXT_ACTION"] = ns.L["NEXT_ACTION"]

ns.L["EDITOR_CREATE_SCRIPT"] = ns.L["WRITE_SCRIPT"]
ns.L["EDITOR_EDIT_SCRIPT"] = ns.L["Edit script"]

ns.L["IN_BATTLE_DEBUGGING_SCRIPT"] = ns.L['Debugging script']
ns.L["IN_BATTLE_EXECUTE"] = ns.L["Auto"]
ns.L["IN_BATTLE_NO_SCRIPT"] = ns.L['No script']
ns.L["IN_BATTLE_SELECT_SCRIPT"] = ns.L['Select script']

ns.L["OPTION_AUTO_SELECT_SCRIPT_BY_ORDER"] = ns.L["OPTION_SETTINGS_AUTO_SELECT_SCRIPT_BY_ORDER"]
ns.L["OPTION_AUTO_SELECT_SCRIPT_ONLY_ONE"] = ns.L["OPTION_SETTINGS_AUTO_SELECT_SCRIPT_ONLY_ONE"]
ns.L["OPTION_AUTOBUTTON_HOTKEY"] = ns.L["OPTION_SETTINGS_AUTOBUTTON_HOTKEY"]
ns.L["OPTION_EDITOR_FONT_FACE"] = ns.L["Font face"]
ns.L["OPTION_EDITOR_FONT_SIZE"] = ns.L["Font size"]
ns.L["OPTION_HIDE_MINIMAP"] = ns.L["OPTION_SETTINGS_HIDE_MINIMAP"]
ns.L["OPTION_HIDE_SELECTOR_NO_SCRIPT"] = ns.L["OPTION_SETTINGS_HIDE_SELECTOR_NO_SCRIPT"]
ns.L["OPTION_LOCK_SCRIPT_SELECTOR"] = ns.L["OPTION_SETTINGS_LOCK_SCRIPT_SELECTOR"]
ns.L["OPTION_NO_WAIT_DELETE_SCRIPT"] = ns.L["OPTION_SETTINGS_NO_WAIT_DELETE_SCRIPT"]
ns.L["OPTION_NOTIFY_BUTTON_ACTIVE"] = ns.L["OPTION_SETTINGS_NOTIFY_BUTTON_ACTIVE"]
ns.L["OPTION_NOTIFY_BUTTON_ACTIVE_SOUND"] = ns.L["OPTION_SETTINGS_NOTIFY_BUTTON_ACTIVE_SOUND"]
ns.L["OPTION_RESET_FRAMES"] = ns.L["OPTION_SETTINGS_RESET_FRAMES"]
ns.L["OPTION_TEST_BREAK"] = ns.L["OPTION_SETTINGS_TEST_BREAK"]

ns.L["SCRIPT_EDITOR_AUTOFORMAT_SCRIPT"] = ns.L['Beauty script']
ns.L["SCRIPT_EDITOR_DELETE_SCRIPT_CONFIRMATION"] = ns.L["SCRIPT_EDITOR_DELETE_SCRIPT"]
ns.L["SCRIPT_EDITOR_FOUND_ERROR"] = ns.L['Found error']
ns.L["SCRIPT_EDITOR_NAME_TITLE"] = ns.L['Script name']
ns.L["SCRIPT_EDITOR_RUN_BUTTON"] = ns.L["Run"]
ns.L["SCRIPT_EDITOR_SAVE_SUCCESS"] = ns.L['Save success']
ns.L["SCRIPT_EDITOR_TEXTAREA_TITLE"] = ns.L["Script"]
ns.L["SCRIPT_EDITOR_TITLE"] = ns.L['Script editor']

ns.L["SCRIPT_MANAGER_TITLE"] = ns.L['Script manager']
ns.L["SCRIPT_MANAGER_TOGGLE"] = ns.L["TOGGLE_SCRIPT_MANAGER"]

ns.L["SCRIPT_SELECTOR_TITLE"] = ns.L['Script selector']
ns.L["SCRIPT_SELECTOR_TOGGLE"] = ns.L["TOGGLE_SCRIPT_SELECTOR"]

ns.L["SELECTOR_ALLINONE_NOTES"] = ns.L["PLUGINALLINONE_NOTES"]
ns.L["SELECTOR_ALLINONE_TITLE"] = ns.L["PLUGINALLINONE_TITLE"]
ns.L["SELECTOR_BASE_ALLY"] = ns.L["PLUGINBASE_TEAM_ALLY"]
ns.L["SELECTOR_BASE_ENEMY"] = ns.L["PLUGINBASE_TEAM_ENEMY"]
ns.L["SELECTOR_BASE_NOTES"] = ns.L["PLUGINBASE_NOTES"]
ns.L["SELECTOR_BASE_TITLE"] = ns.L["PLUGINBASE_TITLE"]
ns.L["SELECTOR_FIRSTENEMY_NOTES"] = ns.L["PLUGINFIRSTENEMY_NOTES"]
ns.L["SELECTOR_FIRSTENEMY_TITLE"] = ns.L["PLUGINFIRSTENEMY_TITLE"]
ns.L["SELECTOR_REMATCH_NO_TEAM_FOR_SCRIPT"] = ns.L["NO_TEAM_FOR_SCRIPT"]
ns.L["SELECTOR_REMATCH_NOTES"] = ns.L["NOTES"]
ns.L["SELECTOR_REMATCH_TEAM_FORMAT"] = ns.L["TEAM"] .. "%s" -- team title
ns.L["SELECTOR_REMATCH_TITLE"] = ns.L["TITLE"]

ns.L["SHARE_EXPORT_SCRIPT"] = ns.L["Export"]

ns.L["SHARE_IMPORT_CHOOSE_KEY"] = ns.L["IMPORT_CHOOSE_KEY"]
ns.L["SHARE_IMPORT_CHOOSE_SELECTOR"] = ns.L["IMPORT_CHOOSE_PLUGIN"]
ns.L["SHARE_IMPORT_LABEL_ALREADY_EXISTS_CHECKBOX"] = ns.L["SCRIPT_IMPORT_LABEL_GOON"]
ns.L["SHARE_IMPORT_LABEL_EXTRA"] = ns.L["SCRIPT_IMPORT_LABEL_EXTRA"]
ns.L["SHARE_IMPORT_LABEL_ALREADY_EXISTS_WARNING"] = ns.L["SCRIPT_IMPORT_LABEL_COVER"]
ns.L["SHARE_IMPORT_REINPUT_TEXT"] = ns.L["IMPORT_REINPUT_TEXT"]
ns.L["SHARE_IMPORT_SCRIPT"] = ns.L["Import"]
ns.L["SHARE_IMPORT_SCRIPT_EXISTS"] = ns.L["IMPORT_SCRIPT_EXISTS"]
ns.L["SHARE_IMPORT_SCRIPT_NOT_IMPORT_STRING_WARNING"] = ns.L["IMPORT_SCRIPT_WARNING"]
ns.L["SHARE_IMPORT_SCRIPT_WELCOME"] = ns.L["IMPORT_SCRIPT_WELCOME"]
ns.L["SHARE_IMPORT_STRING_INCOMPLETE"] = ns.L["IMPORT_SHARED_STRING_WARNING"]

_G.PetBattleScripts = Addon

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
