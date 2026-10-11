--------------------------------------------------------
-- Classes - Team Member
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
    A class representing a team member.
]]
---@class TeamMember: NoirClass
---@field New fun(self: TeamMember, player: NoirPlayer, parentTeam: Team): TeamMember
Addon.Classes.TeamMember = Noir.Class("TeamMember")

--[[
    Initializes `TeamMember` class instances.
]]
---@param player NoirPlayer The player to add to the team
---@param parentTeam Team The team to add the player to
function Addon.Classes.TeamMember:Init(player, parentTeam)
    --[[
        The Y offset for the identification widget (meters).
    ]]
    self.IDENTIFICATION_WIDGET_Y_OFFSET = 1.2

    --[[
        The render distance for the identification widget (meters).
    ]]
    self.IDENTIFICATION_WIDGET_RENDER_DISTANCE = 10

    --[[
        The player.
    ]]
    self.Player = player

    --[[
        The team this member belongs to.
    ]]
    self.ParentTeam = parentTeam

    --[[
        Closet for identification widgets.
    ]]
    self.IdentificationWidgetCloset = Addon.Janitor:CreateCloset()
end

--[[
    Creates identification popup widgets for all other players to show this player's team.
]]
function Addon.Classes.TeamMember:SetupIdentificationWidgets()
    local character = self.Player:GetCharacter()

    if not character then
        error("TeamMember", ":SetupIdentificationWidget(): Player %s character is nil.", self.Player.Name)
    end

    for _, player in pairs(Addon.Events:GetPartakingPlayers()) do
        if Noir.Services.PlayerService:IsSamePlayer(player, self.Player) then
            goto continue
        end

        local widget = Noir.Services.UIService:CreatePopup(
            self.ParentTeam.Name,
            matrix.translation(0, 0, 0),
            self.IDENTIFICATION_WIDGET_RENDER_DISTANCE,
            true,
            player
        )

        widget.AttachmentOffset = matrix.translation(0, self.IDENTIFICATION_WIDGET_Y_OFFSET, 0)
        widget:AttachToObject(character)

        Addon.Janitor:DisposeWidget(widget)
        self.IdentificationWidgetCloset:Add(widget)

        ::continue::
    end
end

--[[
    Called when the member is added to a team.
]]
function Addon.Classes.TeamMember:OnAdd()
    self:SetupIdentificationWidgets()
end

--[[
    Called when the member is removed from the team.
]]
function Addon.Classes.TeamMember:OnRemove()
    self.IdentificationWidgetCloset:Cleanup()
end

--[[
    Sends a team chat message.
]]
---@param message string The message to send
function Addon.Classes.TeamMember:SendTeamChatMessage(message)
    for _, member in pairs(self.ParentTeam:GetMembers()) do
        Addon.Message:SendMessage(
            member.Player,
            ("%s (Team Chat)"):format(self.Player.Name),
            message
        )
    end
end