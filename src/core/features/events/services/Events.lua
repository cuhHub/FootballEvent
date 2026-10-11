--------------------------------------------------------
-- Services - Events
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
    A service that acts a cuhHub event framework, managing the starting/stopping of events, teams, etc.
]]
---@class Events: NoirService
Addon.Events = Noir.Services:CreateService(
    "Events",
    false,
    "A service that acts a cuhHub event framework.",
    "A service that acts a cuhHub event framework, managing the starting/stopping of events, teams, etc.",
    {"Cuh4"}
)

--[[
    Called when this service is initialized.
]]
function Addon.Events:ServiceInit()
    --[[
        The name of the event.
    ]]
    self.EventName = "Undefined"

    --[[
        The description of the event.
    ]]
    self.EventDescription = "No description provided."

    --[[
        The message to show to players describing what they have to do.<br>
        Used in event start message.
    ]]
    self.EventObjectiveMessage = "No objective provided."

    --[[
        The minimum players needed for the event to start.
    ]]
    self.MinimumPlayersToStart = 2

    --[[
        Whether the event has started.
    ]]
    self.HasEventStarted = false

    --[[
        The partaking players, indexed by peer ID.
    ]]
    ---@type table<integer, NoirPlayer>
    self.PartakingPlayers = {}

    --[[
        The spectating players, indexed by peer ID.
    ]]
    ---@type table<integer, Spectator>
    self.SpectatingPlayers = {}

    --[[
        The teams in the event.
    ]]
    ---@type table<integer, Team>
    self.Teams = {}

    --[[
        The winning players.
    ]]
    ---@type table<integer, NoirPlayer>
    self.WinningPlayers = {}

    --[[
        Represents if automatic team assignement is enabled.<br>
        If enabled, players will be assigned to a random team when the event starts. The teams will be balanced.
    ]]
    self.IsAutoTeamAssignEnabled = true

    --[[
        Called when the events start.
    ]]
    self.OnStart = Noir.Libraries.Events:Create()

    --[[
        Called when the events end.<br>
        Arguments: winners (`NoirPlayer[]`)
    ]]
    self.OnEnd = Noir.Libraries.Events:Create()

    --[[
        Called every tick while event is active.
    ]]
    self.OnTick = Noir.Libraries.Events:Create()

    --[[
        Called when a player joins the event.<br>
        Arguments: player (`NoirPlayer`)
    ]]
    self.OnParticipantAdd = Noir.Libraries.Events:Create()

    --[[
        Called when a player leaves the event, e.g. due to elimination.<br>
        Arguments: player (`NoirPlayer`), reason (`string|nil`)
    ]]
    self.OnParticipantRemove = Noir.Libraries.Events:Create()

    --[[
        The position of the hub.
    ]]
    self.HUB_POSITION = matrix.translation(0, 500, 0)

    --[[
        The radius of the hub area (meters).
    ]]
    self.HUB_RADIUS = 25
end

--[[
    Called when this service is started.
]]
function Addon.Events:ServiceStart()
    --[[
        The hub asset.
    ]]
    self.HubAsset = Addon.Assets:Find({"event_hub"})[1] or error("Events", "Could not find hub asset (tag: event_hub).")

    --[[
        The hub vehicle.
    ]]
    self.Hub = self:SpawnHub()

    --[[
        A connection to `PlayerService`'s `OnJoin` event.
    ]]
    ---@param player NoirPlayer
    self.OnJoinConnection = Noir.Services.PlayerService.OnJoin:Connect(function(player)
        self:_HandlePlayerJoin(player)
    end)

    --[[
        A connection to `PlayerService`'s `OnLeave` event.
    ]]
    ---@param player NoirPlayer
    self.OnLeaveConnection = Noir.Services.PlayerService.OnLeave:Connect(function(player)
        self:_HandlePlayerLeave(player)
    end)

    --[[
        A connection to `onTick`.
    ]]
    self.OnTickConnection = Noir.Callbacks:Connect("onTick", function()
        self:_HandleTick()
    end)

    --[[
        A task to keep players in the hub.
    ]]
    self.KeepPlayersInHubTask = Noir.Services.TaskService:AddTimeTask(function()
        self:KeepPlayersInHub()
    end, 0.1, nil, true)

    -- Create UI
    self:CreateEventInfoUI()
    self:CreateTeamUI()
    self:CreateSpectatorUI()

    -- Create commands
    self:CreateCommands()

    -- Register flags
    self:RegisterFlags()
