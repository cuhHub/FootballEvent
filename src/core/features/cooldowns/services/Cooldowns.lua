--------------------------------------------------------
-- Services - Cooldowns
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
    A service that provides cooldown functionality.
]]
---@class Cooldowns: NoirService
Addon.Cooldowns = Noir.Services:CreateService(
    "Cooldowns",
    false,
    "A service that provides cooldown functionality.",
    "A service that provides cooldown functionality.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Cooldowns:ServiceInit()
    --[[
        All existing cooldowns.
    ]]
    ---@type table<integer, Cooldown>
    self.Cooldowns = {}
end

--[[
    Called when the service is started.
]]
function Addon.Cooldowns:ServiceStart()
    --[[
        A connection to onTick.
    ]]
    self.OnTickConnection = Noir.Callbacks:Connect("onTick", function()
        self:CheckCooldowns()
    end)

    if Noir.AddonReason == "AddonReload" then
        Noir.Services.HoarderService:LoadAll(
            self,
            "Cooldowns",
            self.Cooldowns,
            Addon.Classes.Cooldown,
            {}
        )
    end
end

--[[
    Checks for expired cooldowns.
]]
function Addon.Cooldowns:CheckCooldowns()
    for _, cooldown in pairs(self.Cooldowns) do
        if cooldown:HasExpired() then
            self:RemoveCooldown(cooldown)
        end
    end
end

--[[
    Returns if the key is on cooldown. If not, a cooldown is automatically created and false is returned.
]]
---@param key string The unique key of the cooldown
---@param duration number The duration of the cooldown
---@return boolean
function Addon.Cooldowns:HandleCooldown(key, duration)
    local cooldown = self:GetCooldown(key)

    if not cooldown then
        self:CreateCooldown(key, duration)
        return false
    end

    return true
end

--[[
    Creates a cooldown.
]]
---@param key string The unique key of the cooldown
---@param duration number The duration of the cooldown in seconds
---@return Cooldown
function Addon.Cooldowns:CreateCooldown(key, duration)
    local cooldown = Addon.Classes.Cooldown:New(key, duration)
    self.Cooldowns[key] = cooldown
    cooldown:Save()

    return cooldown
end

--[[
    Retrieves a cooldown by key.
]]
---@param key string The unique key of the cooldown
---@return Cooldown
function Addon.Cooldowns:GetCooldown(key)
    return self.Cooldowns[key]
end

--[[
    Removes a cooldown.
]]
---@param cooldown Cooldown The cooldown to remove
function Addon.Cooldowns:RemoveCooldown(cooldown)
    cooldown:Unsave()
    self.Cooldowns[cooldown.Key] = nil
end

--[[
    Returns a cooldown key for a player.
]]
---@param player NoirPlayer The player to get the cooldown key for
---@param key string The unique key of the cooldown
---@return string
function Addon.Cooldowns:_GetPlayerCooldownKey(player, key)
    return player.Steam.."_"..key
end

--[[
    Returns if a player is on cooldown with the specified key. If not, a cooldown is automatically created and false is returned.
]]
---@param player NoirPlayer The player to check the cooldown for
---@param key string The unique key of the cooldown
---@param duration number The duration of the cooldown
---@return boolean
function Addon.Cooldowns:HandlePlayerCooldown(player, key, duration)
    return self:HandleCooldown(self:_GetPlayerCooldownKey(player, key), duration)
end

--[[
    Creates a cooldown for a player.
]]
---@param player NoirPlayer The player to create the cooldown for
---@param key string The unique key of the cooldown
---@param duration number The duration of the cooldown in seconds
---@return Cooldown
function Addon.Cooldowns:CreatePlayerCooldown(player, key, duration)
    return self:CreateCooldown(self:_GetPlayerCooldownKey(player, key), duration)
end

--[[
    Retrieves a player's cooldown by key.
]]
---@param player NoirPlayer The player to retrieve the cooldown for
---@param key string The unique key of the cooldown
---@return Cooldown
function Addon.Cooldowns:GetPlayerCooldown(player, key)
    return self:GetCooldown(self:_GetPlayerCooldownKey(player, key))
end