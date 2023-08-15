local ns = select(2, ...)
local Addon = ns.Addon


function Addon:UpdateDB()

    -- A Rematch4 entry indicates the scripts have been migrated.
    local scriptsDB = TD_DB_BATTLEPETSCRIPT_GLOBAL.global.scripts
    if scriptsDB.Rematch4 then return end
    scriptsDB.Rematch4 = CopyTable(scriptsDB.Rematch) -- Backup old scripts

    -- Force Rematch to update teams, so 'GetTeamIDByName' works
    Rematch.savedTeams:TeamsChanged(true)

    local moveTasks = {}

    for key, script in self:IterateScripts() do
        if type(key)=="number" then

            -- Attach script to first team found
            local teams = Rematch.savedTargets[key]

            if teams then
                --print('found some teams, attaching to the first one')
                tinsert(moveTasks, {key, teams[1], script})
            else
                print('no team found.', 'target:', Rematch.targetInfo:GetNpcName(key))
            end
        else

            -- Look for a team with a matching name
            local teamID = Rematch.savedTeams:GetTeamIDByName(key)

            if teamID then
                -- Does the team already have a matching script
                if not self:GetScript(teamID) then
                    -- print('found matching team with no script')
                    tinsert(moveTasks, {key, teamID, script})
                else
                    print('found a matching team, but it has a script.', key, teamID)
                end
            else
                print('no team found.', 'name:', key)
            end
        end
    end

    if #moveTasks>0 then
        for _, info in ipairs(moveTasks) do
            self:RemoveScript(info[1])
            self:AddScript(info[2], info[3])
        end
    end
end
