-- Version.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/4/2018, 9:56:44 PM

local ns = select(2, ...)
local Addon = ns.Addon

local Version = Addon:NewClass('Version')

ns.Version = Version

function Version:Constructor(major, minor, build, revision)
    self.major = major or 0
    self.minor = minor or 0
    self.build = build or 0
    self.revision = revision or 0
end

function Version:Current()
    local version = GetAddOnMetadata('Rematch', 'Version')
    if not version then
        return
    end

    local major, minor, build = version:match('^(%d+)%.(%d+)%.(%d+)')
    local revision = version:match('exp%-(%d+)')
    return Version:New(tonumber(major), tonumber(minor), tonumber(build), tonumber(revision))
end

local Meta = Version._Meta

function Meta.__lt(lhs, rhs)
    if lhs.major ~= rhs.major then
        return lhs.major < rhs.major
    end
    if lhs.minor ~= rhs.minor then
        return lhs.minor < rhs.minor
    end
    if lhs.build ~= rhs.build then
        return lhs.build < rhs.build
    end
    return lhs.revision < rhs.revision
end

function Meta.__eq(lhs, rhs)
    return lhs.major == rhs.major and
            lhs.minor == rhs.minor and
            lhs.build == rhs.build and
            lhs.revision == rhs.revision
end

function Meta.__tostring(self)
    return format('%d.%d.%d.%d', self.major, self.minor, self.build, self.revision)
end