end

--[[
    Keeps all relevant players in the hub.
]]
function Addon.Events:KeepPlayersInHub()
    if self.HasEventStarted then
        return
    end

    for _, player in pairs(Noir.Services.PlayerService:GetPlayers(true)) do
        if self:IsPlayerPartaking(player) then
            goto continue
        end

        if self:IsPlayerSpectating(player) then
            goto continue
        end

        if self:IsPlayerInHub(player) then
            goto continue
        end

        self:TeleportPlayerToHub(player)

        ::continue::
    end
end

--[[
    Returns if a player is in the hub or not.
]]
---@param player NoirPlayer The player to check
---@return boolean
function Addon.Events:IsPlayerInHub(player)
    return Addon.Libs.Matrix:GetSquaredDistance(player:GetPosition(), self.HUB_POSITION) < self.HUB_RADIUS * self.HUB_RADIUS
end

--[[
    Teleports a player to the hub.
]]
---@param player NoirPlayer The player to teleport
function Addon.Events:TeleportPlayerToHub(player)
    if not Addon.Flags:IsEnabled("Events.HubTeleport") then
        return
    end

    local character = player:GetCharacter()

    if not character then
        return -- player hasnt loaded in fully yet. teleporting them would cause a ctd. fucking stormworks
    end

    if not character.Loaded then
        return -- just in case character is not nil even when player hasnt loaded. i cant be fucked to test exactly what happens so lets hope one of these two checks work properly
    end

    if character:IsDowned() then
        return
    end

    player:Teleport(Noir.Libraries.Matrix:Offset(self.HUB_POSITION, 0, 5, 0))
end

--[[
    Spawns the hub.
]]
---@return NoirVehicle
function Addon.Events:SpawnHub()
    local vehicle = self.HubAsset:SpawnVehicle(self.HUB_POSITION)
    Addon.Janitor:DisposeVehicle(vehicle)

    return vehicle
end

--[[
    Starts the event.
]]
function Addon.Events:StartEvent()
    if self.HasEventStarted then
        Addon.Logger:Warning("Events: Cannot start event, event has already started.")
        return
    end

    if self:GetPlayerCount() < self.MinimumPlayersToStart then
        Addon.Logger:Warning("Events: Cannot start event, not enough players.")
        return
    end

    self.HasEventStarted = true
    self:FillParticipants()

    if self.IsAutoTeamAssignEnabled then
        self:AutoAssignTeams()
    end

    for _, participant in pairs(self:GetPartakingPlayers()) do
        Addon.Libs.Player:HealPlayer(participant)
    end

    self:_AnnounceEventStart()
    self.OnStart:Fire()
end

--[[
    Announces the event start to all players.
]]
function Addon.Events:_AnnounceEventStart()
    Addon.Message:Send(
        nil,
        "Event",
        "The event has started! Good luck!\n\nYour Objective:\n"..self.EventObjectiveMessage,
        Addon.Enums.NotificationType.INFO
    )

    Addon.Interface:SendLiveChat(
        "Event",
        "The event has started!",
        ":money_with_wings:",
        125,
        200,
        125
    )
end

--[[
    Ends the event.
]]
function Addon.Events:EndEvent()
    if not self.HasEventStarted then
        Addon.Logger:Warning("Events: Cannot end event, event has not started.")
        return
    end

    self.HasEventStarted = false

    local winners = self:GetWinningPlayers()
    self:ClearWinningPlayers()
    self:ClearTeams()
    self:ClearSpectators()
    self:ClearParticipants()

    self:_AnnounceEventEnd(winners)
    self.OnEnd:Fire(winners)
end

--[[
    Announces the event end to all players.
]]
---@param winners table<integer, NoirPlayer> The winning players
function Addon.Events:_AnnounceEventEnd(winners)
    ---@type table<integer, string>
    local formattedWinners = {}

    for _, player in pairs(winners) do
        table.insert(formattedWinners, Addon.Libs.Player:FormatPlayerName(player))
    end

    if #formattedWinners <=  0 then
        formattedWinners = {"No winners."}
    end

    Addon.Message:Send(
        nil,
        "Event",
        "The event has ended!\n\nWinner(s):\n"..table.concat(formattedWinners, "\n"),
        Addon.Enums.NotificationType.SUCCESS
    )

    Addon.Interface:SendLiveChat(
        "Event",
        "The event has ended! Winners: "..table.concat(formattedWinners, ", "),
        ":crown:",
        100,
        235,
        100
    )
