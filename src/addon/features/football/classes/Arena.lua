--------------------------------------------------------
-- Classes - Arena
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
    A class for the football arena.
]]
---@class Arena: NoirClass
---@field New fun(self: Arena, asset: Asset, spawnPosition: SWMatrix): Arena
Addon.Classes.Arena = Noir.Class("Arena")

--[[
    Initializes new `Arena` instances.
]]
---@param asset Asset The arena asset
---@param spawnPosition SWMatrix The position to spawn the arena at
function Addon.Classes.Arena:Init(asset, spawnPosition)
    --[[
        The arena asset.
    ]]
    self.Asset = asset

    --[[
        The arena spawn position.
    ]]
    self.SpawnPosition = spawnPosition

    --[[
        The spawn count per-team.
    ]]
    self.SpawnCountPerTeam = self:GetAsset():GetProperty("SpawnCountPerTeam") or error(
        "Addon.Classes.Arena:Init()",
        "SpawnCountPerTeam property is missing from arena asset (%s).",
        self:GetAsset():Format()
    )

    --[[
        The spawned arena vehicle.
    ]]
    ---@type NoirVehicle
    self.Vehicle = nil

    --[[
        An event fired when the arena loads.
    ]]
    self.OnLoad = Noir.Libraries.Events:Create()

    --[[
        A closet to cleanup things on despawn.
    ]]
    self.DespawnCloset = Addon.Janitor:CreateCloset()

    --[[
        The ball spawn Y offset.
    ]]
    self.BALL_SPAWN_Y_OFFSET = 1.25

    --[[
        The team spawn Y offset.
    ]]
    self.TEAM_SPAWN_Y_OFFSET = 1
end

--[[
    Sets up the arena.
]]
function Addon.Classes.Arena:Setup()
    self:Spawn()
end

--[[
    Cleans up the arena.
]]
function Addon.Classes.Arena:Cleanup()
    self:Despawn()
end

--[[
    Returns the arena asset.
]]
---@return Asset
function Addon.Classes.Arena:GetAsset()
    return self.Asset
end

--[[
    Returns the arena spawn position.
]]
---@return SWMatrix
function Addon.Classes.Arena:GetSpawnPosition()
    return self.SpawnPosition
end

--[[
    Returns the arena spawn count per-team.
]]
---@return integer
function Addon.Classes.Arena:GetSpawnCountPerTeam()
    return self.SpawnCountPerTeam
end

--[[
    Returns if the arena is spawned or not.
]]
---@return boolean
function Addon.Classes.Arena:IsSpawned()
    return self.Vehicle ~= nil
end

--[[
    Returns if the arena has loaded or not.
]]
---@return boolean
function Addon.Classes.Arena:HasLoaded()
    if not self:IsSpawned() then
        return false
    end

    return self:GetPrimaryBody():IsSimulating()
end

--[[
    Returns the arena primary body.
]]
---@return NoirBody
function Addon.Classes.Arena:GetPrimaryBody()
    if not self:IsSpawned() then
        error("Addon.Classes.Arena:GetPrimaryBody()", "Arena is not spawned.")
    end

    return self:GetVehicle().PrimaryBody
end

--[[
    Returns the arena vehicle.
]]
---@return NoirVehicle
function Addon.Classes.Arena:GetVehicle()
    if not self:IsSpawned() then
        error("Addon.Classes.Arena:GetVehicle()", "Arena is not spawned.")
    end

    return self.Vehicle
end

--[[
    Spawns the arena.
]]
function Addon.Classes.Arena:Spawn()
    if self:IsSpawned() then
        error("Addon.Classes.Arena:Spawn()", "Arena is already spawned.")
    end

    self.Vehicle = self.Asset:SpawnVehicle(self:GetSpawnPosition())
    Addon.Janitor:DisposeVehicle(self:GetVehicle())

    self.DespawnCloset:Add(self:GetPrimaryBody().OnLoad:Connect(function()
        self.OnLoad:Fire()
    end))

    Addon.Logger:Info("Arena: Spawned arena (ID: %s)", self:GetVehicle().ID)
end

