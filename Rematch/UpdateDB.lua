local ns = select(2, ...)
local Addon = ns.Addon

function Addon:UpdateDB(convertedTeams)
    -- Backup old scripts
    local scriptsDB = PetBattleScripts.db.global.scripts
    scriptsDB.Rematch4 = CopyTable(scriptsDB.Rematch)

    -- First we need a cache list of all of our scripts.
    -- so we can modify our scripts database without messing up the loops
    local scriptList = {}
    for key, script in self:IterateScripts() do
        scriptList[key] = script
    end

    -- now we can migrade scripts.
    for key, script in pairs(scriptList) do
        local newTeamID = convertedTeams[key]
        if newTeamID then
            self:RemoveScript(key)
            self:AddScript(newTeamID, script)

            --TODO: do we want to maintain the same script name and team name?
        else
            print('Found an orphaned script:', 'name:', script:GetName(), 'key:', key)
        end
    end
end
