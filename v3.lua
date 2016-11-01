--[[
v3.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns = select(2, ...)
if ns.Version > 3 then return end

local Addon = ns.Addon
local L     = LibStub('AceLocale-3.0'):GetLocale('tdBattlePetScript_Rematch')

local teamMenu = {
    text = L.WRITE_SCRIPT,
    func = function()
        local key = Rematch.menu.subject
        Addon:OpenScriptEditor(key, Rematch:GetTeamTitle(key))
    end
}

function Addon:OnEnable()
    tinsert(Rematch.menu.menus.teamList, 6, teamMenu)
    tinsert(Rematch.menu.menus.headerMenu, 3, teamMenu)

    self:Hook(Rematch.rmf, 'DeleteAccept', function(...)
        local _, key = Rematch:GetSideline()
        if key then
            self:RemoveScript(key)
        end
    end)
end

function Addon:OnDisable()
    tDeleteItem(Rematch.menu.menus.teamList, teamMenu)
    tDeleteItem(Rematch.menu.menus.headerMenu, teamMenu)
end
