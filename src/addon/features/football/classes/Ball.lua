--------------------------------------------------------
-- Classes - Ball
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
    A class for the football.
]]
---@class Ball: NoirClass
---@field New fun(self: Ball, asset: Asset, spawnPosition: SWMatrix): Ball
Addon.Classes.Ball = Noir.Class("Ball")

--[[
    Initializes new `Ball` instances.
]]
---@param asset Asset The ball asset
---@param spawnPosition SWMatrix The position to spawn the ball at
function Addon.Classes.Ball:Init(asset, spawnPosition)
    --[[
        The ball asset.
    ]]
    self.Asset = asset

    --[[
        The ball spawn position.
    ]]
    self.SpawnPosition = spawnPosition

    --[[
        The ball vehicle.
    ]]
    ---@type NoirVehicle
    self.Vehicle = nil

    --[[
        The ball's popup widget.
    ]]
    ---@type NoirPopupWidget
    self.PopupWidget = nil
end

--[[
    Sets up the ball.
]]
function Addon.Classes.Ball:Setup()
    self:Spawn()
end

--[[
    Cleans up the ball.
]]
function Addon.Classes.Ball:Cleanup()
    self:Despawn()
end

--[[
    Returns the ball's position.
]]
---@return SWMatrix
function Addon.Classes.Ball:GetPosition()
    return self:GetVehicle():GetPosition()
end

--[[
    Spawns the ball.
]]
function Addon.Classes.Ball:Spawn()
    if self:IsSpawned() then
        error("Addon.Classes.Ball:Spawn()", "Ball is already spawned.")
    end

    self.Vehicle = self.Asset:SpawnVehicle(self:GetSpawnPosition())
    Addon.Janitor:DisposeVehicle(self:GetVehicle())

    self.PopupWidget = Noir.Services.UIService:CreatePopup(
        "[v]",
        matrix.identity(),
        math.huge,
        true
    )

    Addon.Janitor:DisposeWidget(self.PopupWidget)

    Addon.Logger:Info("Ball: Spawned ball (ID: %s)", self:GetVehicle().ID)
end

--[[
    Updates the ball.
]]
function Addon.Classes.Ball:Update()
    if not self:IsSpawned() then
        return
    end

    local position = self:GetPosition() -- rather than :Offset(), we create a new matrix so offset doesn't take rotation into account

    self.PopupWidget.Position = matrix.translation(
        position[13],
        position[14] + 6,
        position[15]
    )

    self.PopupWidget:Update()
end

--[[
    Despawns the ball.
]]
function Addon.Classes.Ball:Despawn()
    if not self:IsSpawned() then
        error("Addon.Classes.Ball:Despawn()", "Ball is not spawned.")
    end

    self.Vehicle:Despawn()
    self.Vehicle = nil

    self.PopupWidget:Remove()
    self.PopupWidget = nil
end

--[[
    Resets the ball.
]]
function Addon.Classes.Ball:Reset()
    if not self:IsSpawned() then
        error("Addon.Classes.Ball:Reset()", "Ball is not spawned.")
    end

    self:GetVehicle():Teleport(self:GetSpawnPosition())
end

--[[
    Returns the ball asset.
]]
---@return Asset
function Addon.Classes.Ball:GetAsset()
    return self.Asset
end

--[[
    Returns the ball spawn position.
]]
---@return SWMatrix
function Addon.Classes.Ball:GetSpawnPosition()
    return self.SpawnPosition
end

--[[
    Returns if the ball is spawned or not.
]]
---@return boolean
function Addon.Classes.Ball:IsSpawned()
    return self.Vehicle ~= nil
end

--[[
    Returns the ball vehicle.
]]
---@return NoirVehicle
function Addon.Classes.Ball:GetVehicle()
    return self.Vehicle
end