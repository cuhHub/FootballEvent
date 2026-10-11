--------------------------------------------------------
-- Libraries - Commands
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
    A library for command-related utilities.
]]
---@class CommandsLib: NoirLibrary
Addon.Libs.Commands = Noir.Libraries:Create(
    "Commands",
    "A library for command-related utilities.",
    "A library for command-related utilities.",
    {"Cuh4"}
)

--[[
    Handles paginated list commands.
]]
---@param context NoirCommandContext The command context
---@param title string The title to display
---@param list table<integer, string> The list to paginate
---@param pageSize integer The entries per page
---@param lineSep string|nil The line separator to use, nil for default
---@param callback? fun(message: string): string
function Addon.Libs.Commands:HandlePaginateList(context, title, list, pageSize, lineSep, callback)
    local pages = Addon.Libs.Table:Paginate(list, pageSize)
    local pageNumber = Noir.Libraries.Number:Clamp(tonumber(context.Args[1]) or 1, 1, #pages)
    local page = pages[pageNumber] ---@type table<integer, string>

    local content = ("%s (%d available) (Page %d/%d):\n%s\n\nUse '?%s (page)' to view other pages."):format(
        title,
        #list,
        pageNumber,
        #pages,
        Addon.Libs.String:BulletList(page, "-", lineSep or "\n"),
        context.Command.Name
    )

    Addon.Message:Send(
        context.Player,
        title,
        callback and callback(content) or content,
        Addon.Enums.NotificationType.INFO
    )
end