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
        The needed goals to win.
    ]]
    self.NEEDED_GOALS_TO_WIN = Config.Football.NeededGoalsToWin

    --[[
        The football asset tag.
    ]]
    self.FOOTBALL_ASSET_TAG = "football"

    --[[
        The arena asset tag.
    ]]
    self.ARENA_ASSET_TAG = "arena"

    --[[
        The car asset tag.
    ]]
    self.CAR_ASSET_TAG = "car"
end

--[[
    Called when the service is started.
]]
function Addon.Football:ServiceStart()
    self:SetupEvent()
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
        "Score the ball into the opposing team's goal."
    )

    Addon.Events:SetMinimumPlayersToStart(Config.Football.MinimumPlayers)
    Addon.Events:SetAutoTeamAssignEnabled(true)

    Addon.Events:CreateTeam(
        1,
        "RED"
    )

    Addon.Events:CreateTeam(
        2,
        "BLUE"
    )
end