end

--[[
    Sets the event information.
]]
---@param name string The event name
---@param description string The event description
---@param objective string The event objective message
function Addon.Events:SetEventInfo(name, description, objective)
    self.EventName = name
    self.EventDescription = description
    self.EventObjectiveMessage = objective
end

--[[
    Sets the minimum players needed to start.
]]
---@param minimumPlayers integer The minimum players needed to start
function Addon.Events:SetMinimumPlayersToStart(minimumPlayers)
    self.MinimumPlayersToStart = minimumPlayers
end

--[[
    Sets whether teams should automatically be assigned on event start.
]]
---@param enabled boolean Whether teams should automatically be assigned
function Addon.Events:SetAutoTeamAssignEnabled(enabled)
    self.IsAutoTeamAssignEnabled = enabled
end

--[[
    Returns if a player is a winner.
]]
---@param player NoirPlayer The player to check
---@return boolean
function Addon.Events:IsPlayerWinner(player)
    return self.WinningPlayers[player.ID] ~= nil
end

--[[
    Adds a player to the winners.
]]
---@param player NoirPlayer The player to add
function Addon.Events:AddWinningPlayer(player)
    self.WinningPlayers[player.ID] = player
end

--[[
    Adds all players in a team to the winners.
]]
---@param team Team The team to add
function Addon.Events:AddWinningTeam(team)
    for _, member in pairs(team:GetMembers()) do
        self:AddWinningPlayer(member.Player)
    end
end

--[[
    Clears winning players.
]]
function Addon.Events:ClearWinningPlayers()
    self.WinningPlayers = {}
end

--[[
    Returns all winning players.
]]
---@return table<integer, NoirPlayer>
function Addon.Events:GetWinningPlayers()
    return self.WinningPlayers
end

--[[
    Automatically assigns participants to teams evenly.
]]
function Addon.Events:AutoAssignTeams()
    if not self:IsTeamBasedEvent() then -- no teams
        return
    end

    self:ClearTeams()

    local teams = Noir.Libraries.Table:Values(self:GetTeams())
    local teamCount = #teams

    local participants = self:GetPartakingPlayers()
    participants = Noir.Libraries.Table:Values(participants)
    participants = Addon.Libs.Table:Shuffle(participants)

    local i = 1

    for _, participant in pairs(participants) do
        teams[i]:AddMember(participant)
        i = (i % teamCount) + 1
    end
end

--[[
    Creates a team.
]]
---@param ID integer The team ID
---@param name string The team name
---@return Team
function Addon.Events:CreateTeam(ID, name)
    local team = Addon.Classes.Team:New(ID, name)
    self.Teams[ID] = team

    return team
end

--[[
    Gets a team by ID.
]]
---@param ID integer The team ID
---@return Team|nil
function Addon.Events:GetTeamByID(ID)
    return self:GetTeams()[ID]
end

--[[
    Returns all teams.
]]
---@return table<integer, Team>
function Addon.Events:GetTeams()
    return self.Teams
end

--[[
    Returns the team a player is in, if any.
]]
---@param player NoirPlayer The player to check
---@return Team|nil
function Addon.Events:GetPlayerTeam(player)
    for _, team in pairs(self:GetTeams()) do
        if team:IsInTeam(player) then
            return team
        end
    end
end

--[[
    Clears all teams.
]]
function Addon.Events:ClearTeams()
    for _, team in pairs(self:GetTeams()) do
        team:Clear()
    end
end

--[[
    Returns if any teams exist.
]]
---@return boolean
function Addon.Events:IsTeamBasedEvent()
    return Noir.Libraries.Table:Length(self.Teams) >= 1
end

--[[
    Returns all spectators.
]]
---@return table<integer, Spectator>
function Addon.Events:GetSpectators()
    return self.SpectatingPlayers
end

