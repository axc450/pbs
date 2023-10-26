--[[
Minimap.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns        = select(2, ...)
local Addon     = ns.Addon
local UI        = ns.UI
local L         = ns.L
local GUI       = LibStub('tdGUI-1.0')
local LibDBIcon = LibStub('LibDBIcon-1.0')

local Minimap = Addon:NewModule('UI.Minimap', 'AceEvent-3.0')

function Minimap:OnInitialize()
    local LDB = LibStub('LibDataBroker-1.1')

    local function HideTooltip()
        GameTooltip:Hide()

        if LibDBIcon.tooltip then
            LibDBIcon.tooltip:Hide()
        end
    end

    local BrokerObject = LDB:NewDataObject('tdBattlePetScript', {
        type = 'launcher',
        icon = ns.ICON,
        OnClick = function(button, click)
            HideTooltip()

            if click == 'RightButton' then
                GUI:ToggleMenu(button, {
                    {
                        text = L.ADDON_NAME,
                        isTitle = true,
                    },
                    {
                        text = L.SCRIPT_MANAGER_TOGGLE,
                        func = function()
                            UI.MainPanel:TogglePanel()
                        end
                    },
                    {
                        text = L.SHARE_IMPORT_SCRIPT,
                        func = function()
                            UI.Import.Frame:Show()
                            UI.MainPanel:HidePanel()
                        end
                    },
                    {
                        text = SETTINGS_TITLE,
                        func = function()
                            Addon:OpenOptionsFrame()
                        end
                    }
                })
            else
                UI.MainPanel:TogglePanel()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:SetText(L.ADDON_NAME)
            tooltip:AddLine(' ')
            tooltip:AddLine(UI.LEFT_MOUSE_BUTTON .. L.SCRIPT_MANAGER_TOGGLE, 1, 1, 1)
            tooltip:AddLine(UI.RIGHT_MOUSE_BUTTON .. SETTINGS_TITLE, 1, 1, 1)
        end,
        OnLeave = HideTooltip
    })

    LibDBIcon:Register('tdBattlePetScript', BrokerObject, Addon.db.profile.minimap)

    self:RegisterMessage('PET_BATTLE_SCRIPT_SETTING_CHANGED_hideMinimap', 'Refresh')

    self:Refresh()
end

function Minimap:Refresh()
    Addon.db.profile.minimap.hide = Addon:GetSetting('hideMinimap') or nil
    LibDBIcon:Refresh('tdBattlePetScript')
end
