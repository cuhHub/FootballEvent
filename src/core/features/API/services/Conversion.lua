--------------------------------------------------------
-- Services - API - Conversion
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
    Handles requests to cuhHub's Conversion Service, allowing for POST, DELETE, etc, requests.
]]
---@class API.Conversion: NoirService
Addon.API.Conversion = Noir.Services:CreateService("API.Conversion")

--[[
    Called when this service is initialized.
]]
function Addon.API.Conversion:ServiceInit()
    --[[
        Events for conversion requests, indexed by request ID.
    ]]
    ---@type table<string, APIConversionRequestEvents>
    self.ConversionRequestCallbacks = {}
end

--[[
    Called when this service is started.
]]
function Addon.API.Conversion:ServiceStart()
    Addon.API:RunWhenReady(function()
        if Config.API.ShouldFetchConversionRequestResponses then
            --[[
                A task for fetching and handling responses to conversion requests.
            ]]
            self.ConversionRequestTask = Noir.Services.TaskService:AddTimeTask(function()
                self:HandleConversionRequestResponses()
            end, Config.API.ConversionResponsesFetchInterval, nil, true)
        end
    end)
end

--[[
    Fetches and handles responses to conversion requests.<br>
    This should be called regularly.
]]
function Addon.API.Conversion:HandleConversionRequestResponses()
    -- Remove outdated responses
    for requestID, eventContainer in pairs(self.ConversionRequestCallbacks) do
        if Noir.Services.TaskService:GetTimeSeconds() - eventContainer.CreatedAt >= Config.API.ConversionRequestTimeout then
            self.ConversionRequestCallbacks[requestID] = nil
        end
    end

    -- Fetch and handle responses
    local requestIDs = Noir.Libraries.Table:Keys(self.ConversionRequestCallbacks)
    local requestIDsJSON = #requestIDs > 0 and Noir.Libraries.JSON:Encode(requestIDs) or "[]"

    local getResponsesURL = "/"..Addon.Enums.APIServiceRoute.Conversion.."get-response"..Noir.Libraries.HTTP:URLParameters({
        request_ids = requestIDsJSON
    })

    Noir.Services.HTTPService:GET(getResponsesURL, Config.API.Port, function(response)
        -- Check if the request was successful
        if not response:IsOk() then
            Addon.Logger:Warning("API.Conversion: HandleConversionRequestResponses(): Request to conversion service failed: "..response.Text)
            return
        end

        -- Decode the response
        ---@type table<string, table>
        local decoded = Noir.Libraries.JSON:Decode(response.Text)

        if not decoded then
            Addon.Logger:Warning("API.Conversion:HandleConversionRequestResponses(): Failed to decode conversion response: "..response.Text)
            return
        end

        -- Convert response to use the classes
        ---@type table<string, APIConversionRequestResponse>
        local responses = {}

        for requestID, conversionRequestResponse in pairs(decoded) do
            responses[requestID] = Addon.Classes.APIConversionRequestResponse:FromBackendResponse(conversionRequestResponse)
        end

        -- Handle the responses
        for requestID, conversionRequestResponse in pairs(responses) do
            if not conversionRequestResponse.HasResponse then
                goto continue
            end

            self:HandleConversionRequestResponse(requestID, conversionRequestResponse)

            ::continue::
        end
    end)
end

--[[
    Handles a conversion request response.
]]
---@param requestID string The ID of the request
---@param response APIConversionRequestResponse The response
function Addon.API.Conversion:HandleConversionRequestResponse(requestID, response)
    local callbacks = self.ConversionRequestCallbacks[requestID]

    if not callbacks then
        return
    end

    if response.IsSuccess then
        callbacks.OnSuccess:Fire(response)
    else
        callbacks.OnFailure:Fire(response)
    end

    self.ConversionRequestCallbacks[requestID] = nil
end

--[[
    Sets up events for a conversion request
]]
---@param requestInfo APIConversionRequestInfo The request info
---@param successCallback fun(response: APIConversionRequestResponse)|nil The callback to call when a response is received and is successful
---@param errorCallback fun(response: APIConversionRequestResponse)|nil The callback to call when the request fails
---@return APIConversionRequestEvents
function Addon.API.Conversion:SetupConversionRequest(requestInfo, successCallback, errorCallback)
    local eventContainer = Addon.Classes.APIConversionRequestEvents:New()

    if successCallback then
        eventContainer.OnSuccess:Connect(successCallback)
    end

    if errorCallback then
        eventContainer.OnFailure:Connect(errorCallback)
    end

    self.ConversionRequestCallbacks[requestInfo.RequestID] = eventContainer
    return eventContainer
end