--[[
    Returns if a player is a spectator.
]]
---@param player NoirPlayer The player to check
---@return boolean
function Addon.Events:IsPlayerSpectating(player)
    return self.SpectatingPlayers[player.ID] ~= nil
end

--[[
    Makes a player spectate.
]]
---@param player NoirPlayer The player to make spectate
---@return Spectator
function Addon.Events:MakePlayerSpectate(player)
    local spectator = Addon.Classes.Spectator:New(player)
    self.SpectatingPlayers[player.ID] = spectator

    return spectator
end

--[[
    Returns spectator from player.
]]
---@param player NoirPlayer The player to get the spectator instance from
---@return Spectator|nil
function Addon.Events:GetSpectatorFromPlayer(player)
    return self.SpectatingPlayers[player.ID]
end

--[[
    Clears all spectators.
]]
function Addon.Events:ClearSpectators()
    for _, spectator in pairs(self:GetSpectators()) do
        self:StopPlayerSpectating(spectator.Player)
    end
end

--[[
    Stops a player from spectating.
]]
---@param player NoirPlayer The player to stop spectating
function Addon.Events:StopPlayerSpectating(player)
    local spectator = self:GetSpectatorFromPlayer(player)

    if not spectator then
        return
    end

    spectator:Cleanup()
    self.SpectatingPlayers[player.ID] = nil
end

--[[
    Updates all spectators.
]]
function Addon.Events:UpdateSpectators()
    for _, spectator in pairs(self:GetSpectators()) do
        spectator:Update()
    end
end

--[[
    Returns all partaking players.
]]
---@return table<integer, NoirPlayer>
function Addon.Events:GetPartakingPlayers()
    return self.PartakingPlayers
end

--[[
    Returns the amount of partaking players.
]]
---@return integer
function Addon.Events:GetPartakingPlayerCount()
    return Noir.Libraries.Table:Length(self.PartakingPlayers)
end

--[[
    Returns the amount of players in the server.
]]
---@return integer
function Addon.Events:GetPlayerCount()
    return #Noir.Services.PlayerService:GetPlayers(false)
end

--[[
    Returns if a player is partaking in the event.
]]
---@param player NoirPlayer The player to check
---@return boolean
function Addon.Events:IsPlayerPartaking(player)
    return self.PartakingPlayers[player.ID] ~= nil
end

--[[
    Adds all players in the server as participants.
]]
function Addon.Events:FillParticipants()
    for _, player in pairs(Noir.Services.PlayerService:GetPlayers()) do
        self:AddPartakingPlayer(player)
    end
end

--[[
    Removes all participants.
]]
function Addon.Events:ClearParticipants()
    for _, player in pairs(self:GetPartakingPlayers()) do
        self:RemovePartakingPlayer(player)
    end
end

--[[
    Adds a player as a participant.
]]
---@param player NoirPlayer The player to add
function Addon.Events:AddPartakingPlayer(player)
    if self:IsPlayerPartaking(player) then
        Addon.Logger:Warning("Events: Cannot add player %s as a participant, they are already partaking in the event.", player.Name)
        return
    end

    if not self.HasEventStarted then
        Addon.Logger:Warning("Events: Cannot add player %s as a participant, event hasn't started.", player.Name)
        return
    end

    if self:IsPlayerSpectating(player) then
        Addon.Logger:Warning("Events: Cannot add player %s as a participant, they are currently spectating.", player.Name)
        return
    end

    player:SetAudioMood(4)
    self.PartakingPlayers[player.ID] = player
    self.OnParticipantAdd:Fire(player)
end

--[[
    Removes a player as a participant.
]]
---@param player NoirPlayer The player to remove
---@param reason string|nil The reason the player was removed
function Addon.Events:RemovePartakingPlayer(player, reason)
    if not self:IsPlayerPartaking(player) then
        Addon.Logger:Warning("Events: Cannot remove player %s as a participant, they are not partaking in the event.", player.Name)
        return
    end

    self.OnParticipantRemove:Fire(player, reason)

    local team = self:GetPlayerTeam(player)

    if team then
        team:RemoveMember(team:GetMember(player))
    end

    player:SetAudioMood(2)

    Addon.Libs.Player:HealPlayer(player)
    Addon.Libs.Player:ClearPlayerItems(player)

    self.PartakingPlayers[player.ID] = nil

    if self.HasEventStarted then
        self:MakePlayerSpectate(player)

        Addon.Message:SendNotification(
            player,
            "Elimination",
            Addon.Libs.Player:FormatPlayerName(player).." has been eliminated.",
            Addon.Enums.NotificationType.ERROR
        )

        Addon.Message:Send(
            player,
            "Elimination",
            "You have been eliminated. You will now be made a spectator."..(reason and "\nReason: "..reason or ""),
            Addon.Enums.NotificationType.ERROR,
            reason
        )

        Addon.Interface:SendLiveChat(
            "Event",
            Addon.Libs.Player:FormatPlayerName(player).." has been eliminated.",
            ":x:",
            215,
            50,
            50
        )
    else
        self:TeleportPlayerToHub(player)
    end
