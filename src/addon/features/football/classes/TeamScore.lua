--------------------------------------------------------
-- Classes - Team Score
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
    A class to track a team's score.
]]
---@class TeamScore: NoirClass
---@field New fun(self: TeamScore, team: Team, winThreshold: integer): TeamScore
Addon.Classes.TeamScore = Noir.Class("TeamScore")

--[[
    Initializes new `TeamScore` instances.
]]
---@param team Team The team this is for
---@param winThreshold integer The score needed to win
function Addon.Classes.TeamScore:Init(team, winThreshold)
    --[[
        The team this is for.
    ]]
    self.Team = team

    --[[
        The score.
    ]]
    self.Score = 0

    --[[
        The score needed to win.
    ]]
    self.WinThreshold = winThreshold

    --[[
        An event fired when the score changes.
    ]]
    self.OnScoreChanged = Noir.Libraries.Events:Create()

    --[[
        An event fired when the score passes win threshold.
    ]]
    self.OnScorePassWinThreshold = Noir.Libraries.Events:Create()
end

--[[
    The team this is for.
]]
---@return Team
function Addon.Classes.TeamScore:GetTeam()
    return self.Team
end

--[[
    The score.
]]
---@return integer
function Addon.Classes.TeamScore:GetScore()
    return self.Score
end

--[[
    The score needed to win.
]]
---@return integer
function Addon.Classes.TeamScore:GetWinThreshold()
    return self.WinThreshold
end

--[[
    Sets the score.
]]
---@param score integer The score to set
function Addon.Classes.TeamScore:SetScore(score)
    if score == self:GetScore() then
        return
    end

    local winThreshold = self:GetWinThreshold()

    if score < 0 or score > winThreshold then
        return
    end

    local before = self:GetScore()
    self.Score = score

    Addon.Logger:Info("TeamScore: Set score for team %s (%s) to %s.", self:GetTeam().Name, self:GetTeam().ID, self:GetScore())

    if self:GetScore() > before then
        self.OnScoreChanged:Fire()
    end

    if self:GetScore() >= winThreshold then
        self.OnScorePassWinThreshold:Fire()
    end
end

--[[
    Increments the score.
]]
function Addon.Classes.TeamScore:IncrementScore()
    self:SetScore(self:GetScore() + 1)
end

--[[
    Decrements the score.
]]
function Addon.Classes.TeamScore:DecrementScore()
    self:SetScore(self:GetScore() - 1)
end

--[[
    Resets the score.
]]
function Addon.Classes.TeamScore:ResetScore()
    self:SetScore(0)
end