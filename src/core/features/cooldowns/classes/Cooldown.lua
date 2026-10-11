--------------------------------------------------------
-- Classes - Cooldown
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
    A class representing a cooldown.<br>
    Handled in `Cooldowns` service.
]]
---@class Cooldown: NoirHoardable
---@field New fun(self: Cooldown, key: string, duration: number): Cooldown
Addon.Classes.Cooldown = Noir.Class("Cooldown", Noir.Classes.Hoardable)

--[[
    Initializes `Cooldown` class instances.
]]
---@param key string The unique key of this cooldown.
---@param duration number The duration of this cooldown.
function Addon.Classes.Cooldown:Init(key, duration)
    self:InitFrom(Noir.Classes.Hoardable, key)

    --[[
        The key of this cooldown.
    ]]
    self.Key = key

    --[[
        The duration of this cooldown.
    ]]
    self.Duration = duration

    --[[
        When this cooldown started.
    ]]
    self.Started = Noir.Services.TaskService:GetTimeSeconds()

    --[[
        The duration of this cooldown.
    ]]
    self.Duration = duration
end

--[[
    Saves this cooldown.
]]
function Addon.Classes.Cooldown:Save()
    self:Hoard(Addon.Cooldowns, "Cooldowns")
end

--[[
    Unsave this cooldown.
]]
function Addon.Classes.Cooldown:Unsave()
    self:Unhoard(Addon.Cooldowns, "Cooldowns")
end

--[[
    Returns if this cooldown has expired.
]]
function Addon.Classes.Cooldown:HasExpired()
    return Noir.Services.TaskService:GetTimeSeconds() > self.Started + self.Duration
end