end

Addon.Events.Eliminate = Addon.Events.RemovePartakingPlayer

--[[
    Handles a tick.
]]
function Addon.Events:_HandleTick()
    if not self.HasEventStarted then
        return
    end

    self:UpdateSpectators()
    self.OnTick:Fire()
end

--[[
    Handles a new player joining.
]]
---@param player NoirPlayer The player that joined
function Addon.Events:_HandlePlayerJoin(player)
    if self.HasEventStarted then
        self:MakePlayerSpectate(player)
    end
end

--[[
    Handles a player leaving.
]]
---@param player NoirPlayer The player that left
function Addon.Events:_HandlePlayerLeave(player)
    if self:IsPlayerPartaking(player) then
        self:RemovePartakingPlayer(player, "Player left")
    end

    if self:IsPlayerSpectating(player) then
        self:StopPlayerSpectating(player)
    end
end

--[[
    Sends an announcement for all players.
]]
---@param message string The message to send
---@param ... any String formatting arguments
function Addon.Events:SendAdministrativeAnnouncement(message, ...)
    Addon.Message:Send(
        nil,
        "Event",
        message,
        Addon.Enums.NotificationType.ANNOUNCEMENT,
        ...
    )

    Addon.Interface:SendLiveChat(
        "Event",
        ... and message:format(...) or message,
        ":loudspeaker:",
        175,
        175,
        215
    )
end

--[[
    Creates an event administration command.
]]
---@param name string The command name
---@param callback fun(player: NoirPlayer, args: table<integer, string>)
function Addon.Events:CreateEventAdminCommand(name, callback)
    Noir.Services.CommandService:CreateCommand(
        name,
        {},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            callback(context.Player, context.Args)
        end
    )
end

--[[
    Creates commands.
]]
function Addon.Events:CreateCommands()
    Noir.Services.CommandService:CreateCommand(
        "team",
        {"t"},
        false,
        false,
        false,
        nil,

        function(context)
            local team = self:GetPlayerTeam(context.Player)

            if not team then
                return
            end

            local member = team:GetMember(context.Player)
            local teamMessage = table.concat(context.Args, " ")
            member:SendTeamChatMessage(teamMessage)
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "spectate",
        {"s"},
        false,
        false,
        false,
        nil,

        function(context)
            local spectator = self:GetSpectatorFromPlayer(context.Player)

            if not spectator then
                return
            end

            local targetID = tonumber(context.Args[1])

            if not targetID then
                Addon.Message:Send(
                    context.Player,
                    "Spectate",
                    "Please provide a valid player ID.\nExample: '?s 1'",
                    Addon.Enums.NotificationType.ERROR
                )

                return
            end

            local targetPlayer = Noir.Services.PlayerService:GetPlayer(targetID)

            if not targetPlayer then
                Addon.Message:Send(
                    context.Player,
                    "Spectate",
                    "Please provide a valid player ID.\nExample: '?s 1'",
                    Addon.Enums.NotificationType.ERROR
                )

                return
            end

            if not spectator:CanSpectatePlayer(targetPlayer) then
                Addon.Message:Send(
                    context.Player,
                    "Spectate",
                    "You cannot spectate %s.",
                    Addon.Enums.NotificationType.ERROR,
                    Addon.Libs.Player:FormatPlayerName(targetPlayer)
                )

                return
            end

            spectator:SpectatePlayer(targetPlayer)
        end
    )

    self:CreateEventAdminCommand("start", function(player, args)
        if self.HasEventStarted then
            return
        end

        self:StartEvent()
    end)

    self:CreateEventAdminCommand("end", function(player, args)
        if not self.HasEventStarted then
            return
        end

        self:EndEvent()
    end)

    self:CreateEventAdminCommand("assignteams", function(player, args)
        if not self.HasEventStarted then
            return
        end

        self:AutoAssignTeams()
    end)

    self:CreateEventAdminCommand("announce", function(player, args)
        local message = table.concat(args, " ")
        self:SendAdministrativeAnnouncement(message)
    end)

    self:CreateEventAdminCommand("setminplayers", function(player, args)
        local minimumPlayers = tonumber(args[1])

        if not minimumPlayers then
            Addon.Message:Send(
                player,
                "Event",
                "Please provide a valid number of players.",
                Addon.Enums.NotificationType.ERROR
            )

            return
        end

        self:SetMinimumPlayersToStart(minimumPlayers)
    end)
