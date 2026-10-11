--------------------------------------------------------
-- Libraries - Table
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
    A library for table-related utilities.
]]
---@class TableLib: NoirLibrary
Addon.Libs.Table = Noir.Libraries:Create(
    "Table",
    "A library for table-related utilities.",
    "A library for table-related utilities (pagination, etc).",
    {"Cuh4"}
)

--[[
    Paginates a table by returning an array of tables representing pages.<br>
    Each page contains a maximum number of items defined by `pageSize`.
]]
---@param items table<integer, any> The table to paginate (must be sequential (an array))
---@param pageSize number The maximum number of items per page
---@return table<integer, table<integer, any>>
function Addon.Libs.Table:Paginate(items, pageSize)
    local pageCount = math.ceil(#items / pageSize)
    local pages = {}

    for i = 1, pageCount do
        local startIndex = (i - 1) * pageSize + 1
        local endIndex = math.min(i * pageSize, #items)
        pages[i] = Noir.Libraries.Table:Slice(items, startIndex, endIndex)
    end

    return pages
end

--[[
    Shuffles a sequential table randomly.
]]
---@param tbl table<integer, any> The table to shuffle
---@return table<integer, any>
function Addon.Libs.Table:Shuffle(tbl)
    local clone = Noir.Libraries.Table:Copy(tbl)

    for index = #clone, 2, -1 do
        local new = math.random(index)
        clone[index], clone[new] = clone[new], clone[index]
    end

    return clone
end

--[[
    Picks a random value from the table using weights, returning the value and index.
]]
---@param tbl table<integer, any> The table to pick from
---@param weightFunc fun(value: any): number The function called to get the weight of each value
---@return any|nil, integer|nil
function Addon.Libs.Table:Pick(tbl, weightFunc)
    local totalWeight = 0

    for _, item in pairs(tbl) do
        local weight = weightFunc(item)

        if weight < 0 then
            error("Addon.Libs.Table:Pick()", "Weight cannot be negative")
        end

        totalWeight = totalWeight + weightFunc(item)
    end

    if totalWeight <= 0 then
        return
    end

    local randomWeight = math.random() * totalWeight
    local currentWeight = 0

    for index, item in pairs(tbl) do
        currentWeight = currentWeight + weightFunc(item)

        if randomWeight <= currentWeight then
            return item, index
        end
    end
end

--[[
    Picks multiple unique random values from the table using weights, returning the values.
]]
---@param tbl table<integer, any> The table to pick from
---@param weightFunc fun(value: any): number The function called to get the weight of each value
---@param count integer The amount of values to pick
---@return table<integer, any>
function Addon.Libs.Table:PickMultiple(tbl, weightFunc, count)
    local pool = {}

    for _, value in pairs(tbl) do
        table.insert(pool, value)
    end

    local results = {}

    for _ = 1, math.min(count, #pool) do
        local pickedValue, pickedIndex = self:Pick(pool, weightFunc)

        if not pickedValue then
            break
        end

        table.insert(results, pickedValue)
        table.remove(pool, pickedIndex)
    end

    return results
end