--[[
    Send a GET/POST/... request via conversion service.
]]
---@param method APIHTTPMethodEnum The HTTP method to use
---@param URL string The full URL to send a request to
---@param callback fun(response: APIConversionRequestResponse)|nil The callback to call when a response is received. If this is nil, a response won't be expected in the backend
---@param errorCallback fun(response: APIConversionRequestResponse)|nil The callback to call when the request fails
---@param headers table<string, string>|nil The headers to send
---@param body table<string, any>|nil The body to send ("POST", "PUT", "PATCH" only)
function Addon.API.Conversion:HTTPRequest(method, URL, callback, errorCallback, headers, body)
    -- Check if this is a request to the backend
    local isRequestToBackend = Noir.Libraries.String:StartsWith(URL, Config.API.URL:sub(1, -2))

    if not Addon.API.API_TOKEN and isRequestToBackend then
        Addon.Logger:Warning("API.Conversion:HTTPRequest(): No API token set, can't send request to backend")
        return
    end

    Addon.Logger:Info("Conversion: API.Conversion:HTTPRequest()", "%s: %s", method:upper(), URL)

    -- Get headers
    headers = headers or {}

    if isRequestToBackend then -- we don't wanna provide the API token to sites other than the backend. stormworks is shit with security and there's likely a way for a client to call this method on their
        headers["X-Authorization"] = "Bearer "..Addon.API.API_TOKEN -- own hosted api and therefore steal the token
    end

    -- Get body
    local encoded_body

    if not body and (method == "POST" or method == "PUT" or method == "PATCH") then
        encoded_body = "{}"
    elseif body and (method == "POST" or method == "PUT" or method == "PATCH") then
        encoded_body = Noir.Libraries.JSON:Encode(body)
    else
        encoded_body = nil
    end

    -- Construct URL
    local url = "/"..Addon.Enums.APIServiceRoute.Conversion..method..Noir.Libraries.HTTP:URLParameters({
        url = URL,
        headers = Noir.Libraries.JSON:Encode(headers),
        body = encoded_body,
        expecting_response = callback ~= nil
    })

    -- Send request
    Noir.Services.HTTPService:GET(url, Config.API.Port, function(response)
        if not response:IsOk() then
            Addon.Logger:Warning("API.Conversion:HTTPRequest(): Request to conversion service failed: "..response.Text)
            return
        end

        if callback then
            ---@type table
            local decoded = response:JSON()

            if not decoded then
                Addon.Logger:Warning("API.Conversion:HTTPRequest(): Request to JSON decode conversion service response: "..response)
                return
            end

            local conversionRequestInfoResponse = Addon.Classes.APIConversionRequestInfo:FromBackendResponse(decoded)
            self:SetupConversionRequest(conversionRequestInfoResponse, callback, errorCallback)
        end
    end)
end

--[[
    Sends a GET request via the conversion service.
]]
---@param URL string The full URL to send a GET request to
---@param callback fun(response: APIConversionRequestResponse)|nil The callback to call when a response is received
---@param errorCallback fun(response: APIConversionRequestResponse)|nil The callback to call when the request fails
---@param headers table<string, string>|nil The headers to send
function Addon.API.Conversion:HTTPGET(URL, callback, errorCallback, headers)
    self:HTTPRequest(Addon.Enums.APIHTTPMethods.GET, URL, callback, errorCallback, headers)
end

--[[
    Sends a POST request via the conversion service.
]]
---@param URL string The full URL to send a POST request to
---@param callback fun(response: APIConversionRequestResponse)|nil The callback to call when a response is received
---@param errorCallback fun(response: APIConversionRequestResponse)|nil The callback to call when the request fails
---@param headers table<string, string>|nil The headers to send
---@param body table<string, any>|nil The body to send
function Addon.API.Conversion:HTTPPOST(URL, callback, errorCallback, headers, body)
    self:HTTPRequest(Addon.Enums.APIHTTPMethods.POST, URL, callback, errorCallback, headers, body)
end

--[[
    Sends a PUT request via the conversion service.
]]
---@param URL string The full URL to send a PUT request to
---@param callback fun(response: APIConversionRequestResponse)|nil The callback to call when a response is received
---@param errorCallback fun(response: APIConversionRequestResponse)|nil The callback to call when the request fails
---@param headers table<string, string>|nil The headers to send
---@param body table<string, any>|nil The body to send
function Addon.API.Conversion:HTTPPUT(URL, callback, errorCallback, headers, body)
    self:HTTPRequest(Addon.Enums.APIHTTPMethods.PUT, URL, callback, errorCallback, headers, body)
end

--[[
    Sends a PATCH request via the conversion service.
]]
---@param URL string The full URL to send a PATCH request to
---@param callback fun(response: APIConversionRequestResponse)|nil The callback to call when a response is received
---@param errorCallback fun(response: APIConversionRequestResponse)|nil The callback to call when the request fails
---@param headers table<string, string>|nil The headers to send
---@param body table<string, any>|nil The body to send
function Addon.API.Conversion:HTTPPATCH(URL, callback, errorCallback, headers, body)
    self:HTTPRequest(Addon.Enums.APIHTTPMethods.PATCH, URL, callback, errorCallback, headers, body)
end

--[[
    Sends a DELETE request via the conversion service.
]]
---@param URL string The full URL to send a DELETE request to
---@param callback fun(response: APIConversionRequestResponse)|nil The callback to call when a response is received
---@param errorCallback fun(response: APIConversionRequestResponse)|nil The callback to call when the request fails
---@param headers table<string, string>|nil The headers to send
function Addon.API.Conversion:HTTPDELETE(URL, callback, errorCallback, headers)
    self:HTTPRequest(Addon.Enums.APIHTTPMethods.DELETE, URL, callback, errorCallback, headers)
end