end

--[[
    Creates event info UI.
]]
function Addon.Events:CreateEventInfoUI()
    --[[
        A UI hook for event info UI.
    ]]
    self.EventInfoUIHook = Addon.UI.GlobalUIHook:Connect(function()
        ---@type NoirScreenPopupWidget
        local eventInfo = Addon.UI:WrapWidget("EventInfo", Noir.Services.UIService:CreateScreenPopup(
            "",
            0,
            0,
            false
        ))

        Addon.UI:OnUIUpdate(nil, function()
            if not self.HasEventStarted then
                local playerCount = self:GetPlayerCount()
                local neededPlayers = self.MinimumPlayersToStart - playerCount

                eventInfo.Text = ("---\ncuhHub\nEvent\n---\n%s:\n%s\n\n%s."):format(
                    self.EventName:upper(),
                    self.EventDescription,
                    playerCount < self.MinimumPlayersToStart and ("Waiting for %d more player(s)..."):format(neededPlayers) or "Starting soon..."
                )

                eventInfo.Y = 0.55
                eventInfo.Visible = true
            else
                eventInfo.Visible = false
            end

            eventInfo:Update()
        end)
    end)
end

--[[
    Creates team UI.
]]
function Addon.Events:CreateTeamUI()
    --[[
        A UI hook for team UI.
    ]]
    ---@param player NoirPlayer
    self.TeamUIHook = Addon.UI.PlayerUIHook:Connect(function(player)
        ---@type NoirScreenPopupWidget
        local teamUI = Addon.UI:WrapWidget("Team", Noir.Services.UIService:CreateScreenPopup(
            "",
            0,
            0,
            false,
            player
        ))

        Addon.UI:OnUIUpdate(player, function()
            local team = self:GetPlayerTeam(player)

            if team then
                teamUI.Text = ("---\nTeam\n%s\n---\n%s\n---\nUse '?t <message>' for team chat"):format(team.Name, table.concat(team:GetFormattedNames(), "\n"))
                teamUI.Visible = true
            else
                teamUI.Visible = false
            end

            teamUI.X = -0.9
            teamUI.Y = 0.3
            teamUI:Update()
        end)
    end)
end

--[[
    Creates spectator UI.
]]
function Addon.Events:CreateSpectatorUI()
    --[[
        A UI hook for spectator UI.
    ]]
    self.SpectatorUIHook = Addon.UI.PlayerUIHook:Connect(function(player)
        ---@type NoirScreenPopupWidget
        local spectatorUI = Addon.UI:WrapWidget("Spectator", Noir.Services.UIService:CreateScreenPopup(
            "",
            0,
            0.7,
            false,
            player
        ))

        Addon.UI:OnUIUpdate(player, function()
            local spectator = self:GetSpectatorFromPlayer(player)

            if spectator then
                spectatorUI.Text = ("---\nSpectating\n---\n%s\n---\nUse '?s <Peer ID>' to spectate another player"):format(
                    spectator.TargetPlayer and Addon.Libs.Player:FormatPlayerName(spectator.TargetPlayer) or "N/A"
                )
            end

            spectatorUI.Visible = spectator ~= nil
            spectatorUI:Update()
        end)
    end)
end

--[[
    Registers flags.
]]
function Addon.Events:RegisterFlags()
    Addon.Flags:RegisterFlag(
        "Events.HubTeleport",
        true
    )
end