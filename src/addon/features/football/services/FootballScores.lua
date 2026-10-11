--------------------------------------------------------
-- Services - Football Scores
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
    A service to handle team scores.
]]
---@class FootballScores: NoirService
Addon.FootballScores = Noir.Services:CreateService(
    "FootballScores",
    false,
    "A service to handle team scores.",
    "A service to handle team scores.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.FootballScores:ServiceInit()
    --[[
        The needed goals to win.
    ]]
    self.NEEDED_GOALS_TO_WIN = Config.Football.NeededGoalsToWin

    --[[
        Per-team scores.
    ]]
    ---@type table<Team, TeamScore>
    self.TeamScores = {}

    --[[
        An event fired when a team scores.<br>
        Arguments: teamScore (TeamScore)
    ]]
    self.OnTeamScore = Noir.Libraries.Events:Create()

    --[[
        An event fired when a team gets enough scores to win.<br>
        Arguments: teamScore (TeamScore)
    ]]
    self.OnTeamWin = Noir.Libraries.Events:Create()
end

--[[
    Called when the service is started.
]]
function Addon.FootballScores:ServiceStart()
    self:CreateUI()
end

--[[
    Scores a goal for a team.
]]
---@param team Team The team to score for
function Addon.FootballScores:ScoreGoal(team)
    local teamScore = self:GetTeamScore(team)
    teamScore:IncrementScore()
end

--[[
    Sets up scores for a team.
]]
---@param team Team The team to set up scores for
function Addon.FootballScores:CreateTeamScore(team)
    local teamScore = Addon.Classes.TeamScore:New(team, self.NEEDED_GOALS_TO_WIN)
    self:TrackTeamScore(teamScore)

    self.TeamScores[team] = teamScore

    Addon.Logger:Info("FootballScores: Created team score for team %s (%s).", team.Name, team.ID)
end

--[[
    Returns a team's score.
]]
---@param team Team The team to get the score for
---@return TeamScore
function Addon.FootballScores:GetTeamScore(team)
    local score = self.TeamScores[team]

    if not score then
        error("Addon.FootballScores:GetTeamScore()", "Team has no score instance.")
    end

    return score
end

--[[
    Returns all team scores.
]]
---@return table<Team, TeamScore>
function Addon.FootballScores:GetTeamScores()
    return self.TeamScores
end

--[[
    Resets all scores.
]]
function Addon.FootballScores:ResetScores()
    for _, teamScore in pairs(self:GetTeamScores()) do
        teamScore:ResetScore()
    end
end

--[[
    Celebrates a goal.
]]
---@param teamScore TeamScore The team score instance
function Addon.FootballScores:CelebrateGoal(teamScore)
    Addon.Message:Send(
        nil,
        "SCORE!!!",
        "%s has scored a goal (%s/%s)!",
        Addon.Enums.NotificationType.SUCCESS,
        teamScore:GetTeam().Name,
        teamScore:GetScore(),
        teamScore:GetWinThreshold()
    )
end

--[[
    Tracks team score events.
]]
---@param teamScore TeamScore The team score instance
function Addon.FootballScores:TrackTeamScore(teamScore)
    teamScore.OnScoreChanged:Connect(function()
        self.OnTeamScore:Fire(teamScore)
        self:CelebrateGoal(teamScore)
    end)

    teamScore.OnScorePassWinThreshold:Connect(function()
        self.OnTeamWin:Fire(teamScore)
    end)
end

--[[
    Formats scores.
]]
---@return string
function Addon.FootballScores:FormatScores()
    ---@type table<integer, string>
    local formatted = {}

    for _, score in pairs(self:GetTeamScores()) do
        table.insert(formatted, ("%s (%s)"):format(score:GetScore(), score:GetTeam().Name))
    end

    return table.concat(formatted, "\n")
end

--[[
    Creates UI.
]]
function Addon.FootballScores:CreateUI()
    Addon.UI.GlobalUIHook:Connect(function()
        ---@type NoirScreenPopupWidget
        local scoresUI = Addon.UI:WrapWidget("TeamScores", Noir.Services.UIService:CreateScreenPopup(
            "",
            0,
            -0.72,
            false
        ))

        Addon.UI:OnUIUpdate(nil, function()
            if Addon.Events.HasEventStarted then
                scoresUI.Text = self:FormatScores()
                scoresUI.Visible = true
            else
                scoresUI.Visible = false
            end

            scoresUI:Update()
        end)
    end)
end