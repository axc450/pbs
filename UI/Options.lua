local ADDON, ns		      = ...
local Addon             = ns.Addon
local L                 = ns.L
local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
local AceConfigDialog   = LibStub('AceConfigDialog-3.0')
local AceGUISharedMediaWidgets = LibStub('AceGUISharedMediaWidgets-1.0')
local LibSharedMedia = LibStub("LibSharedMedia-3.0")
local Options           = Addon:NewModule('Options')
local PluginManager     = ns.PluginManager

local function orderGen()
    local order = 0
    return function()
        order = order + 1
        return order
    end
end

function Options:OnEnable()
    self:InitOptions()
end

function Options:InitOptions()
    self.optionsArgs = {}
    local options = {
        type = 'group',
        args = self.optionsArgs
    }
    AceConfigRegistry:RegisterOptionsTable(L.ADDON_NAME, options)
    AceConfigDialog:AddToBlizOptions(L.ADDON_NAME, L.ADDON_NAME)

    self:UpdateOptions()
end

function Options:UpdateOptions()
    local order = orderGen()

    local function defaultGet(item)
        return Addon:GetSetting(item[#item])
    end

    local function defaultSet(item, value)
        return Addon:SetSetting(item[#item], value)
    end

    local function makeBase(name, type, extra)
        local tab = extra or {}
        tab.order = order()
        tab.width = tab.width or 'full'
        tab.name = name
        tab.type = type

        local set = (extra and extra.set) or defaultSet
        local get = (extra and extra.get) or defaultGet

        if extra and extra.needsReload then
            extra.needsReload = nil
            set = function(item, value)
                set(item, value)
                C_UI.Reload()
            end
        end

        tab.set = set
        tab.get = get

        return tab
    end
    local function makeHeader(name, extra)
        local tab = makeBase(name, 'header', extra)
        return tab
    end
    local function makeToggle(name, extra)
        local tab = makeBase(name, 'toggle', extra)
        return tab
    end
    local function makeExecute(name, func, extra)
        local tab = makeBase(name, 'execute', extra)
        tab.func = func
        return tab
    end
    local function makeKeybinding(name, extra)
        local tab = makeBase(name, 'keybinding', extra)
        return tab
    end
    local function makeSelect(name, values, extra)
        local tab = makeBase(name, 'select', extra)
        tab.values = LibSharedMedia:HashTable(values)
        tab.dialogControl = 'LSM30_' .. ((values:gsub("^%l", string.upper)))
        return tab
    end
    local function makeDescription(name, extra)
        local tab = makeBase(name, 'description', extra)
        tab.fontSize = 'medium'
        tab.image = [[Interface\Common\help-i]]
        tab.imageWidth = 16
        tab.imageHeight = 16
        tab.imageCoords = {.2, .8, .2, .8}
        return tab
    end
    local function makeRange(name, min, max, step, extra)
        local tab = makeBase(name, 'range', extra)
        tab.min = min
        tab.max = max
        tab.step = step
        return tab
    end
    local function makePadding(width)
        local tab = makeBase('', 'description', {})
        tab.width = width
        return tab
    end

    local optionsArgs = wipe(self.optionsArgs)

    --- General
    optionsArgs.autoButtonHotKey = makeKeybinding(L.OPTION_AUTOBUTTON_HOTKEY)
    optionsArgs.notifyButtonActive = makeToggle(L.OPTION_NOTIFY_BUTTON_ACTIVE, {width = 'double'})
    optionsArgs.notifyButtonActivePadding = makePadding(0.2)
    optionsArgs.notifyButtonActiveSound = makeSelect(L.OPTION_NOTIFY_BUTTON_ACTIVE_SOUND, LibSharedMedia.MediaType.SOUND, {width = 'normal',})
    optionsArgs.testBreak = makeToggle(L.OPTION_TEST_BREAK)

    optionsArgs.noWaitDeleteScript = makeToggle(L.OPTION_NO_WAIT_DELETE_SCRIPT)
    optionsArgs.hideMinimap = makeToggle(L.OPTION_HIDE_MINIMAP)
    optionsArgs.scriptSelectorResetPos = makeExecute(L.OPTION_RESET_FRAMES, function() Addon:ResetFrames() end)

    --- Script Selector
    optionsArgs.headerPlugins = makeHeader(L.SCRIPT_SELECTOR_TITLE)

    optionsArgs.autoSelect = makeToggle(L.OPTION_AUTO_SELECT_SCRIPT_BY_ORDER)
    optionsArgs.hideNoScript = makeToggle(L.OPTION_HIDE_SELECTOR_NO_SCRIPT)
    optionsArgs.lockScriptSelector = makeToggle(L.OPTION_LOCK_SCRIPT_SELECTOR)

    optionsArgs.descriptionPlugins = makeDescription(L.OPTION_SCRIPTSELECTOR_NOTES)
    self:FillInstalledPlugins(optionsArgs, order)

    --- Script Editor
    optionsArgs.headerScriptEditor = makeHeader(L.SCRIPT_EDITOR_TITLE)

    optionsArgs.editorFontFace = makeSelect(L.OPTION_EDITOR_FONT_FACE, LibSharedMedia.MediaType.FONT, {width = 'double',
        set = function(item, value)
            return defaultSet(item, LibSharedMedia:Fetch(LibSharedMedia.MediaType.FONT, value))
        end,
        get = function(item, value)
            local val = defaultGet(item)
            for k, v in pairs(LibSharedMedia:HashTable(LibSharedMedia.MediaType.FONT)) do
                if v == val then
                    return k
                end
            end
            return nil
        end,
    })
    optionsArgs.editorFontPadding = makePadding(0.2)
    optionsArgs.editorFontSize = makeRange(L.OPTION_EDITOR_FONT_SIZE, 9, 32, 1, {width = 'normal'})

    AceConfigRegistry:NotifyChange(ADDON)
end

function Options:FillInstalledPlugins(args, order)
    local pluginCount = #PluginManager:GetPluginList()

    for i, plugin in PluginManager:IteratePlugins() do
        local name = plugin:GetPluginName()
        local isFirst = i == 1
        local isLast = i == pluginCount

        args[name] = {
            type = 'toggle',
            name = function()
                return PluginManager:IsPluginAllowed(name) and plugin:GetPluginTitle() or
                    format('|cff808080%s (%s)|r', plugin:GetPluginTitle(), DISABLE)
            end,
            desc = plugin:GetPluginNotes(),
            width = 'double',
            order = order(),
            get = function(item)
                return PluginManager:IsPluginAllowed(name)
            end,
            set = function(item, value)
                return PluginManager:SetPluginAllowed(name, value)
            end,
        }

        args[name .. 'Up'] = {
            type = 'execute',
            name = '',
            width = 0.3,
            disabled = isFirst,
            image = function()
                return isFirst and [[Interface\MINIMAP\MiniMap-VignetteArrow]] or
                    [[Interface\MINIMAP\MiniMap-QuestArrow]]
            end,
            imageCoords = {0.1875, 0.8125, 0.1875, 0.8125},
            imageWidth = 16,
            imageHeight = 16,
            order = order(),
            func = function()
                PluginManager:MoveUpPlugin(name)
                self:UpdateOptions()
            end
        }

        args[name .. 'Down'] = {
            type = 'execute',
            name = '',
            width = 0.3,
            disabled = isLast,
            image = function()
                return isLast and [[Interface\MINIMAP\MiniMap-VignetteArrow]] or
                    [[Interface\MINIMAP\MiniMap-QuestArrow]]
            end,
            imageCoords = {0.1875, 0.8125, 0.8125, 0.1875},
            imageWidth = 16,
            imageHeight = 16,
            order = order(),
            func = function()
                PluginManager:MoveDownPlugin(name)
                self:UpdateOptions()
            end
        }
    end
end

function Addon:OpenOptionsFrame()
    Settings.OpenToCategory(L.ADDON_NAME)
end
