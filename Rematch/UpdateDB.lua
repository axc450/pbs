local ns = select(2, ...)
local Addon = ns.Addon


function Addon:UpdateDB()

    -- A Rematch4 entry indicates the scripts have been migrated.
    local scriptsDB = TD_DB_BATTLEPETSCRIPT_GLOBAL.global.scripts
    if scriptsDB.Rematch4 then return end
    scriptsDB.Rematch4 = CopyTable(scriptsDB.Rematch) -- Backup old scripts

    -- Force Rematch to update teams, so 'GetTeamIDByName' works
    Rematch.savedTeams:TeamsChanged(true)

    -- First we need a cache list of all of our scripts.
    -- so we can modify our scripts database without messing up the loops
    local scriptList = {}
    for key, script in self:IterateScripts() do
        scriptList[key] = script
    end

    -- now we first migrade scripts attached to a team with a target ID
    for key, script in pairs(scriptList) do
        if type(key)=="number" then

            -- Attach script to first team found
            local teams = Rematch.savedTargets[key]

            if teams then
                --print('found at least one team on that target, attaching to the first one.')
                self:RemoveScript(key)
                self:AddScript(teams[1], script)
            else
                print('no team found.', 'target:', Rematch.targetInfo:GetNpcName(key))
            end
        end
    end

    -- and then migrate scripts that are attached to a team without a target
    for key, script in pairs(scriptList) do
        if type(key)~="number" then
            -- Look for a team with a matching name
            local teamID = Rematch.savedTeams:GetTeamIDByName(key)

            if teamID then
                -- Does the team already have a matching script
                if not self:GetScript(teamID) then
                    -- print('found matching team with no script.')
                    self:RemoveScript(key)
                    self:AddScript(teamID, script)
                else
                    print('found a matching team, but it has a script. looking for another …', 'oldkey:', key)

                    local name = key:trim():gsub(" %(%d+%)$", "") -- take off any trailing (2)s
                    local newTeamID, newTeamFound
                    for num = 2, 100 do -- stop looking after 100.
                        local newName = format("%s (%d)", name, num)
                        newTeamID = Rematch.savedTeams:GetTeamIDByName(newName)

                        if newTeamID and not self:GetScript(newTeamID) then
                            newTeamFound = true
                            break
                        end
                    end

                    if newTeamFound then
                        print('   … found a team without a script!', 'newKey:', newTeamID, Rematch.savedTeams[newTeamID].name)
                        self:RemoveScript(key)
                        self:AddScript(newTeamID, script)
                    else
                        print('   … faild looking for another matching team. Sorry.')
                    end
                end
            else
                print('no team found.', 'name:', key)
            end
        end
    end
end
