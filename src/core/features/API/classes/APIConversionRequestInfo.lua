--------------------------------------------------------
-- Classes - API Conversion Request Info
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
    A class representing the info of a request to the backend conversion service.
]]
---@class APIConversionRequestInfo: NoirDataclass
---@field New fun(self: APIConversionRequestInfo, requestID: string): APIConversionRequestInfo
---@field RequestID string The ID of the request
Addon.Classes.APIConversionRequestInfo = Noir.Libraries.Dataclasses:New("APIConversionRequestInfo", {
    Noir.Libraries.Dataclasses:Field("RequestID", "string")
})

--[[
    Returns an APIConversionRequestInfo instance from a response to a backend request.
    *classmethod*
]]
---@param response table The decoded response
---@return APIConversionRequestInfo
function Addon.Classes.APIConversionRequestInfo:FromBackendResponse(response)
    return self:New(
        response.request_id
    )
end