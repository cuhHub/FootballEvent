--------------------------------------------------------
-- Classes - Kart
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
    A class for a player's kart.
]]
---@class Kart: NoirClass
---@field New fun(self: Kart, asset: Asset, spawnPosition: SWMatrix, player: NoirPlayer): Kart
Addon.Classes.Kart = Noir.Class("Kart")

--[[
    Initializes new `Kart` instances.
]]
---@param asset Asset The kart asset
---@param spawnPosition SWMatrix The position to spawn the kart at
---@param player NoirPlayer The player the kart belongs to
function Addon.Classes.Kart:Init(asset, spawnPosition, player)
    --[[
        The kart asset.
    ]]
    self.Asset = asset

    --[[
        The kart spawn position.
    ]]
    self.SpawnPosition = spawnPosition

    --[[
        The player the kart belongs to.
    ]]
    self.Player = player

    --[[
        The kart vehicle.
    ]]
    ---@type NoirVehicle
    self.Vehicle = nil

    --[[
        The kart cleanup closet.
    ]]
    self.CleanupCloset = Addon.Janitor:CreateCloset()

    --[[
        The seat name.
    ]]
    self.SEAT_NAME = "Seat"

    --[[
        The kart flip cooldown duration (seconds).
    ]]
    self.FLIP_COOLDOWN_DURATION = Config.Football.KartFlipCooldownSecs
end

--[[
    Sets up the kart.
]]
function Addon.Classes.Kart:Setup()
    self:Spawn()
    self:TrackSeatExit()
    self:NotifySpawnToPlayer()
end

--[[
    Handles cleanup.
]]
function Addon.Classes.Kart:Cleanup()
    self:Despawn()
    self.CleanupCloset:Cleanup()
end

--[[
    Notifies the kart spawn to the player.
]]
function Addon.Classes.Kart:NotifySpawnToPlayer()
    Addon.Message:Send(
        self:GetPlayer(),
        "Kart",
        "You have been spawned in your kart.\n%s.",
        Addon.Enums.NotificationType.SUCCESS,
        Addon.Libs.String:BulletList({
            "Use 'W/S' to move forward/backward",
            "Use 'A/D' to steer",
            "Use 1 for a one-time per-match boost, allowing you to quickly intercept a ball or hit it harder.",
            "Hold 'Space' for hard brakes",
            "Type '?flip' in chat to flip, in case you end up upside down"
        }, "-")
    )
end

--[[
    Spawns the kart.
]]
function Addon.Classes.Kart:Spawn()
    self.Vehicle = self:GetAsset():SpawnVehicle(self:GetSpawnPosition())
    Addon.Janitor:DisposeVehicle(self:GetVehicle())

    self.CleanupCloset:Add(self:GetPrimaryBody().OnLoad:Connect(function()
        self:Seat()
    end))

    Addon.Logger:Info("Kart: Kart spawned (player: %s)", Addon.Libs.Player:FormatPlayerName(self:GetPlayer()))
end

--[[
    Handles flip logic, with cooldowns etc.
]]
function Addon.Classes.Kart:TryFlip()
    if Addon.Cooldowns:HandlePlayerCooldown(self:GetPlayer(), "kart_flip", self.FLIP_COOLDOWN_DURATION) then
        Addon.Message:Send(
            self:GetPlayer(),
            "Kart",
            "This action is on cooldown. Try again later.",
            Addon.Enums.NotificationType.ERROR
        )

        return
    end

    self:Flip()
end

--[[
    Flips the kart.
]]
function Addon.Classes.Kart:Flip()
    if not self:IsSpawned() then
        error("Addon.Classes.Kart:Flip()", "Kart is not spawned.")
    end

    local position = self:GetPosition()
    local newPosition = matrix.translation(position[13], position[14] + 5, position[15])

    self:GetVehicle():Teleport(newPosition)

    Addon.Message:Send(
        self:GetPlayer(),
        "Kart",
        "Your kart has been flipped.",
        Addon.Enums.NotificationType.SUCCESS
    )

    Addon.Logger:Info("Kart: Flipped kart (player: %s)", Addon.Libs.Player:FormatPlayerName(self:GetPlayer()))
end

--[[
    Returns the kart's position.
]]
---@return SWMatrix
function Addon.Classes.Kart:GetPosition()
    if not self:IsSpawned() then
        error("Addon.Classes.Kart:GetPosition()", "Kart is not spawned.")
    end

    return self:GetVehicle():GetPosition()
end

--[[
    Resets the kart back to where it spawned.
]]
function Addon.Classes.Kart:Reset()
    self:Despawn()
    self:Spawn()
    Addon.Logger:Info("Kart: Reset kart (player: %s)", Addon.Libs.Player:FormatPlayerName(self:GetPlayer()))
end

--[[
    Despawns the kart.
]]
function Addon.Classes.Kart:Despawn()
    self.Vehicle:Despawn()
    self.Vehicle = nil
end

--[[
    Tracks when the player exits the kart seat.
]]
function Addon.Classes.Kart:TrackSeatExit()
    self.CleanupCloset:Add(Noir.Callbacks:Connect("onCharacterUnsit", function(objectID, bodyID, seatName)
        if not self:IsLoaded() then
            return
        end

        local character = self:GetPlayer():GetCharacter()

        if not character then
            return
        end

        if character.ID ~= objectID then
            return
        end

        if bodyID ~= self:GetPrimaryBody().ID then
            return
        end

        self:Seat()
    end))
end

--[[
    Seats the player in the kart.
]]
function Addon.Classes.Kart:Seat()
    if not self:IsLoaded() then
        error("Addon.Classes.Kart:Seat()", "Kart is not loaded.")
    end

    local character = self:GetPlayer():GetCharacter()

    if not character then
        error("Addon.Classes.Kart:Seat()", "Player has no character?")
    end

    character:Seat(self:GetPrimaryBody(), self.SEAT_NAME)
end

--[[
    Returns the kart asset.
]]
---@return Asset
function Addon.Classes.Kart:GetAsset()
    return self.Asset
end

--[[
    Returns the kart spawn position.
]]
---@return SWMatrix
function Addon.Classes.Kart:GetSpawnPosition()
    return self.SpawnPosition
end

--[[
    Returns the player the kart belongs to.
]]
---@return NoirPlayer
function Addon.Classes.Kart:GetPlayer()
    return self.Player
end

--[[
    Returns if the kart is loaded or not.
]]
---@return boolean
function Addon.Classes.Kart:IsLoaded()
    if not self:IsSpawned() then
        return false
    end

    if not self:GetPrimaryBody():IsSimulating() then
        return false
    end

    return true
end

--[[
    Returns if the kart has spawned or not.
]]
---@return boolean
function Addon.Classes.Kart:IsSpawned()
    return self.Vehicle ~= nil
end

--[[
    Returns the kart primary body.
]]
---@return NoirBody
function Addon.Classes.Kart:GetPrimaryBody()
    if not self:IsSpawned() then
        error("Addon.Classes.Kart:GetPrimaryBody()", "Kart is not spawned.")
    end

    return self:GetVehicle().PrimaryBody
end

--[[
    Returns the kart vehicle.
]]
---@return NoirVehicle
function Addon.Classes.Kart:GetVehicle()
    if not self:IsSpawned() then
        error("Addon.Classes.Kart:GetVehicle()", "Kart is not spawned.")
    end

    return self.Vehicle
end