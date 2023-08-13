local ns = select(2, ...)
local Addon = ns.Addon


function Addon:UpdateDB()
	local scriptsDB = TD_DB_BATTLEPETSCRIPT_GLOBAL.global.scripts
	-- A rematch4 entry indicates the scripts have been migrated.
	if scriptsDB.Rematch4 then return end
	scriptsDB.Rematch4 = CopyTable(scriptsDB.Rematch)

	-- Force Rematch to update teams, so 'GetTeamIDByName' works
	Rematch.savedTeams:TeamsChanged(true)

	local moveTasks = {}

	for key, script in Addon:IterateScripts() do

		-- migrate scripts with a targetID
		if type(key)=="number" then
			-- Attach script to first team found
			local teams = Rematch.savedTargets[key]

			if teams then
				--print('found some teams, attaching to the first one')
				tinsert(moveTasks, {key, teams[1], script})
			else
				--print('no team found.', 'target:', Rematch.targetInfo:GetNpcName(key))
			end

		-- migrate script with team title string
		else
			local teamID = Rematch.savedTeams:GetTeamIDByName(key)

			if teamID then
				-- does the team already have a matching script
				if not Addon:GetScript(teamID) then
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

	if #moveTasks>0	then
		for _, info in ipairs(moveTasks) do
			Addon:RemoveScript(info[1])
			Addon:AddScript(info[2], info[3])
		end
	end
end
