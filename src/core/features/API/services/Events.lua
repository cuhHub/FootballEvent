--------------------------------------------------------
-- Services - API - Events
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
    Handles fetching and handling of server events.
]]
---@class API.Events: NoirService
Addon.API.Events = Noir.Services:CreateService("API.Events")

--[[
    Called when this service is initialized.
]]
function Addon.API.Events:ServiceInit()
    --[[
        A table of events that have been handled.
    ]]
    ---@type table<string, APIServerEvent>
    self.HandledEvents = {}

    --[[
        A table of events for different event types.
    ]]
    ---@type table<APIServerEventTypeEnum, NoirEvent>
    self.EventListeners = {}
end

--[[
    Called when this service is started.
]]
function Addon.API.Events:ServiceStart()
    Addon.API:RunWhenReady(function()
        if Config.API.ShouldFetchServerEvents then
            --[[
                A task for fetching and handling server events.
            ]]
            self.ServerEventTask = Noir.Services.TaskService:AddTimeTask(function()
                self:HandleServerEvents()
            end, Config.API.ServerEventFetchInterval, nil, true)
        end
    end)
end

--[[
    Triggers all callbacks for a server event.
    Used internally.
]]
---@param event APIServerEvent The event to trigger callbacks for
function Addon.API.Events:_TriggerServerEventCallback(event)
    if not self.EventListeners[event.Type] then
        return
    end

    self.EventListeners[event.Type]:Fire(event)
end

--[[
    Mark all received events as handled.
    Used internally.
]]
function Addon.API.Events:_MarkEventsAsHandled()
    ---@type table<integer, string>
    local identifiers = {}

    for _, event in pairs(self.HandledEvents) do
        table.insert(identifiers, event.Identifier)
    end

    Addon.API.Conversion:HTTPPATCH(
        Config.API.URL..Addon.Enums.APIServiceRoute.Servers..Addon.API.Server.ServerData.ID.."/events",
        function(response)
            self.HandledEvents = {}
        end,
        nil,
        nil,
        {
            events = identifiers
        }
    )
end

--[[
    Returns whether or not a server event has already been handled.
    Used internally.
]]
---@param rawEvent table The raw decoded event from backend
---@return boolean
function Addon.API.Events:_HasEventBeenHandled(rawEvent)
    return self.HandledEvents[rawEvent.identifier] ~= nil
end

--[[
    Fetches all active events for this server and calls the appropriate event in `Addon.API.Events.EventListeners`
]]
function Addon.API.Events:HandleServerEvents()
    Addon.API.Conversion:HTTPGET(Config.API.URL..Addon.Enums.APIServiceRoute.Servers..Addon.API.Server.ServerData.ID.."/events", function(response)
        local decoded = Noir.Libraries.JSON:Decode(response.Text)

        if not decoded then
            Addon.Logger:Warning("API.Events:FetchEvents(): Failed to decode response")
            return
        end

        for _, _event in pairs(decoded) do
            if self:_HasEventBeenHandled(_event) then
                goto continue
            end

            local event = Addon.Classes.APIServerEvent:FromBackendResponse(_event)
            self.HandledEvents[event.Identifier] = event -- so we don't handle the same event twice in case http delay doesn't rid the event in time

            self:_TriggerServerEventCallback(event)

            ::continue::
        end

        if #decoded >= 1 then
            self:_MarkEventsAsHandled()
        end
    end, function(response)
        Addon.Logger:Warning("API.Events:FetchEvents(): Failed to fetch events: "..response.Text)
    end)
end

--[[
    Listen for an event from the backend.
    Allows for `backend --> addon` communication.
]]
---@param eventType APIServerEventTypeEnum The type of events to listen out for
---@param callback fun(event: APIServerEvent) The callback to call whenever an event of the desired type is received
---@return NoirConnection
function Addon.API.Events:ListenForEvent(eventType, callback)
    if not self.EventListeners[eventType] then
        self.EventListeners[eventType] = Noir.Libraries.Events:Create()
    end

    return self.EventListeners[eventType]:Connect(callback)
end