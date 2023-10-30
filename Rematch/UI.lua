--[[
UI.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns = select(2, ...)

local RematchPlugin = ns.RematchPlugin
local L     = LibStub('AceLocale-3.0'):GetLocale('PetBattleScripts')

local scriptMenuItem = {
    text = L.EDITOR_CREATE_SCRIPT,
    func = function(_, key, ...)
        RematchPlugin:OpenScriptEditor(key, Rematch:GetTeamTitle(key))
    end
}

local scriptButtons = setmetatable({}, {
    __index = function(t, parent)
        local button = CreateFrame('Button', nil, parent, 'RematchFootnoteButtonTemplate') do
            if parent.slim then
                button:SetSize(18, 18)
            end
            button:SetPoint('CENTER')
            button:SetNormalTexture("Interface/AddOns/tdBattlePetScript/Rematch/Textures/ScriptIcon")
            button:SetPushedTexture("Interface/AddOns/tdBattlePetScript/Rematch/Textures/ScriptIcon")
            button:SetScript('OnClick', function(button)
                RematchPlugin:OpenScriptEditor(button.key, Rematch:GetTeamTitle(button.key))
            end)
            button:SetScript('OnEnter', function(button)
                GameTooltip:SetOwner(button, 'ANCHOR_RIGHT')
                GameTooltip:SetText(L.ADDON_NAME)
                GameTooltip:AddLine(L.EDITOR_CREATE_SCRIPT, HIGHLIGHT_FONT_COLOR:GetRGB())
                GameTooltip:Show()
            end)
            button:SetScript('OnLeave', GameTooltip_Hide)
        end
        t[parent] = button
        return button
    end
})

function RematchPlugin:SetupUI()
    -- Add menu to edit script
    tinsert(Rematch:GetMenu('TeamMenu'), 6, scriptMenuItem)

    -- When a script is added/removed, refresh the teams list.
    self:RegisterMessage('PET_BATTLE_SCRIPT_SCRIPT_LIST_UPDATE', function()
        if RematchLoadedTeamPanel:IsVisible() then
            RematchLoadedTeamPanel:Update()
        end
        if RematchTeamPanel:IsVisible() then
            if RematchTeamPanel.UpdateList then
                RematchTeamPanel:UpdateList()
            elseif RematchTeamPanel.List then
                RematchTeamPanel.List:Update()
            end
        end
    end)

    -- Button to indicate a script exists
    local version = ns.Version:Current()
    if version >= ns.Version:New(4, 8, 10, 5) then
        self:SecureHook(RematchTeamPanel.List, 'callback', function(button, key)
            local script = scriptButtons[button]
            if self:GetScript(key) then
                script.key = key
                script:Show()
                script:ClearAllPoints()

                local relative = button.Preferences:IsShown()                      and button.Preferences or
                                 button.Notes:IsShown()                            and button.Notes or
                                 button.compact and button.WinRecordBack:IsShown() and button.WinRecordBack

                if relative then
                    script:SetPoint('RIGHT', relative, 'LEFT', relative == button.WinRecordBack and -3 or 0, 0)
                else
                    script:SetPoint('TOPRIGHT', -2, -3)
                end

                button.Name:SetPoint('TOPRIGHT', script:GetLeft() - button:GetRight() , -4)
            else
                script:Hide()
            end
        end)
    else
        self:SecureHook(RematchTeamPanel, 'FillTeamButton', function(_, button, key)
            local script = scriptButtons[button]
            if self:GetScript(key) then
                script.key = key
                script:Show()
                script:ClearAllPoints()

                local xoffset = -3
                local yoffset = 0

                if button.WinRecord:IsShown() then
                    if button.slim then
                        xoffset = xoffset - button.WinRecord:GetWidth()
                    else
                        yoffset = 8
                    end
                    button.WinRecord:SetPoint('BOTTOMRIGHT',-3,4)
                    button.WinRecord:SetHitRectInsets(0,0,0,-2)
                end

                if button.Preferences:IsShown() then
                    xoffset = xoffset - button.Preferences:GetWidth()
                end
                if button.Notes:IsShown() then
                    xoffset = xoffset - button.Notes:GetWidth()
                end

                script:SetPoint('RIGHT', xoffset, yoffset)

                xoffset = xoffset - script:GetWidth()

                if button.slim then
                    button.Name:SetPoint('RIGHT',xoffset-2,0)
                else
                    button.Name:SetPoint('TOPRIGHT',xoffset-1,-6)
                end
            else
                script:Hide()
            end
        end)
    end

    local function move(button, add)
        if not button:IsShown() then
            return 0
        end

        local point, relative, relativePoint, x, y = button:GetPoint()
        button:SetPoint(point, relative, relativePoint, x + 21, y)
        return add
    end

    self:SecureHook(RematchLoadedTeamPanel, 'Update', function(panel)
        local footnotes = panel.Footnotes
        local script = scriptButtons[footnotes]

        if self:GetScript(RematchSettings.loadedTeam) then
            script.key = RematchSettings.loadedTeam
            script:Show()
            script:ClearAllPoints()
            script:SetPoint('LEFT', 5, -0.5)

            local fx = 5 + 21
            fx = fx + move(footnotes.Preferences, 21)
            fx = fx + move(footnotes.Notes, 21)
            fx = fx + move(footnotes.WinRecord, footnotes.WinRecord:GetWidth())
            fx = fx + move(footnotes.Maximize, 21)
            fx = fx + move(footnotes.Close, 21)

            local footnoteWidth = fx + 4
            local panelWidth = panel.maxWidth or 280

            footnotes:SetWidth(footnoteWidth)
            footnotes:Show()
            panel:SetWidth(panelWidth-footnoteWidth-3)
        else
            script:Hide()
        end
    end)

    self:HookScript(RematchJournal, 'OnShow', function(self)
        CollectionsJournal:SetAttribute('UIPanelLayout-width', 870)
        UpdateUIPanelPositions()
    end)
    self:HookScript(RematchJournal, 'OnHide', function(self)
        CollectionsJournal:SetAttribute('UIPanelLayout-width', 710)
        UpdateUIPanelPositions()
    end)
end

function RematchPlugin:TeardownUI()
    tDeleteItem(Rematch:GetMenu('TeamMenu'), scriptMenuItem)
end
