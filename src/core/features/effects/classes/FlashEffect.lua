--------------------------------------------------------
-- Classes - Flash Effect
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
    An effect that spawns a small flash.
]]
---@class FlashEffect: Effect
---@field New fun(self: FlashEffect, position: SWMatrix): FlashEffect
Addon.Classes.FlashEffect = Noir.Class("FlashEffect", Addon.Classes.Effect)

--[[
    Initializes `FlashEffect` class instances.
]]
---@param position SWMatrix The position of the effect
function Addon.Classes.FlashEffect:Init(position)
    self:InitFrom(Addon.Classes.Effect, "Flash", position)
end

--[[
    Called upon the effect starting.
]]
function Addon.Classes.FlashEffect:OnStart()
    server.spawnExplosion(self:GetPosition(), 0)
    self:Complete()
end

--[[
    Called upon the effect completing.
]]
function Addon.Classes.FlashEffect:OnComplete() end