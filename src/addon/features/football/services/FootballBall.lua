--------------------------------------------------------
-- Services - Football Ball
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
    Handles the football ball.
]]
---@class FootballBall: NoirService
Addon.FootballBall = Noir.Services:CreateService(
    "FootballBall",
    false,
    "Handles the football ball.",
    "Handles the football ball.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.FootballBall:ServiceInit()
    --[[
        The ball.
    ]]
    ---@type Ball
    self.Ball = nil

    --[[
        The ball asset tag.
    ]]
    self.BALL_ASSET_TAG = "ball"
end

--[[
    Returns if the ball is spawned or not.
]]
---@return boolean
function Addon.FootballBall:IsBallSpawned()
    return self.Ball ~= nil
end

--[[
    Returns the ball.
]]
---@return Ball
function Addon.FootballBall:GetBall()
    if not self:IsBallSpawned() then
        error("Addon.FootballBall:GetBall()", "Ball is not spawned.")
    end

    return self.Ball
end

--[[
    Spawns the ball.
]]
function Addon.FootballBall:SpawnBall()
    if self:IsBallSpawned() then
        error("Addon.FootballBall:SpawnBall()", "Ball is already spawned.")
    end

    local asset = Addon.Assets:Find({self.BALL_ASSET_TAG})[1]

    if not asset then
        error("Addon.FootballBall:SpawnBall()", "Failed to find ball asset with tag '%s'.", self.BALL_ASSET_TAG)
    end

    self.Ball = Addon.Classes.Ball:New(asset, self:GetBallSpawnPosition())
    self:GetBall():Setup()
end

--[[
    Updates the ball.
]]
function Addon.FootballBall:TryUpdateBall()
    if not self:IsBallSpawned() then
        return
    end

    self:GetBall():Update()
end

--[[
    Resets the ball.
]]
function Addon.FootballBall:ResetBall()
    if not self:IsBallSpawned() then
        error("Addon.FootballBall:ResetBall()", "Ball is not spawned.")
    end

    self:GetBall():Reset()
end

--[[
    Removes the ball.
]]
function Addon.FootballBall:RemoveBall()
    if not self:IsBallSpawned() then
        error("Addon.FootballBall:RemoveBall()", "Ball is not spawned.")
    end

    self:GetBall():Cleanup()
    self.Ball = nil
end

--[[
    Returns the ball spawn position.
]]
---@return SWMatrix
function Addon.FootballBall:GetBallSpawnPosition()
    if not Addon.FootballArena:IsArenaSpawned() then
        error("Addon.FootballBall:GetBallSpawnPosition()", "Arena is not spawned.")
    end

    local arena = Addon.FootballArena:GetArena()
    return arena:GetBallSpawnPosition()
end

--[[
    Returns if the ball is behind the team's goal.
]]
---@param team Team The team to check
---@return boolean
function Addon.FootballBall:IsBallBehindGoal(team)
    if not Addon.FootballArena:IsArenaSpawned() then
        return false
    end

    if not self:IsBallSpawned() then
        return false
    end

    local arena = Addon.FootballArena:GetArena()
    local ball = self:GetBall()

    return arena:IsBehindGoal(ball:GetPosition(), team)
end