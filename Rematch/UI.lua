--[[
UI.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns = select(2, ...)

local Addon = ns.Addon
local L     = LibStub('AceLocale-3.0'):GetLocale('tdBattlePetScript_Rematch')

local teamMenu = {
    text = L.WRITE_SCRIPT,
    func = function(_, key, ...)
        Addon:OpenScriptEditor(key, Rematch:GetTeamTitle(key))
    end
}

local function errorhandler(err)
    return geterrorhandler()(err)
end

local function safecall(func, ...)
    return xpcall(func, errorhandler, ...)
end

local scriptButtons = setmetatable({}, {
    __index = function(t, parent)
        local button = CreateFrame('Button', nil, parent, 'RematchFootnoteButtonTemplate') do
            if parent.slim then
                button:SetSize(18, 18)
            end
            button:SetPoint('CENTER')
            button:SetNormalTexture([[Interface\AddOns\tdBattlePetScript_Rematch\Textures\ScriptIcon]])
            button:SetPushedTexture([[Interface\AddOns\tdBattlePetScript_Rematch\Textures\ScriptIcon]])
            button:SetScript('OnClick', function(button)
                Addon:OpenScriptEditor(button.key, Rematch:GetTeamTitle(button.key))
            end)
            button:SetScript('OnEnter', function(button)
                GameTooltip:SetOwner(button, 'ANCHOR_RIGHT')
                GameTooltip:SetText('tdBattlePetScript')
                GameTooltip:AddLine(L.WRITE_SCRIPT, HIGHLIGHT_FONT_COLOR:GetRGB())
                GameTooltip:Show()
            end)
            button:SetScript('OnLeave', GameTooltip_Hide)
        end
        t[parent] = button
        return button
    end
})

function Addon:OnEnable()
    local menu = Rematch:GetMenu('TeamMenu')
    local deleteItem = self:FindMenuItem(menu, DELETE)

    tinsert(menu, 6, teamMenu)

    -- team delete

    self:RawHook(deleteItem, 'func', function(obj, key, ...)
        self.hooks[deleteItem].func(obj, key, ...)

        local origAccept = RematchDialog.acceptFunc
        RematchDialog.acceptFunc = function(...)
            self:RemoveScript(key)
            return origAccept(...)
        end
    end, true)

    -- team rename

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

    -- team update

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

function Addon:OnDisable()
    tDeleteItem(Rematch:GetMenu('TeamMenu'), teamMenu)
end

function Addon:FindMenuItem(menu, text)
    for i, v in ipairs(menu) do
        if v.text == text then
            return v
        end
    end
end

function Addon:OnExport(key)
    if RematchSaved[key] then
        Rematch:SetSideline(key, RematchSaved[key])
        return Rematch:ConvertSidelineToString()
    end
end

function Addon:OnImport(data)
    Rematch:ShowImportDialog()
    RematchDialog.MultiLine.EditBox:SetText(data)
end
