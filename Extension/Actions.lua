--[[
Actions.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns    = select(2, ...)
local Addon = ns.Addon
local Util  = ns.Util


Addon:RegisterAction('test', function(arg,run)
    if run then
        print(arg)
    end
    return Addon:GetSetting('testBreak')
end)


Addon:RegisterAction('change', function(index,run)
    local active = C_PetBattles.GetActivePet(Enum.BattlePetOwner.Ally)
    if index == 'next' then
        index = active % C_PetBattles.GetNumPets(Enum.BattlePetOwner.Ally) + 1
    else
        index = Util.ParsePetIndex(Enum.BattlePetOwner.Ally, index)
    end
    -- if not index or active == index or C_PetBattles.GetHealth(Enum.BattlePetOwner.Ally, index) == 0 then
    --     return false
    -- end

    if not index or active == index or not (C_PetBattles.CanActivePetSwapOut() or C_PetBattles.ShouldShowPetSelect()) or not C_PetBattles.CanPetSwapIn(index) then
        return false
    end
    if run then
        C_PetBattles.ChangePet(index)
    end
    return true
end)


Addon:RegisterAction('ability', 'use', function(ability,run)
    local index = C_PetBattles.GetActivePet(Enum.BattlePetOwner.Ally)
    local ability= Util.ParseAbility(Enum.BattlePetOwner.Ally, index, ability)
    if not ability then
        return false
    end
    if not C_PetBattles.GetAbilityState(Enum.BattlePetOwner.Ally, index, ability) then
        return false
    end
    if run then
        C_PetBattles.UseAbility(ability)
    end
    return true
end)


Addon:RegisterAction('quit', function(run)
    if run then
        C_PetBattles.ForfeitGame()
    end
    return true
end)


Addon:RegisterAction('standby', function(run)
    if not C_PetBattles.IsSkipAvailable() then
        return false
    end
    if run then
        C_PetBattles.SkipTurn()
    end
    return true
end)


Addon:RegisterAction('catch', function(run)
    if not C_PetBattles.IsTrapAvailable() then
        return false
    end
    if run then
        C_PetBattles.UseTrap()
    end
    return true
end)

Addon:RegisterAction('--', function(run)
    return false
end)
