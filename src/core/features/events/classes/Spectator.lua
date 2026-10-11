--------------------------------------------------------
-- Classes - Spectator
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
    A class representing a spectator.
]]
---@class Spectator: NoirClass
---@field New fun(self: Spectator, player: NoirPlayer): Spectator
Addon.Classes.Spectator = Noir.Class("Spectator")

--[[
    Initializes `Spectator` class instances.
]]
---@param player NoirPlayer The player who is spectating
function Addon.Classes.Spectator:Init(player)
    --[[
        Offset from target player that the spectator should be teleported to (meters).
    ]]
    self.SPECTATE_OFFSET = matrix.translation(25, 30, 25)

    --[[
        The default position to spectate if there is no target player.
    ]]
    self.DEFAULT_SPECTATE_POSITION = Addon.Events.HUB_POSITION

    --[[
        The player who is spectating.
    ]]
    self.Player = player

    --[[
        The target player to spectate.
    ]]
    ---@type NoirPlayer|nil
    self.TargetPlayer = nil

    --[[
        Connection to `PlayerService`'s `OnLeave`.
    ]]
    ---@param _player NoirPlayer
    self.OnLeaveConnection = Noir.Services.PlayerService.OnLeave:Connect(function(_player)
        if not self.TargetPlayer then
            return
        end

        if Noir.Services.PlayerService:IsSamePlayer(_player, self.TargetPlayer) then
            self:SpectateRandom()
        end
    end)
end

--[[
    Returns the spectator target position.
]]
---@return SWMatrix
function Addon.Classes.Spectator:GetTargetPosition()
    return Noir.Libraries.Matrix:Offset(
        self.TargetPlayer and self.TargetPlayer:GetPosition() or self.DEFAULT_SPECTATE_POSITION,
        self.SPECTATE_OFFSET[13],
        self.SPECTATE_OFFSET[14],
        self.SPECTATE_OFFSET[15]
    )
end

--[[
    Spectator default position.
]]
function Addon.Classes.Spectator:SpectateNoOne()
    self.TargetPlayer = nil

    Addon.Logger:Info(
        "Spectator: %s set to spectate no one.",
        Addon.Libs.Player:FormatPlayerName(self.Player)
    )
end

--[[
    Spectates a random event participant.
]]
function Addon.Classes.Spectator:SpectateRandom()
    local participants = Noir.Libraries.Table:Values(Addon.Events:GetPartakingPlayers())

    ---@type table<integer, NoirPlayer>
    local canSpectate = {}

    for _, participant in pairs(participants) do
        if not self:CanSpectatePlayer(participant) then
            goto continue
        end

        table.insert(canSpectate, participant)

        ::continue::
    end

    ---@type NoirPlayer
    local participant = Noir.Libraries.Table:Random(canSpectate)

    if not participant then
        self:SpectateNoOne()
        return
    end

    self:SpectatePlayer(participant)
end

--[[
    Returns if a player can be spectated.
]]
---@param player NoirPlayer The player to check
---@return boolean
function Addon.Classes.Spectator:CanSpectatePlayer(player)
    if not Addon.Events:IsPlayerPartaking(player) then
        return false
    end

    if Noir.Services.PlayerService:IsSamePlayer(player, self.Player) then
        return false
    end

    return true
end

--[[
    Spectates a player.
]]
---@param player NoirPlayer The player to spectate
function Addon.Classes.Spectator:SpectatePlayer(player)
    if not self:CanSpectatePlayer(player) then
        error("Spectator", ":SpectatePlayer(): Cannot spectate player %s.", player.Name)
    end

    self.TargetPlayer = player

    Addon.Message:Send(
        self.Player,
        "Spectating",
        "You are now spectating %s.",
        Addon.Enums.NotificationType.SUCCESS,
        Addon.Libs.Player:FormatPlayerName(self.TargetPlayer)
    )

    Addon.Logger:Info(
        "Spectator: Making %s spectate %s.",
        Addon.Libs.Player:FormatPlayerName(self.Player),
        Addon.Libs.Player:FormatPlayerName(self.TargetPlayer)
    )
end

--[[
    Updates this spectator.<br>
    Called every tick.
]]
function Addon.Classes.Spectator:Update()
    if self.TargetPlayer and not self:CanSpectatePlayer(self.TargetPlayer) then
        self:SpectateRandom()
    end

    Addon.Libs.Player:HealPlayer(self.Player)
    self.Player:Teleport(self:GetTargetPosition())
end

--[[
    Call upon removing this spectator.
]]
function Addon.Classes.Spectator:Cleanup()
    self.OnLeaveConnection:Disconnect()
end