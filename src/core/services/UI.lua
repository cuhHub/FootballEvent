--------------------------------------------------------
-- Services - UI
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
    A service that adds UI for players to see. Things like vehicles, etc, are shown via UI.
]]
---@class UI: NoirService
Addon.UI = Noir.Services:CreateService(
    "UI",
    false,
    "A service that adds UI for players to see.",
    "A service that adds UI for players to see. Things like vehicles, etc, are shown via UI.",
    {"Cuh4"}
)

Addon.UI.InitPriority = 0
Addon.UI.StartPriority = 99999

--[[
    Called when this service is initialized.
]]
function Addon.UI:ServiceInit()
    --[[
        An event for UI to be created in (per-player)
    ]]
    self.PlayerUIHook = Noir.Libraries.Events:Create()

    --[[
        An event for UI to be created in (global)
    ]]
    self.GlobalUIHook = Noir.Libraries.Events:Create()
end

--[[
    Called when this service is started.
]]
function Addon.UI:ServiceStart()
    --[[
        A connection to `PlayerService`'s `OnJoin` event.
    ]]
    ---@param player NoirPlayer
    self.OnJoinConnection = Noir.Services.PlayerService.OnJoin:Connect(function(player)
        self:_RequestPlayerUI(player)
    end)

    for _, player in pairs(Noir.Services.PlayerService:GetPlayers(true)) do
        self:_RequestPlayerUI(player)
    end

    self:_RequestGlobalUI()
    self:_CreateCommands()
end

--[[
    Sets all UI force hidden property for widgets belonging to a player.
]]
---@param player NoirPlayer The player to reference
---@param hide boolean|nil The value to set. Use nil for toggle behaviour
function Addon.UI:SetForceHideAll(player, hide)
    local widgets = Noir.Services.UIService:GetWidgetsBelongingToPlayer(player)

    for _, widget in pairs(widgets) do
        if hide ~= nil then
            widget.ForceHidden = hide
        else
            widget.ForceHidden = not widget.ForceHidden
        end

        widget:Update()
    end
end

--[[
    Requests UI creation for a player.
]]
---@param player NoirPlayer The player to create UI for
function Addon.UI:_RequestPlayerUI(player)
    self.PlayerUIHook:Fire(player)
end

--[[
    Requests UI creation for all players.
]]
function Addon.UI:_RequestGlobalUI()
    self.GlobalUIHook:Fire()
end

--[[
    Wraps a widget and associates it with an ID.
]]
---@param identifier string The identifier of the widget
---@param widget NoirWidget The widget to wrap
---@return NoirWidget
function Addon.UI:WrapWidget(identifier, widget)
    local _widget = self:LoadWidget(identifier, widget.Player)

    if _widget then
        widget:Remove()
        return _widget
    end

    self:SaveWidget(identifier, widget)
    return widget
end

--[[
    Creates a task to be used for UI updates.
    The task is automatically removed when the provided player leaves, if one is provided.
]]
---@param player NoirPlayer|nil The player to create the task for, or nil to not link to a player
---@param callback fun() The callback to call every update
---@return NoirTask
function Addon.UI:OnUIUpdate(player, callback)
    local task

    task = Noir.Services.TaskService:AddTimeTask(function()
        if player and not player.InGame then
            task:Remove()
            return
        end

        callback()
    end, Config.UI.UpdateInterval, nil, true)

    return task
end

--[[
    Saves a widget.
]]
---@param identifier string The identifier of the widget
---@param widget NoirWidget The widget to save
function Addon.UI:SaveWidget(identifier, widget)
    local savedWidgets = self:EnsuredLoad("Widgets", {})
    local ID = widget.Player and widget.Player.ID or -1

    if not savedWidgets[ID] then
        savedWidgets[ID] = {}
    end

    savedWidgets[ID][identifier] = widget.ID
end

--[[
    Loads a widget of a specific identifier.
]]
---@param identifier string The identifier of the widget
---@param player NoirPlayer|nil The player to load the widget for, or nil if the widget was global
---@return NoirWidget|nil
function Addon.UI:LoadWidget(identifier, player)
    local savedWidgets = self:EnsuredLoad("Widgets", {})
    local widgetID

    if player then
        widgetID = savedWidgets[player.ID] and savedWidgets[player.ID][identifier]
    else
        widgetID = savedWidgets[-1] and savedWidgets[-1][identifier]
    end

    if not widgetID then
        return
    end

    return Noir.Services.UIService:GetWidget(widgetID)
end

--[[
    Creates commands.
]]
function Addon.UI:_CreateCommands()
    Noir.Services.CommandService:CreateCommand(
        "ui",
        {},
        false,
        false,
        false,
        "Toggles all UI belonging to you.",

        function(context)
            if not context.HasPermission then
                return
            end

            if not context.Args[1] then
                Addon.Message:Send(
                    context.Player,
                    "UI",
                    "Please provide the first argument, either 'show' or 'hide'.\nE.g. '?ui show' to show UI, '?ui hide' to hide UI.",
                    Addon.Enums.NotificationType.INFO
                )

                return
            end

            local choice = context.Args[1]:lower()

            if choice ~= "show" and choice ~= "hide" then
                Addon.Message:Send(
                    context.Player,
                    "UI",
                    "Invalid argument. Please provide either 'show' or 'hide'.\nE.g. '?ui show' to show UI, '?ui hide' to hide UI.",
                    Addon.Enums.NotificationType.INFO
                )

                return
            end

            local hide = choice == "hide"
            self:SetForceHideAll(context.Player, hide)

            Addon.Message:Send(
                context.Player,
                "UI",
                "Your UI has been %s.",
                Addon.Enums.NotificationType.INFO,
                hide and "hidden" or "shown"
            )
        end
    )
end