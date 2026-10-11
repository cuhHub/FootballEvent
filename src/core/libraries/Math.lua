--------------------------------------------------------
-- Libraries - Math
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
    A library for math utilities.
]]
---@class MathLib: NoirLibrary
Addon.Libs.Math = Noir.Libraries:Create(
    "Math",
    "A library for math utilities.",
    "A library for math utilities.",
    {"Cuh4"}
)

--[[
    Returns a compass direction ("NE", "E", etc) from the provided radian.
]]
---@param radian number The radian to get the direction from
---@return string
function Addon.Libs.Math:GetCompassDirection(radian)
    -- AI-generated unfortunately. not good enough at math for this
    local directions = {
        "n", "ne", "e", "se", "s", "sw", "w", "nw"
    }

    local degrees = math.deg(radian) % 360
    local adjusted = (degrees + 22.5) % 360

    return directions[math.floor(adjusted / 45) + 1]
end

--[[
    Lerps a number from a to b over t.
]]
---@param a number The starting number
---@param b number The ending number
---@param t number The lerp amount
---@return number
function Addon.Libs.Math:Lerp(a, b, t)
    return a + (b - a) * t
end

--[[
    Returns a random float between min and max.
]]
---@param min number The minimum value
---@param max number The maximum value
---@return number
function Addon.Libs.Math:RandomFloat(min, max)
    if min > max then
        min, max = max, min
    end

    return math.random() * (max - min) + min
end