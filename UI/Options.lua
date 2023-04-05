_, ns 				    = ...
local Addon             = ns.Addon
local L                 = ns.L
local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
local AceConfigDialog   = LibStub('AceConfigDialog-3.0')
local AceGUISharedMediaWidgets = LibStub('AceGUISharedMediaWidgets-1.0')
local LibSharedMedia = LibStub("LibSharedMedia-3.0")
local Options           = Addon:NewModule('Options')


function Options:OnEnable()
    self:InitOptions()
end

function Options:InitOptions()
    local options = {
        type = "group",
		args = {
			hideMinimap = {
				order = 0,
				type = "toggle",
				name = L.OPTION_SETTINGS_HIDE_MINIMAP,
				get = getHideMinimap,
				set = setHideMinimap
			},
			newLine1 = {
				order = 1,
				type = "description",
				name = ""
			},
			autoButtonHotKey = {
				order = 2,
				type = "keybinding",
				name = L.OPTION_SETTINGS_AUTOBUTTON_HOTKEY,
				get = getAutoButtonHotKey,
				set = setAutoButtonHotKey
			},
			newLine2 = {
				order = 3,
				type = "description",
				name = ""
			},
			notifyButtonActive = {
				order = 4,
				type = "toggle",
				name = L.OPTION_SETTINGS_NOTIFY_BUTTON_ACTIVE,
				get = function(item)
					return Addon:GetSetting("notifyButtonActive")
				end,
				set = function(item, value)
					Addon:SetSetting("notifyButtonActive", value)
				end,
			},
			notifyButtonActiveSound = {
				order = 5,
				type = "select",
				name = L.OPTION_SETTINGS_NOTIFY_BUTTON_ACTIVE_SOUND,
				values = LibSharedMedia:HashTable("sound"),
				dialogControl = "LSM30_Sound",
				get = function(item)
					return Addon:GetSetting("notifyButtonActiveSound")
				end,
				set = function(item, value)
					Addon:SetSetting("notifyButtonActiveSound", value)
				end,
			},
		}
    }

    AceConfigRegistry:RegisterOptionsTable(L.ADDON_NAME, options)
    AceConfigDialog:AddToBlizOptions(L.ADDON_NAME, L.ADDON_NAME)
end

function getAutoButtonHotKey(item)
	return Addon:GetSetting("autoButtonHotKey")
end

function setAutoButtonHotKey(item, value)
	Addon:SetSetting("autoButtonHotKey", value)
end

function getHideMinimap(item)
	return Addon:GetSetting("hideMinimap")
end

function setHideMinimap(item, value)
	Addon:SetSetting("hideMinimap", value)
end

function Addon:OpenOptionsFrame()
    InterfaceOptionsFrame_OpenToCategory(L.ADDON_NAME)
end
