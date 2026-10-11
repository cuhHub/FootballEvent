--------------------------------------------------------
-- Libraries - Asset Parser
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
    A library for parsing asset text (tags, props, etc.).
]]
---@class AssetParserLib: NoirLibrary
Addon.Libs.AssetParser = Noir.Libraries:Create(
    "AssetParser",
    "A library for parsing asset text.",
    "A library for parsing asset text (tags, props, etc.).",
    {"Cuh4"}
)

Addon.Libs.AssetParser.EQUAL_OPERATOR = "="
Addon.Libs.AssetParser.TAG_SEPARATOR = ","
Addon.Libs.AssetParser.TRUE_BOOL_KEYWORD = "true"
Addon.Libs.AssetParser.FALSE_BOOL_KEYWORD = "false"
Addon.Libs.AssetParser.SKIP_LINE_KEYWORD = ""

--[[
    Parses a property string value.
]]
---@param value string The value to parse
---@return string
function Addon.Libs.AssetParser:ParsePropertyStringValue(value)
    return value:gsub("\\n", "\n"):sub(2)
end

--[[
    Parses a property number value.
]]
---@param value string The value to parse
---@return number
function Addon.Libs.AssetParser:ParsePropertyNumberValue(value)
    return tonumber(value) or error("Addon.Libs.AssetParser:ParsePropertyNumberValue()", "Invalid number value: %s", value)
end

--[[
    Parses a property boolean value.
]]
---@param value string The value to parse
---@return boolean
function Addon.Libs.AssetParser:ParsePropertyBooleanValue(value)
    if value == self.TRUE_BOOL_KEYWORD then
        return true
    elseif value == self.FALSE_BOOL_KEYWORD then
        return false
    else
        error("Addon.Libs.AssetParser:ParsePropertyBooleanValue()", "Invalid boolean value: %s", value)
    end
end

--[[
    Returns the type of a raw property value.
]]
---@param value string The value to parse
---@return AssetPropertyValueType
function Addon.Libs.AssetParser:GetPropertyValueType(value)
    if Noir.Libraries.String:StartsWith(value, "\"") then
        return Addon.Enums.AssetPropertyValueType.String
    elseif value == self.TRUE_BOOL_KEYWORD or value == self.FALSE_BOOL_KEYWORD then
        return Addon.Enums.AssetPropertyValueType.Boolean
    elseif tonumber(value) then
        return Addon.Enums.AssetPropertyValueType.Number
    else
        return Addon.Enums.AssetPropertyValueType.None
    end
end

--[[
    Parses a property value.
]]
---@param value string The property value
---@return any, AssetPropertyValueType
function Addon.Libs.AssetParser:ParsePropertyValue(value)
    local valueType = self:GetPropertyValueType(value)

    if valueType == Addon.Enums.AssetPropertyValueType.String then
        return self:ParsePropertyStringValue(value), valueType
    elseif valueType == Addon.Enums.AssetPropertyValueType.Number then
        return self:ParsePropertyNumberValue(value), valueType
    elseif valueType == Addon.Enums.AssetPropertyValueType.Boolean then
        return self:ParsePropertyBooleanValue(value), valueType
    else
        error("Addon.Libs.AssetParser:ParsePropertyValue()", "Invalid property value: %s", value)
    end
end

--[[
    Parses a property line.
]]
---@param line string The property line
---@return string, any, AssetPropertyValueType
function Addon.Libs.AssetParser:ParsePropertyLine(line)
    local key, value = table.unpack(Noir.Libraries.String:Split(line, self.EQUAL_OPERATOR))
    return key, self:ParsePropertyValue(value)
end

--[[
    Parses asset tags.
]]
---@param tags string The tags to parse
---@return table<integer, string>
function Addon.Libs.AssetParser:ParseTags(tags)
    return Noir.Libraries.String:Split(tags, self.TAG_SEPARATOR)
end

--[[
    Parses asset text, returning tags and properties.
]]
---@param text string The text to parse
---@return table<integer, string>, table<string, any>
function Addon.Libs.AssetParser:ParseAssetText(text)
    if text == "" then
        return {}, {}
    end

    local lines = Noir.Libraries.String:Split(text:gsub("\r", ""), "\n") -- strip "\r" (windows clrf line endings)
    local tags = self:ParseTags(lines[1])

    ---@type table<integer, string>
    local propertyLines = Noir.Libraries.Table:Slice(lines, 2)

    ---@type table<string, any>
    local properties = {}

    for _, line in pairs(propertyLines) do
        if line == self.SKIP_LINE_KEYWORD then
            goto continue
        end

        local key, value = self:ParsePropertyLine(line)
        properties[key] = value

        ::continue::
    end

    return tags, properties
end