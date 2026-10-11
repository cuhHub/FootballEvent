--------------------------------------------------------
-- Classes - API Conversion Request Response
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
    A class representing a response from the backend conversion service.
]]
---@class APIConversionRequestResponse: NoirDataclass
---@field New fun(self: APIConversionRequestResponse, text: string, statusCode: number, isSuccess: boolean, HTTPVersion: string, elapsed: number, hasResponse: boolean): APIConversionRequestResponse
---@field Text string The raw text from the HTTP(S) request. `nil` if `has_response` is false
---@field StatusCode number The status code. `nil` if `has_response` is false
---@field IsSuccess boolean Whether or not the request was successful. `nil` if `has_response` is false
---@field HTTPVersion string The HTTP version used. `nil` if `has_response` is false
---@field Elapsed number The time it took to make the request. `nil` if `has_response` is false
---@field HasResponse boolean Whether or not the request was successful
Addon.Classes.APIConversionRequestResponse = Noir.Libraries.Dataclasses:New("APIConversionRequestResponse", {
    Noir.Libraries.Dataclasses:Field("Text", "string", "nil"),
    Noir.Libraries.Dataclasses:Field("StatusCode", "number", "nil"),
    Noir.Libraries.Dataclasses:Field("IsSuccess", "boolean", "nil"),
    Noir.Libraries.Dataclasses:Field("HTTPVersion", "string", "nil"),
    Noir.Libraries.Dataclasses:Field("Elapsed", "number", "nil"),
    Noir.Libraries.Dataclasses:Field("HasResponse", "boolean")
})

--[[
    Returns an APIConversionRequestResponse instance from a response to a backend request.
    *classmethod*
]]
---@param response table The decoded response
---@return APIConversionRequestResponse
function Addon.Classes.APIConversionRequestResponse:FromBackendResponse(response)
    return self:New(
        response.text,
        response.status_code,
        response.is_success,
        response.http_version,
        response.elapsed,
        response.has_response
    )
end