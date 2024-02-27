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

    local ABOffset = 1 + AutoButton:GetWidth()
    local XPOffset = E.PixelMode and 2 or 3

    S:HandleButton(AutoButton)
    AutoButton:SetPoint('LEFT', SkipButton,'RIGHT', 1, 0)
    AutoButton:SetParent(SkipButton:GetParent())

    -- When the SkipButton is placed, make room for the AutoButton
    hooksecurefunc(SkipButton, "SetPoint", function(_, _, _, _, _, _, forced)
        if forced == true then return end

        SkipButton:Point('BOTTOMRIGHT', ElvUIPetBattleActionBar, 'TOPRIGHT', -ABOffset, 1, true)
        XPBar:Point('BOTTOMRIGHT', SkipButton, 'TOPRIGHT', ABOffset-E.Border, XPOffset)
    end)

    -- When the AutoButton visibility is toggled, reset the SkipButton width
    hooksecurefunc(AutoButton, "SetShown", function(_, show)
        local ABOffset = show and ABOffset or 0

        SkipButton:Point('BOTTOMRIGHT', ElvUIPetBattleActionBar, 'TOPRIGHT', -ABOffset, 1, true)
        XPBar:Point('BOTTOMRIGHT', SkipButton, 'TOPRIGHT', ABOffset-E.Border, XPOffset)
    end)
end

S:AddCallbackForAddon('tdBattlePetScript')
