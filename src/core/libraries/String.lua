--------------------------------------------------------
-- Libraries - String
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
    A library for string manipulation.
]]
---@class StringLib: NoirLibrary
Addon.Libs.String = Noir.Libraries:Create(
    "String",
    "A library for string manipulation.",
    "A library for string manipulation (bullet lists, etc).",
    {"Cuh4"}
)

--[[
    Lists a table of strings like a bullet list.
]]
---@param list table<integer, string> The list of strings
---@param bullet string The bullet to use (e.g: "-")
---@param lineSeparator string|nil The line separator to use, defaults to "\n"
---@return string
function Addon.Libs.String:BulletList(list, bullet, lineSeparator)
    local separator = bullet.." "
    return separator..table.concat(list, (lineSeparator or "\n")..separator)
end

--[[
    Converts a string into a user-friendly query-suitable format (e.g: "Hello World" -> "helloworld").
]]
---@param str string The string to convert
---@return string
function Addon.Libs.String:ToQuery(str)
    return (str:lower():gsub("%s+", ""):gsub("%p+", ""))
end

--[[
    Checks two strings and returns if they match (for querying).
]]
---@param searchAgainst string The first string
---@param query string The second string
---@return boolean
function Addon.Libs.String:QueryMatch(searchAgainst, query)
    return self:ToQuery(searchAgainst):find(self:ToQuery(query)) ~= nil
end

--[[
    Formats a 0-1 value into a percentage.
]]
---@param value number The 0-1 value
---@return string
function Addon.Libs.String:FormatPercentage(value)
    return ("%.0f%%"):format(value * 100)
end

--[[
    Truncates a string, adding the `ending` if it was truncated.
]]
---@param str string The string to truncate
---@param length integer The length to truncate to
---@param ending string|nil The ending to add if truncated
---@return string
function Addon.Libs.String:Truncate(str, length, ending)
    ending = ending or "..."

    if #str > length then
        return str:sub(1, length - #ending)..ending
    end

    return str
end