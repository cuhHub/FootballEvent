--------------------------------------------------------
-- Classes - API Conversion Request Events
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
    A class holding events for a response to a conversion request.
]]
---@class APIConversionRequestEvents: NoirDataclass
---@field New fun(self: APIConversionRequestEvents): APIConversionRequestEvents
Addon.Classes.APIConversionRequestEvents = Noir.Class("APIConversionRequestEvents")

--[[
    Initializes `APIConversionRequestEvents` class instances.
]]
function Addon.Classes.APIConversionRequestEvents:Init()
    --[[
        Fired if the request was successful.
    ]]
    self.OnSuccess = Noir.Libraries.Events:Create()

    --[[
        Fired if the request failed.
    ]]
    self.OnFailure = Noir.Libraries.Events:Create()

    --[[
        The time this was created.
    ]]
    self.CreatedAt = Noir.Services.TaskService:GetTimeSeconds()
end