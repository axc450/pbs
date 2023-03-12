_, ns 				    = ...
local Addon             = ns.Addon
local L                 = ns.L
local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
local AceConfigDialog   = LibStub('AceConfigDialog-3.0')
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
			newLine = {
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
