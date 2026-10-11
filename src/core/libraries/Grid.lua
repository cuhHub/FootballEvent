--------------------------------------------------------
-- Libraries - Grid
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
    A library for creating a grid of matrices centered around a matrix.
]]
---@class Grid: NoirLibrary
Addon.Libs.Grid = Noir.Libraries:Create(
    "Grid",
    "A library for creating a grid of matrices centered around a matrix.",
    "A library for creating a grid of matrices centered around a matrix.",
    {"Cuh4"}
)

--[[
    Returns a 2D grid of matrices centered around a matrix.<br>
    Rows first, columns second.
]]
---@param center SWMatrix The center matrix
---@param rowCount integer The number of rows in the grid
---@param columnCount integer The number of columns in the grid
---@param spacing number The distance in meters between each matrix in the grid
---@return table<integer, table<integer, SWMatrix>>
function Addon.Libs.Grid:CreateGrid(center, rowCount, columnCount, spacing)
    local grid = {}

    for row = 1, rowCount do
        grid[row] = {}

        for column = 1, columnCount do
            local matrix = matrix.multiply(center, matrix.translation(
                spacing * (column - (columnCount / 2)),
                0,
                spacing * (row - (rowCount / 2))
            ))

            grid[row][column] = matrix
        end
    end

    return grid
end

--[[
    Returns a 2D grid of matrices that adds enough rows or columns to fit the number of values needed.
]]
---@param center SWMatrix The center matrix
---@param rowCount integer|nil The number of rows in the grid
---@param columnCount integer|nil The number of columns in the grid
---@param spacing number The distance in meters between each matrix in the grid
---@param values integer The value count
---@return table<integer, table<integer, SWMatrix>>
function Addon.Libs.Grid:CreateGridToFit(center, rowCount, columnCount, spacing, values)
    if rowCount and columnCount then
        error("Grid:CreateGridToFit()", "Either `rowCount` or `columnCount` must be nil.")
    end

    if values <= 0 then
        error("Grid:CreateGridToFit()", "`values` must be greater than 1.")
    end

    if rowCount then
        rowCount = Noir.Libraries.Number:Clamp(rowCount, 1, values)
        columnCount = math.ceil(values / rowCount)
    elseif columnCount then
        columnCount = Noir.Libraries.Number:Clamp(columnCount, 1, values)
        rowCount = math.ceil(values / columnCount)
    end

    return self:CreateGrid(center, rowCount, columnCount, spacing) ---@diagnostic disable-line: param-type-mismatch
end

--[[
    Creates a 2D grid of with best possible case of equal rows and columns, while fitting the number of values needed.
]]
---@param center SWMatrix The center matrix
---@param spacing number The distance in meters between each matrix in the grid
---@param values integer The value count
---@return table<integer, table<integer, SWMatrix>>
function Addon.Libs.Grid:CreateGridToFitBest(center, spacing, values)
    if values <= 0 then
        error("Grid:CreateGridToFitBest()", "`values` must be greater than 1.")
    end

    local rowCount = math.ceil(math.sqrt(values))
    local columnCount = math.ceil(values / rowCount)

    return self:CreateGrid(center, rowCount, columnCount, spacing)
end

--[[
    Iterates through all matrices in a grid.
]]
---@param grid table<integer, table<integer, SWMatrix>> The grid to iterate through
---@param callback fun(matrix: SWMatrix, row: integer, column: integer)
---@param iterationLimit integer|nil The maximum amount of matrices to iterate through. Nil for no limit
function Addon.Libs.Grid:IterateGrid(grid, callback, iterationLimit)
    local count = 0

    for rowIndex, row in ipairs(grid) do
        for columnIndex, matrix in ipairs(row) do
            count = count + 1

            if iterationLimit and count > iterationLimit then
                return
            end

            callback(matrix, rowIndex, columnIndex)
        end
    end
end