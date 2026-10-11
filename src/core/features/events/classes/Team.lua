--------------------------------------------------------
-- Classes - Team
--------------------------------------------------------

--[[
    Copyright (C) 2026 cuhHub

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing an event team.
]]
---@class Team: NoirClass
---@field New fun(self: Team, ID: integer, name: string): Team
Addon.Classes.Team = Noir.Class("Team")

--[[
    Initializes `Team` class instances.
]]
---@param ID integer The team ID
---@param name string The team name
function Addon.Classes.Team:Init(ID, name)
    --[[
        The ID of this team.
    ]]
    self.ID = ID

    --[[
        The name of this team.
    ]]
    self.Name = name

    --[[
        The players in this team, indexed by peer ID.
    ]]
    ---@type table<integer, TeamMember>
    self.Members = {}
end

--[[
    Adds a player to this team.
]]
---@param player NoirPlayer The player to add
function Addon.Classes.Team:AddMember(player)
    local member = Addon.Classes.TeamMember:New(player, self)
    self.Members[player.ID] = member

    member:OnAdd()

    Addon.Logger:Info("Team: Added %s to team %s (%s).", Addon.Libs.Player:FormatPlayerName(player), self.Name, self.ID)
end

--[[
    Gets a team member.
]]
---@param player NoirPlayer The player to get
---@return TeamMember
function Addon.Classes.Team:GetMember(player)
    return self.Members[player.ID]
end

--[[
    Removes a member from this team.
]]
---@param member TeamMember The member to remove
function Addon.Classes.Team:RemoveMember(member)
    member:OnRemove()
    self.Members[member.Player.ID] = nil

    Addon.Logger:Info("Team: Removed %s from team %s (%s).", Addon.Libs.Player:FormatPlayerName(member.Player), self.Name, self.ID)
end

--[[
    Clears the team.
]]
function Addon.Classes.Team:Clear()
    for _, member in pairs(self:GetMembers()) do
        self:RemoveMember(member)
    end
end

--[[
    Returns all members in this team.
]]
---@return table<integer, TeamMember>
function Addon.Classes.Team:GetMembers()
    return self.Members
end

--[[
    Returns the amonut of members in this team.
]]
---@return integer
function Addon.Classes.Team:GetMemberCount()
    return Noir.Libraries.Table:Length(self:GetMembers())
end

--[[
    Returns formatted names of all players in this team.
]]
---@return table<integer, string>
function Addon.Classes.Team:GetFormattedNames()
    ---@type table<integer, string>
    local formattedNames = {}

    for _, member in pairs(self:GetMembers()) do
        table.insert(formattedNames, Addon.Libs.Player:FormatPlayerName(member.Player))
    end

    return formattedNames
end

--[[
    Returns if a player is in this team.
]]
---@param player NoirPlayer The player to check
---@return boolean
function Addon.Classes.Team:IsInTeam(player)
    return self:GetMember(player) ~= nil
end