--[[
    Despawns the arena.
]]
function Addon.Classes.Arena:Despawn()
    if not self:IsSpawned() then
        error("Addon.Classes.Arena:Despawn()", "Arena is not spawned.")
    end

    self.DespawnCloset:Cleanup()

    self.Vehicle:Despawn()
    self.Vehicle = nil
end

--[[
    Converts a team's name to sign format.
]]
---@param team Team The team to convert
---@return string
function Addon.Classes.Arena:ConvertTeamNameToSign(team)
    return team.Name:lower()
end

--[[
    Triggers the horn.
]]
function Addon.Classes.Arena:TriggerHorn()
    if not self:HasLoaded() then
        error("Addon.Classes.Arena:TriggerHorn()", "Arena is not loaded.")
    end

    self:GetPrimaryBody():PressButton("horn")
end

--[[
    Returns the position of a given sign.
]]
---@param signName string The sign to get the position of
---@return SWMatrix
function Addon.Classes.Arena:GetSignPosition(signName)
    if not self:HasLoaded() then
        error("Addon.Classes.Arena:GetSignPosition()", "Arena is not loaded.")
    end

    local primaryBody = self:GetPrimaryBody()
    local sign = primaryBody:GetSign(signName)

    if not sign then
        error("Addon.Classes.Arena:GetSignPosition()", "Sign %s does not exist.", signName)
    end

    return primaryBody:GetPosition(sign.pos.x, sign.pos.y, sign.pos.z)
end

--[[
    Returns the position of the given team's goal.
]]
---@param team Team The team to get the goal position of
---@return SWMatrix
function Addon.Classes.Arena:GetGoalPosition(team)
    if not self:HasLoaded() then
        error("Addon.Classes.Arena:GetGoalPosition()", "Arena is not loaded.")
    end

    return self:GetSignPosition(self:ConvertTeamNameToSign(team).."_goal")
end

--[[
    Returns if the provided team needs inverted logic (e.g. rotate spawns 180 degrees, etc.).
]]
---@param team Team The team to check
---@return boolean
function Addon.Classes.Arena:TeamNeedsInvertedLogic(team)
    return team.Name == "Red"
end

--[[
    Returns if the provided position is behind a team's goal.
]]
---@param position SWMatrix The position to check
---@param team Team The team to check
---@return boolean
function Addon.Classes.Arena:IsBehindGoal(position, team)
    if not self:HasLoaded() then
        error("Addon.Classes.Arena:IsBehindGoal()", "Arena is not loaded.")
    end

    local goalPosition = self:GetGoalPosition(team)

    if self:TeamNeedsInvertedLogic(team) then
        return position[15] > goalPosition[15]
    else
        return position[15] < goalPosition[15]
    end
end

--[[
    Returns all spawn positions for a team.
]]
---@param team Team The team to get the spawn positions of
---@return table<integer, SWMatrix>
function Addon.Classes.Arena:GetTeamSpawnPositions(team)
    if not self:HasLoaded() then
        error("Addon.Classes.Arena:GetSpawnPositions()", "Arena is not loaded.")
    end

    ---@type table<integer, SWMatrix>
    local spawns = {}

    local teamNameSign = self:ConvertTeamNameToSign(team)

    for i = 1, self:GetSpawnCountPerTeam() do
        local position = self:GetSignPosition(teamNameSign.."_spawn_"..i)

        if self:TeamNeedsInvertedLogic(team) then
            position = matrix.multiply(position, matrix.rotationY(math.rad(180)))
        end

        position = Noir.Libraries.Matrix:Offset(position, 0, self.TEAM_SPAWN_Y_OFFSET, 0)

        table.insert(spawns, position)
    end

    return spawns
end

--[[
    Returns the ball spawn point.
]]
---@return SWMatrix
function Addon.Classes.Arena:GetBallSpawnPosition()
    if not self:HasLoaded() then
        error("Addon.Classes.Arena:GetBallSpawnPosition()", "Arena is not loaded.")
    end

    local position = self:GetSignPosition("football_spawn")
    return Noir.Libraries.Matrix:Offset(position, 0, self.BALL_SPAWN_Y_OFFSET, 0)
end