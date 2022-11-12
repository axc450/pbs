--[[
Action.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local ns     = select(2, ...)
local Util   = ns.Util
local Addon  = ns.Addon
local Action = {} ns.Action = Action

Action.apis = {}

function Addon:RegisterAction(...)
    local last = select('#', ...)
    local method = select(last, ...)

    if last < 2 or type(method) ~= 'function' then
        error('Usage: :RegisterAction(name, [name2, ...], method)')
    end

    for i = 1, last - 1 do
        Action.apis[select(i, ...)] = method
    end
end

function Action:CallAction(action, run)
    local cmd, value = self:ParseAction(action)

    local fn = self.apis[cmd]
    return fn and ((value ~= nil and fn(value, run)) or (value == nil and fn(run)))
end

function Action:Run(action)
    return self:CallAction(action, true)
end

function Action:Test(action)
    return self:CallAction(action, false)
end

function Action:ParseAction(action)
    Util.assert(type(action) == 'string', 'Invalid Action: `%s`', action)

    if action:find('^%-%-') then
        return '--', action
    end

    local cmd, value = Util.ParseQuote(action)

    Util.assert(cmd, 'Invalid Action: `%s`', action)
    Util.assert(self.apis[cmd], 'Invalid Action: `%s` (Not found command)', action)

    return cmd, value ~= '' and value or nil
end
