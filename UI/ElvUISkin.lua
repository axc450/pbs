local _, ns  = ...
local Addon  = ns.Addon
local Module = Addon:GetModule('UI.PetBattle')

if not ElvUI then return end

local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

function S:tdBattlePetScript()
    local blizzardSkinsTable = E.private.skins.blizzard
    if not blizzardSkinsTable.enable or not blizzardSkinsTable.petbattleui then return end

    local ToolButton = Module.ToolButton
    local Highlight = ToolButton:GetRegions()
    local ArtFrame2 = Module.ArtFrame2
    local AutoButton = Module.AutoButton
    local SkipButton = Module.SkipButton
    local XPBar = PetBattleFrame.BottomFrame.xpBar

    ToolButton:ClearAllPoints()
    ToolButton:Point('TOPLEFT', PetBattleFrame.TopVersusText, 'TOPLEFT', 0, 0)
    ToolButton:Point('BOTTOMRIGHT', PetBattleFrame.TopVersusText, 'BOTTOMRIGHT', 0, 0)

    Highlight:Hide()
    Highlight.Show = nop
    Highlight.SetShown = nop

    ArtFrame2:Hide()
    ArtFrame2.Show = nop
    ArtFrame2.SetShown = nop

    local yOffset = E.PixelMode and -1 or 1
    local gap = E.PixelMode and 1 or 3
    local xOffset = gap + AutoButton:GetWidth()

    S:HandleButton(AutoButton)
    AutoButton:SetPoint('LEFT', SkipButton,'RIGHT', gap, 0)

    -- When the SkipButton is placed, make room for the AutoButton
    hooksecurefunc(SkipButton, "SetPoint", function(_, _, _, _, _, _, forced)
        if forced == true then return end

        SkipButton:Point('BOTTOMRIGHT', ElvUIPetBattleActionBar, 'TOPRIGHT', -xOffset, yOffset, true)
        XPBar:Point('BOTTOMRIGHT', SkipButton, 'TOPRIGHT', xOffset-E.Border, yOffset)
    end)

    -- When the AutoButton visibility is toggled, reset the SkipButton width
    hooksecurefunc(AutoButton, "SetShown", function(_, show)
        local xOffset = show and -xOffset or 0

        SkipButton:Point('BOTTOMRIGHT', ElvUIPetBattleActionBar, 'TOPRIGHT', xOffset, yOffset, true)
        XPBar:Point('BOTTOMRIGHT', SkipButton, 'TOPRIGHT', -E.Border, yOffset)
    end)
end

S:AddCallbackForAddon('tdBattlePetScript')
