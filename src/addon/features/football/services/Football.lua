--------------------------------------------------------
-- Services - Football
--------------------------------------------------------

--[[
    Copyright (C) 2026 cuhHub - All Rights Reserved
    - Unauthorized copying of this file, via any medium is strictly prohibited
    - Proprietary and confidential
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Handles the football event.
]]
---@class Football: NoirService
Addon.Football = Noir.Services:CreateService(
    "Football",
    false,
    "Handles the football event.",
    "Handles the football event.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Football:ServiceInit()
    --[[
        The kart asset tag.
    ]]
    self.KART_ASSET_TAG = "kart"
end

--[[
    Called when the service is started.
]]
function Addon.Football:ServiceStart()
    self:SetupEvent()
    self:SetupSettings()
    self:SetupTeams()
    self:HandleEventLifecycle()
    self:CreateCommands()
end

--[[
    Handles event lifecycle.
]]
function Addon.Football:HandleEventLifecycle()
    Addon.Events.OnStart:Connect(function()
        Addon.FootballArena:SpawnArena(function()
            Addon.FootballBall:SpawnBall()

            Addon.Events.EventEndCloset:Add(Noir.Services.TaskService:AddTimeTask(function()
                self:SpawnParticipants()
            end, Config.Football.StartDelaySecs))
        end)
    end)

    Addon.Events.OnEnd:Connect(function(winners)
        Addon.FootballArena:RemoveArena()
        Addon.FootballBall:RemoveBall()
        Addon.FootballScores:ResetScores()
    end)

    Addon.Events.OnTick:Connect(function()
        Addon.FootballBall:TryUpdateBall()

        if Addon.FootballBall:IsBallSpawned() then
            if Addon.FootballBall:IsBallBehindGoal(self.RedTeam) then
                Addon.FootballScores:ScoreGoal(self.BlueTeam)
            elseif Addon.FootballBall:IsBallBehindGoal(self.BlueTeam) then
                Addon.FootballScores:ScoreGoal(self.RedTeam)
            end
        end
    end)

    ---@param teamScore TeamScore
    Addon.FootballScores.OnTeamScore:Connect(function(teamScore)
        self:Reset()
    end)

    ---@param teamScore TeamScore
    Addon.FootballScores.OnTeamWin:Connect(function(teamScore)
        Addon.Events:AddWinningTeam(teamScore:GetTeam())
        Addon.Events:EndEvent()
    end)

    ---@param player NoirPlayer
    ---@param reason string|nil
    Addon.Events.OnParticipantRemove:Connect(function(player, reason)
        if not Addon.FootballKarts:HasKart(player) then
            return
        end

        Addon.FootballKarts:RemoveKart(player)
    end)
end

--[[
    Resets the match (not scores!).
]]
function Addon.Football:Reset()
    Addon.FootballBall:ResetBall()
    Addon.FootballKarts:ResetKarts()
end

--[[
    Spawns participants in their karts at appropriate spawn points.
]]
function Addon.Football:SpawnParticipants()
    local arena = Addon.FootballArena:GetArena()

    for _, team in pairs(Addon.Events:GetTeams()) do
        local members = Noir.Libraries.Table:Values(team:GetMembers())
        local positions = arena:GetTeamSpawnPositions(team)

        for memberIndex, position in pairs(positions) do
            local member = members[memberIndex]

            if not member then -- no more members, no need to iterate further
                break
            end

            Addon.FootballKarts:SpawnKart(member.Player, position)
        end
    end
end

--[[
    Sets up teams.
]]
function Addon.Football:SetupTeams()
    --[[
        The red team.
    ]]
    self.RedTeam = Addon.Events:CreateTeam(
        1,
        "Red"
    )

    Addon.FootballScores:CreateTeamScore(self.RedTeam)

    --[[
        The blue team.
    ]]
    self.BlueTeam = Addon.Events:CreateTeam(
        2,
        "Blue"
    )

    Addon.FootballScores:CreateTeamScore(self.BlueTeam)
end

--[[
    Sets up the event.
]]
function Addon.Football:SetupEvent()
    Addon.Events:SetEventInfo(
        "Football",
        ("Two teams, each player with a car. Score the ball into the opposing team's goal to increase your team's score. First to %s wins."):format(
            Config.Football.NeededGoalsToWin
        ),
        ("Score the ball into the opposing team's goal. First to %s wins."):format(
            Config.Football.NeededGoalsToWin
        )
    )

    Addon.Events:SetMinimumPlayersToStart(Config.Football.MinimumPlayers)
    Addon.Events:SetAutoTeamAssignEnabled(true)
end

--[[
    Configures game settings.
]]
function Addon.Football:SetupSettings()
    Noir.Services.GameSettingsService:SetSetting("player_damage", false)
    Noir.Services.GameSettingsService:SetSetting("vehicle_damage", false)
    Noir.Services.GameSettingsService:SetSetting("infinite_batteries", true)
end

--[[
    Creates commands.
]]
function Addon.Football:CreateCommands()
    Addon.Events:CreateEventAdminCommand("reset", function(player, args)
        self:Reset()
    end)

    Addon.Events:CreateEventAdminCommand("take", function(player, args)
        local teamID = tonumber(args[1])

        if not teamID then
            return
        end

        local team = Addon.Events:GetTeamByID(teamID)

        if not team then
            return
        end

        local score = Addon.FootballScores:GetTeamScore(team)

        if score then
            score:DecrementScore()
        end
    end)

    Addon.Events:CreateEventAdminCommand("spectate", function(player, args)
        Addon.Events:MakePlayerSpectate(player)
    end)
end