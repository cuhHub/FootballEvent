--------------------------------------------------------
-- Libraries - Time
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
    A library for time utilities.
]]
---@class TimeLib: NoirLibrary
Addon.Libs.Time = Noir.Libraries:Create(
    "Time",
    "A library for time utilities.",
    "A library for time utilities.",
    {"Cuh4"}
)

--[[
    Formats seconds to a readable time string (e.g. "1h 5m 3s").
]]
---@param seconds number The number of seconds to format
---@return string
function Addon.Libs.Time:FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)

    if hours > 0 then
        return ("%dh %dm %ds"):format(hours, minutes, secs)
    end

    if minutes > 0 then
        return ("%dm %ds"):format(minutes, secs)
    end

    if secs > 0 then
        return ("%ds"):format(secs)
    end

    return "0s"
end